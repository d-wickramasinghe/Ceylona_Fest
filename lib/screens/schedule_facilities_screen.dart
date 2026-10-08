import 'package:flutter/material.dart';
import '../services/db.dart';
import '../widgets/ceylona_bottom_navigation.dart';

class ScheduleFacilitiesScreen extends StatelessWidget {
  final String eventId;
  const ScheduleFacilitiesScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
          title: const Text('Schedule & Facilities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 2),
        body: StreamBuilder(
          stream: Db.event(eventId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.data!.exists) {
              return const Center(child: Text('Event not found'));
            }
            final data = snapshot.data!.data() ?? <String, dynamic>{};
            final agenda = (data['agenda'] as List?)
                    ?.whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [];
            final facilities =
                Map<String, dynamic>.from(data['facilities'] as Map? ?? {});
            return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  const Text('Event Timeline',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (agenda.isEmpty)
                    const Text('No schedule added yet.',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xff667085))),
                  for (final item in agenda)
                    _TimelineRow(
                        time: item['time']?.toString() ?? '',
                        activity: item['activity']?.toString() ?? ''),
                  const SizedBox(height: 24),
                  const Text('On-Site Facilities',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final facility in _facilityDefinitions)
                    if (facilities[facility.key]?.toString().isNotEmpty == true)
                      _FacilityRow(
                          icon: facility.icon,
                          title: facility.title,
                          note: facilities[facility.key].toString()),
                  if (facilities.isEmpty)
                    const Text('No facilities added yet.',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xff667085))),
                ]);
          },
        ),
      );
}

class _TimelineRow extends StatelessWidget {
  final String time;
  final String activity;
  const _TimelineRow({required this.time, required this.activity});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 66,
            child: Text(time,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff667085)))),
        Expanded(
            child: Text(activity,
                style: const TextStyle(fontSize: 11, color: Color(0xff172033))))
      ]));
}

class _FacilityDefinition {
  final String key;
  final IconData icon;
  final String title;
  const _FacilityDefinition(this.key, this.icon, this.title);
}

const _facilityDefinitions = [
  _FacilityDefinition('parking', Icons.local_parking, 'Parking'),
  _FacilityDefinition('transport', Icons.directions_bus, 'Public Transport'),
  _FacilityDefinition('food', Icons.restaurant, 'Food & Drinks'),
  _FacilityDefinition('restrooms', Icons.wc, 'Restrooms'),
  _FacilityDefinition('firstAid', Icons.medical_services, 'First Aid'),
];

class _FacilityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String note;
  const _FacilityRow(
      {required this.icon, required this.title, required this.note});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xffe5e7eb),
            child: Icon(icon, size: 17, color: const Color(0xff667085))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(note,
              style: const TextStyle(fontSize: 10, color: Color(0xff667085)))
        ]))
      ]));
}
