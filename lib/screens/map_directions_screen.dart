// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../widgets/ceylona_bottom_navigation.dart';
// import '../theme/app_theme.dart';

// class MapDirectionsScreen extends StatelessWidget {
//   final Map<String, dynamic> event;
//   const MapDirectionsScreen({super.key, required this.event});

//   @override
//   Widget build(BuildContext context) {
//     final latitude = (event['lat'] as num?)?.toDouble() ?? 6.9271;
//     final longitude = (event['lng'] as num?)?.toDouble() ?? 79.8612;
//     final point = LatLng(latitude, longitude);
//     return Scaffold(
//       body: SafeArea(
//         child: ListView(
//             padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
//             children: [
//               _PageHeader(
//                   title: 'Event Location',
//                   subtitle: event['title']?.toString() ?? 'Event',
//                   onBack: () => Navigator.pop(context)),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                 child: Column(children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(9),
//                 child: SizedBox(
//                   height: 190,
//                   child: FlutterMap(
//                     options: MapOptions(initialCenter: point, initialZoom: 14),
//                     children: [
//                       TileLayer(
//                           urlTemplate:
//                               'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           userAgentPackageName: 'com.example.ceylona'),
//                       MarkerLayer(markers: [
//                         Marker(
//                             point: point,
//                             width: 48,
//                             height: 48,
//                             child: const Icon(Icons.location_pin,
//                                 color: Color(0xff172033), size: 40))
//                       ]),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _InfoCard(event: event, latitude: latitude, longitude: longitude),
//               const SizedBox(height: 16),
//               const Text('Suggested Transport',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 8),
//               Row(children: const [
//                 _TransportTile(
//                     icon: Icons.directions_bus,
//                     label: 'Bus',
//                     detail: 'Route 138 / 120'),
//                 _TransportTile(
//                     icon: Icons.local_taxi,
//                     label: 'Taxi',
//                     detail: 'Uber / PickMe'),
//                 _TransportTile(
//                     icon: Icons.directions_walk,
//                     label: 'Train',
//                     detail: 'Kollupitiya Station'),
//               ]),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 44,
//                 child: FilledButton.icon(
//                   style: FilledButton.styleFrom(
//                       backgroundColor: const Color(0xff111827),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6))),
//                   icon: const Icon(Icons.near_me, size: 16),
//                   label: const Text('Get Directions',
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
//                   onPressed: () async {
//                     final uri = Uri.parse(
//                         'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
//                     if (await canLaunchUrl(uri)) {
//                       await launchUrl(uri,
//                           mode: LaunchMode.externalApplication);
//                     }
//                   },
//                 ),
//               )]),
//               ),
//             ]),
//       ),
//       bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
//     );
//   }
// }

// class _PageHeader extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final VoidCallback onBack;
//   const _PageHeader(
//       {required this.title, required this.subtitle, required this.onBack});

//   @override
//   Widget build(BuildContext context) => SizedBox(
//         height: 128,
//         child: Stack(children: [
//           ClipPath(
//               clipper: _HeaderClipper(),
//               child: Container(color: AppColors.primary)),
//           Positioned(
//               top: 14,
//               left: 12,
//               child: IconButton(
//                   onPressed: onBack,
//                   icon: const Icon(Icons.arrow_back, color: Colors.black))),
//           Positioned(
//               left: 20,
//               bottom: 28,
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 22, fontWeight: FontWeight.w700)),
//                 Text(subtitle, style: const TextStyle(fontSize: 11)),
//               ])),
//         ]),
//       );
// }

// class _HeaderClipper extends CustomClipper<ui.Path> {
//   @override
//   ui.Path getClip(Size size) {
//     final path = ui.Path()..lineTo(0, size.height * .72);
//     path.cubicTo(size.width * .25, size.height, size.width * .38,
//         size.height * .52, size.width * .58, size.height * .72);
//     path.cubicTo(size.width * .76, size.height * .9, size.width * .86,
//         size.height * .5, size.width, size.height * .64);
//     return path..lineTo(size.width, 0)..close();
//   }

//   @override
//   bool shouldReclip(covariant _HeaderClipper oldClipper) => false;
// }

// class _InfoCard extends StatelessWidget {
//   final Map<String, dynamic> event;
//   final double latitude;
//   final double longitude;
//   const _InfoCard(
//       {required this.event, required this.latitude, required this.longitude});

//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(event['title'] ?? 'Event location',
//               style:
//                   const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 4),
//           Text(event['location'] ?? 'Colombo, Sri Lanka',
//               style: const TextStyle(fontSize: 10, color: Color(0xff667085))),
//           const Divider(height: 12),
//           Row(children: [
//             const Icon(Icons.near_me, size: 12, color: Color(0xff667085)),
//             const SizedBox(width: 5),
//             Text(
//                 '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)} from your location',
//                 style: const TextStyle(fontSize: 9, color: Color(0xff667085)))
//           ]),
//         ]),
//       );
// }

