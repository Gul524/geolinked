import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolinked/feature/home/home_controller.dart';
import 'package:geolinked/feature/map/map_controller.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeMapWidget extends ConsumerStatefulWidget {
  const HomeMapWidget({super.key});

  @override
  ConsumerState<HomeMapWidget> createState() => _HomeMapWidgetState();
}

class _HomeMapWidgetState extends ConsumerState<HomeMapWidget> {
  static const LatLng _defaultCenter = LatLng(24.8607, 67.0011);
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeMapControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleCameraRequest(HomeMapState? previous, HomeMapState next) {
    if (_mapController == null) return;

    final LatLng? nextTarget = next.cameraTarget;
    final double? nextZoom = next.cameraZoom;

    if (nextTarget == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: nextTarget, zoom: nextZoom ?? 15.0),
      ),
    );
    ref.read(homeMapControllerProvider.notifier).clearCameraRequest();
  }

  @override
  Widget build(BuildContext context) {
    final HomeMapState state = ref.watch(homeMapControllerProvider);
    final HomeMapController mapController = ref.read(
      homeMapControllerProvider.notifier,
    );
    final HomeController homeController = ref.read(
      homeControllerProvider.notifier,
    );

    ref.listen<HomeMapState>(homeMapControllerProvider, _handleCameraRequest);

    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final LatLng initialCenter = state.currentLocation ?? _defaultCenter;

    final Set<Marker> markers = {
      if (state.currentLocation != null)
        Marker(
          markerId: const MarkerId('current_location'),
          position: state.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      if (state.targetLocation != null)
        Marker(
          markerId: const MarkerId('target_location'),
          position: state.targetLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ...state.communityMarkers.map((data) {
        return Marker(
          markerId: MarkerId(data.id),
          position: data.position,
          icon: _getMarkerIcon(data, state.markerIcons),
          infoWindow: InfoWindow(
            title: data.type == 'ask' ? 'Query' : data.category ?? 'Alert',
          ),
        );
      }),
    };

    return SafeArea(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: 13.5,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (LatLng point) {
              if (!state.isTargetSlecting) return;
              mapController.selectTargetLocation(point);
            },
          ),

          // Search Bar
          Positioned(
            top: 28,
            left: 14,
            right: 14,
            child: Column(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.search,
                          color: Color(0xFF007AFF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: mapController.searchPlaces,
                            decoration: InputDecoration(
                              hintText: 'Search places...',
                              border: InputBorder.none,
                              suffixIcon:
                                  state.searchResults.isNotEmpty ||
                                      state.isLoading
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        mapController.clearSearchResults();
                                        FocusScope.of(context).unfocus();
                                      },
                                    )
                                  : null,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: onSurface),
                          ),
                        ),
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: state.searchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = state.searchResults[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          title: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            _searchController.text = result.displayName;
                            mapController.selectSearchResult(result);
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // My Location Button
          Positioned(
            bottom: state.isConfirmingLocation ? 100 : 20,
            left: 20,
            child: GestureDetector(
              onTap: mapController.moveToCurrentLocation,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF007AFF),
                  size: 22,
                ),
              ),
            ),
          ),
          if (state.isConfirmingLocation)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: mapController.cancelLocationConfirmation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          if (state.targetLocation != null && context.mounted) {
                            unawaited(
                              homeController.onLocationConfirmed(context),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  BitmapDescriptor _getMarkerIcon(
    MapMarkerData data,
    Map<String, BitmapDescriptor> icons,
  ) {
    if (data.type == 'ask') {
      return icons['ask'] ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    final String? category = data.category;
    if (category != null && icons.containsKey(category)) {
      return icons[category]!;
    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }
}
