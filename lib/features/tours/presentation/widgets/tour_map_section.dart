import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class TourMapSection extends StatelessWidget {
  final List<LatLng> coordinates;
  final LatLng center;

  const TourMapSection({
    super.key,
    required this.coordinates,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tour_detail.location_route'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: RepaintBoundary(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: coordinates.length > 1 ? 9 : 12,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: kOpenStreetMapTileUrl,
                    userAgentPackageName: 'com.example.onlinetravelagent',
                  ),
                  // Connect route paths if multiple destinations
                  if (coordinates.length > 1)
                    PolylineLayer(
                      polylines: <Polyline<Object>>[
                        Polyline(
                          points: coordinates,
                          strokeWidth: 4,
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: coordinates.map((pt) {
                      final int idx = coordinates.indexOf(pt);
                      return Marker(
                        point: pt,
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_sharp,
                              color: Colors.red,
                              size: 32,
                            ),
                            Positioned(
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
