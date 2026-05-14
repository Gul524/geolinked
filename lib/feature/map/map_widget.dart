import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolinked/feature/home/home_controller.dart';
import 'package:geolinked/feature/map/map_controller.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:latlong2/latlong.dart';

class HomeMapWidget extends ConsumerStatefulWidget {
  const HomeMapWidget({super.key});

  @override
  ConsumerState<HomeMapWidget> createState() => _HomeMapWidgetState();
}

class _HomeMapWidgetState extends ConsumerState<HomeMapWidget> {
  static const LatLng _defaultCenter = LatLng(24.8607, 67.0011);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeMapControllerProvider.notifier).initialize();
    });
  }

  Marker _buildTargetLocationMark(LatLng point) {
    return Marker(
      point: point,
      width: 70,
      height: 70,
      child: const _CenterPulseMarker(),
    );
  }

  Marker _buildCurrentLocationMark(LatLng point) {
    return Marker(
      point: point,
      width: 22,
      height: 22,
      child: const _DotMarker(color: Color(0xFF007AFF)),
    );
  }

  Marker _buildCommunityMarker(MapMarkerData data) {
    return Marker(
      point: data.position,
      width: 32,
      height: 32,
      child: _CustomCategoryMarker(data: data),
    );
  }

  void _handleCameraRequest(HomeMapState? previous, HomeMapState next) {
    final LatLng? previousTarget = previous?.cameraTarget;
    final LatLng? nextTarget = next.cameraTarget;
    final double? previousZoom = previous?.cameraZoom;
    final double? nextZoom = next.cameraZoom;

    if (nextTarget == null ||
        (previousTarget == nextTarget && previousZoom == nextZoom)) {
      return;
    }

    final double zoom = nextZoom ?? _mapController.camera.zoom;
    _mapController.move(nextTarget, zoom);
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

    final List<Marker> communityMarkers = state.communityMarkers
        .map((data) => _buildCommunityMarker(data))
        .toList();

    return SafeArea(
      child: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.5,
              minZoom: 3,
              maxZoom: 19,
              onTap: (_, LatLng point) {
                if (!state.isTargetSlecting) {
                  return;
                }
                mapController.selectTargetLocation(point);
              },
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const <String>['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.geolinked.app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  markers: communityMarkers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MarkerLayer(
                markers: [
                  if (state.targetLocation != null)
                    _buildTargetLocationMark(state.targetLocation!),
                  if (state.currentLocation != null)
                    _buildCurrentLocationMark(state.currentLocation!),
                ],
              ),
              RichAttributionWidget(
                attributions: <SourceAttribution>[
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          // Search Bar
          Positioned(
            top: 14,
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
                            onChanged: mapController.searchPlaces,
                            decoration: const InputDecoration(
                              hintText: 'Search places...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: onSurface,
                                ),
                          ),
                        ),
                        if (state.isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                          title: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
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
}

class _CustomCategoryMarker extends StatelessWidget {
  const _CustomCategoryMarker({required this.data});

  final MapMarkerData data;

  @override
  Widget build(BuildContext context) {
    if (data.type == 'ask') {
      return _MarkerContainer(
        color: const Color(0xFF16A34A),
        icon: Icons.help_outline_rounded,
      );
    }

    Color color = const Color(0xFF2563EB);
    IconData icon = Icons.info_outline_rounded;

    switch (data.category) {
      case 'Traffic':
        color = const Color(0xFFEA580C);
        icon = Icons.traffic_rounded;
        break;
      case 'Road Block':
        color = const Color(0xFFDC2626);
        icon = Icons.block_flipped;
        break;
      case 'Safety Alert':
        color = const Color(0xFFDC2626);
        icon = Icons.warning_amber_rounded;
        break;
      case 'Utility Issue':
        color = const Color(0xFF854D0E);
        icon = Icons.build_circle_rounded;
        break;
      case 'Market Update':
        color = const Color(0xFF0D9488);
        icon = Icons.shopping_bag_rounded;
        break;
      case 'Public Event':
        color = const Color(0xFF7C3AED);
        icon = Icons.event_note_rounded;
        break;
    }

    return _MarkerContainer(color: color, icon: icon);
  }
}

class _MarkerContainer extends StatelessWidget {
  const _MarkerContainer({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _CenterPulseMarker extends StatelessWidget {
  const _CenterPulseMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF007AFF).withOpacity(0.18),
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _DotMarker extends StatelessWidget {
  const _DotMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
