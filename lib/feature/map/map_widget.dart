import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolinked/feature/map/map_controller.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/exports.dart';
import 'package:latlong2/latlong.dart';

class HomeMapWidget extends ConsumerStatefulWidget {
  const HomeMapWidget({super.key});

  @override
  ConsumerState<HomeMapWidget> createState() => _HomeMapWidgetState();
}

class _HomeMapWidgetState extends ConsumerState<HomeMapWidget> {
  static const LatLng _defaultCenter = LatLng(24.8607, 67.0011);
  final MapController _mapController = MapController();

  List<Marker> _buildMarkers(HomeMapState state) {
    return <Marker>[
      if (state.targetLocation != null)
        _buildTargetLocationMark(state.targetLocation!),
      ..._buildBroadcastMarks(state.broadcasts),
      if (state.currentLocation != null)
        _buildCurrentLocationMark(state.currentLocation!),
    ];
  }

  Marker _buildTargetLocationMark(LatLng point) {
    return Marker(
      point: point,
      width: 70,
      height: 70,
      child: const _CenterPulseMarker(),
    );
  }

  List<Marker> _buildBroadcastMarks(List<LatLng> points) {
    return points
        .map(
          (LatLng point) => Marker(
            point: point,
            width: 28,
            height: 28,
            child: const _DotMarker(color: Color(0xFF00A86B)),
          ),
        )
        .toList(growable: false);
  }

  Marker _buildCurrentLocationMark(LatLng point) {
    return Marker(
      point: point,
      width: 22,
      height: 22,
      child: const _DotMarker(color: Color(0xFF007AFF)),
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
    final List<Marker> markers = _buildMarkers(state);
    final LatLng initialCenter = state.targetLocation ?? _defaultCenter;

    final List<LatLng> routePoints = <LatLng>[
      if (state.currentLocation != null) state.currentLocation!,
      ...state.points,
      if (state.targetLocation != null) state.targetLocation!,
    ];

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
              if (routePoints.length > 1)
                PolylineLayer(
                  polylines: <Polyline>[
                    Polyline(
                      points: routePoints,
                      strokeWidth: 3,
                      color: const Color(0xFF007AFF).withValues(alpha: 0.8),
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
              RichAttributionWidget(
                attributions: <SourceAttribution>[
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    textStyle: TextStyle(fontSize: 11),
                  ),
                  TextSourceAttribution(
                    '© CARTO',
                    textStyle: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.public_rounded,
                      color: Color(0xFF007AFF),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live community map',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'English',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
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
          color: const Color(0xFF007AFF).withValues(alpha: 0.18),
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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
