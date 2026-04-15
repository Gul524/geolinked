import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeMapWidget extends StatelessWidget {
  const HomeMapWidget({super.key});

  static const LatLng _initialCenter = LatLng(24.8607, 67.0011);

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Stack(
      children: <Widget>[
        FlutterMap(
          options: const MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 13.5,
            minZoom: 3,
            maxZoom: 19,
          ),
          children: <Widget>[
            TileLayer(
              // Free, no key required, clean readable style.
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const <String>['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.geolinked.app',
            ),
            const MarkerLayer(
              markers: <Marker>[
                Marker(
                  point: _initialCenter,
                  width: 70,
                  height: 70,
                  child: _CenterPulseMarker(),
                ),
              ],
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ],
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