// class _TransportTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String detail;
//   const _TransportTile(
//       {required this.icon, required this.label, required this.detail});

//   @override
//   Widget build(BuildContext context) => Expanded(
//           child: Container(
//         height: 62,
//         margin: const EdgeInsets.only(right: 6),
//         padding: const EdgeInsets.symmetric(vertical: 7),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: const Color(0xffd9dde5)),
//             borderRadius: BorderRadius.circular(6)),
//         child: Column(children: [
//           Icon(icon, size: 16, color: const Color(0xff172033)),
//           const SizedBox(height: 2),
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
//           Text(detail,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 7, color: Color(0xff667085)))
//         ]),
//       ));
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/ceylona_bottom_navigation.dart';
import '../theme/app_theme.dart';

class MapDirectionsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const MapDirectionsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    // ORIGINAL LOCATION LOGIC - UNCHANGED
    final latitude =
        (event['lat'] as num?)?.toDouble() ?? 6.9271;

    final longitude =
        (event['lng'] as num?)?.toDouble() ?? 79.8612;

    final point = LatLng(latitude, longitude);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CeylonaBottomNavigation(selectedIndex: 0),

      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER
            _PageHeader(
              title: 'Event Location',
              subtitle: event['title']?.toString() ?? 'Event',
              onBack: () => Navigator.pop(context),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16, 20, 16, 28,
                ),
                children: [
                  // Map section heading
                  const _SectionHeader(
                    icon: Icons.map_outlined,
                    title: 'Explore Location',
                    subtitle: 'Find your way to the event',
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // MAP CARD
                  // ==================================================

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 290,
                          child: Stack(
                            children: [
                              // ORIGINAL FLUTTER MAP
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: point,
                                  initialZoom: 14,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.ceylona',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: point,
                                        width: 48,
                                        height: 48,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: AppColors.primary,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Floating map label
                              Positioned(
                                top: 13,
                                left: 13,
                                child: IgnorePointer(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'EVENT LOCATION',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryDark,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Map coordinates footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MAP COORDINATES',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${latitude.toStringAsFixed(5)}, '
                                      '${longitude.toStringAsFixed(5)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.public_rounded,
                                color: AppColors.primary,
                                size: 21,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 23),

                  // ==================================================
                  // LOCATION INFORMATION
                  // ==================================================

                  const _SectionHeader(
                    icon: Icons.location_on_outlined,
                    title: 'Event Destination',
                    subtitle: 'Location details for your visit',
                  ),

                  const SizedBox(height: 13),

                  _InfoCard(
                    event: event,
                    latitude: latitude,
                    longitude: longitude,
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // TRANSPORT SUGGESTIONS
                  // ==================================================

                  const _SectionHeader(
                    icon: Icons.directions_bus_outlined,
                    title: 'Suggested Transport',
                    subtitle: 'Explore ways to reach your event',
                  ),

                  const SizedBox(height: 14),

                  // ORIGINAL TRANSPORT LABELS
                  const Row(
                    children: [
                      _TransportTile(
                        icon: Icons.directions_bus_rounded,
                        label: 'Bus',
                        detail: 'Route 138 / 120',
                      ),
                      SizedBox(width: 10),
                      _TransportTile(
                        icon: Icons.local_taxi_rounded,
                        label: 'Taxi',
                        detail: 'Uber / PickMe',
                      ),
                      SizedBox(width: 10),
                      _TransportTile(
                        icon: Icons.train_rounded,
                        label: 'Train',
                        detail: 'Kollupitiya Station',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // GOOGLE MAPS DIRECTIONS BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(
                        Icons.near_me_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // ORIGINAL GOOGLE MAPS LOGIC
                      onPressed: () async {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
                        );

                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 13,
                        color: AppColors.secondaryText,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Opens Google Maps for navigation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODERN PAGE HEADER
// ============================================================

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18, 15, 18, 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.045,
            ),
            blurRadius: 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP NAVIGATION
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: onBack,
                  child: const SizedBox(
                    height: 42,
                    width: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_rounded,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'DIRECTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const SizedBox(width: 42),
            ],
          ),

          const SizedBox(height: 24),

          // DECORATIVE SECTION LABEL
          Row(
            children: [
              Container(
                width: 21,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'FIND YOUR WAY',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Event ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Location',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EVENT LOCATION INFORMATION CARD
// ============================================================

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final double latitude;
  final double longitude;

  const _InfoCard({
    required this.event,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title']?.toString() ??
                          'Event location',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      event['location']?.toString() ??
                          'Colombo, Sri Lanka',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            color: AppColors.border,
            height: 1,
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              const Icon(
                Icons.pin_drop_outlined,
                color: AppColors.primary,
                size: 17,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Coordinates: ${latitude.toStringAsFixed(5)}, '
                  '${longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          if (event['address']?.toString().isNotEmpty ==
              true) ...[
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  color: AppColors.primary,
                  size: 17,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    event['address'].toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// MODERN TRANSPORT TILE
// ============================================================

class _TransportTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;

  const _TransportTile({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 116,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              detail,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}