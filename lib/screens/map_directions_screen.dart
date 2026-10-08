import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/ceylona_bottom_navigation.dart';

class MapDirectionsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  const MapDirectionsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final latitude = (event['lat'] as num?)?.toDouble() ?? 6.9271;
    final longitude = (event['lng'] as num?)?.toDouble() ?? 79.8612;
    final point = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
        title: const Text('Event Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  height: 190,
                  child: FlutterMap(
                    options: MapOptions(initialCenter: point, initialZoom: 14),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.ceylona'),
                      MarkerLayer(markers: [
                        Marker(
                            point: point,
                            width: 48,
                            height: 48,
                            child: const Icon(Icons.location_pin,
                                color: Color(0xff172033), size: 40))
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _InfoCard(event: event, latitude: latitude, longitude: longitude),
              const SizedBox(height: 16),
              const Text('Suggested Transport',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: const [
                _TransportTile(
                    icon: Icons.directions_bus,
                    label: 'Bus',
                    detail: 'Route 138 / 120'),
                _TransportTile(
                    icon: Icons.local_taxi,
                    label: 'Taxi',
                    detail: 'Uber / PickMe'),
                _TransportTile(
                    icon: Icons.directions_walk,
                    label: 'Train',
                    detail: 'Kollupitiya Station'),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  icon: const Icon(Icons.near_me, size: 16),
                  label: const Text('Get Directions',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ]),
      ),
      bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final double latitude;
  final double longitude;
  const _InfoCard(
      {required this.event, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event['title'] ?? 'Event location',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(event['location'] ?? 'Colombo, Sri Lanka',
              style: const TextStyle(fontSize: 10, color: Color(0xff667085))),
          const Divider(height: 12),
          Row(children: [
            const Icon(Icons.near_me, size: 12, color: Color(0xff667085)),
            const SizedBox(width: 5),
            Text(
                '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)} from your location',
                style: const TextStyle(fontSize: 9, color: Color(0xff667085)))
          ]),
        ]),
      );
}

class _TransportTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  const _TransportTile(
      {required this.icon, required this.label, required this.detail});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Container(
        height: 62,
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffd9dde5)),
            borderRadius: BorderRadius.circular(6)),
        child: Column(children: [
          Icon(icon, size: 16, color: const Color(0xff172033)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          Text(detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 7, color: Color(0xff667085)))
        ]),
      ));
}
