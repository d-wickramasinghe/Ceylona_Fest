import 'package:flutter/material.dart';
import '../services/db.dart';

class OrganizerScheduleEditorScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;
  const OrganizerScheduleEditorScreen(
      {super.key, required this.eventId, required this.eventTitle});

  Future<void> _addAgenda(BuildContext context) async {
    final time = TextEditingController();
    final activity = TextEditingController();
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Add Agenda Item'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: time,
                      decoration: const InputDecoration(labelText: 'Time')),
                  TextField(
                      controller: activity,
                      decoration: const InputDecoration(labelText: 'Activity'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Add'))
                ]));
    if (confirmed == true &&
        time.text.trim().isNotEmpty &&
        activity.text.trim().isNotEmpty) {
      await Db.addAgendaItem(eventId, time.text.trim(), activity.text.trim());
    }
  }

  Future<void> _setFacility(BuildContext context, _FacilityDefinition facility,
      String? current) async {
    final note = TextEditingController(text: current);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: Text(facility.title),
                content: TextField(
                    controller: note,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Description')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Save'))
                ]));
    if (confirmed == true && note.text.trim().isNotEmpty) {
      await Db.setFacility(eventId, facility.key, note.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(eventTitle)),
        body: StreamBuilder(
          stream: Db.event(eventId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data() ?? <String, dynamic>{};
            final agenda = (data['agenda'] as List?)
                    ?.whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [];
            final facilities =
                Map<String, dynamic>.from(data['facilities'] as Map? ?? {});
            return ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Event Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final item in agenda)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['activity'] ?? ''),
                    leading: SizedBox(
                        width: 62,
                        child: Text(item['time'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => Db.removeAgendaItem(eventId, item))),
              OutlinedButton.icon(
                  onPressed: () => _addAgenda(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Agenda Item')),
              const SizedBox(height: 24),
              const Text('On-Site Facilities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              for (final facility in _facilityDefinitions)
                SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(facility.icon),
                    title: Text(facility.title),
                    subtitle: facilities[facility.key] == null
                        ? null
                        : Text(facilities[facility.key].toString()),
                    value: facilities[facility.key] != null,
                    onChanged: (enabled) => enabled
                        ? _setFacility(context, facility,
                            facilities[facility.key]?.toString())
                        : Db.removeFacility(eventId, facility.key)),
            ]);
          },
        ),
      );
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
