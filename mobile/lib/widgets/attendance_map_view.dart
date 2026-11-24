import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

/// Widget peta interaktif menggunakan flutter_map dan OpenStreetMap.
/// Menampilkan lokasi kantor dinas, radius zona geofence, dan posisi perangkat pengguna.
class AttendanceMapView extends StatelessWidget {
  const AttendanceMapView({
    super.key,
    this.officeLocation = const LatLng(-7.328587, 112.729360), // DKP Prov Jatim, Surabaya
    this.userLocation,
    this.radiusMeters = 100.0,
    this.isUserInside = true,
    this.officeName = 'DKP Provinsi Jawa Timur',
    this.height = 240.0,
  });

  final LatLng officeLocation;
  final LatLng? userLocation;
  final double radiusMeters;
  final bool isUserInside;
  final String officeName;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveUserLocation = userLocation ?? officeLocation;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.ocean.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ocean.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: effectiveUserLocation,
              initialZoom: 16.5,
              minZoom: 12.0,
              maxZoom: 18.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'id.go.jatimprov.dkp.simelayur',
                maxZoom: 19,
              ),

              // Geofence Circle Layer (Zona Presensi)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: officeLocation,
                    radius: radiusMeters,
                    useRadiusInMeter: true,
                    color: (isUserInside ? AppColors.success : Colors.red)
                        .withValues(alpha: 0.18),
                    borderColor: isUserInside ? AppColors.success : Colors.red,
                    borderStrokeWidth: 2.0,
                  ),
                ],
              ),

              // Markers Layer (Kantor & Posisi Pengguna)
              MarkerLayer(
                markers: [
                  // Marker Kantor DKP
                  Marker(
                    point: officeLocation,
                    width: 70,
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.ocean,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.business_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'DKP Jatim',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Marker Posisi Pengguna
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isUserInside ? AppColors.success : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: (isUserInside
                                        ? AppColors.success
                                        : Colors.red)
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Label Info Badge di pojok atas peta
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: isUserInside ? AppColors.ocean : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            officeName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isUserInside ? AppColors.success : Colors.red)
                        .withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    isUserInside ? 'Radius ${radiusMeters.toInt()}m' : 'Luar Radius',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
