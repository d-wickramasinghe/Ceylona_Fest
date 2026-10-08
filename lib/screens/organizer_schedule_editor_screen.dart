import 'package:flutter/material.dart';
import '../services/db.dart';

class OrganizerScheduleEditorScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  const OrganizerScheduleEditorScreen(
      {super.key, required this.eventId, required this.eventTitle});

  @override
  State<OrganizerScheduleEditorScreen> createState() =>
      _OrganizerScheduleEditorScreenState();
}

class _OrganizerScheduleEditorScreenState
    extends State<OrganizerScheduleEditorScreen> {
  Future<void> _editAgenda(
      BuildContext context, Map<String, dynamic>? existing) async {
    final time = TextEditingController(text: existing?['time']?.toString());
    final activity =
        TextEditingController(text: existing?['activity']?.toString());
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
                      child: Text(existing == null ? 'Add' : 'Save'))
                ]));
    if (confirmed == true &&
        time.text.trim().isNotEmpty &&
        activity.text.trim().isNotEmpty) {
      if (existing != null) {
        await Db.removeAgendaItem(widget.eventId, existing);
      }
      await Db.addAgendaItem(
          widget.eventId, time.text.trim(), activity.text.trim());
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
      await Db.setFacility(widget.eventId, facility.key, note.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.eventTitle)),
        body: StreamBuilder(
          stream: Db.event(widget.eventId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data() ?? <String, dynamic>{};
            final status = data['status']?.toString() ?? 'draft';
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
              if (agenda.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('No agenda items yet. Add them only if needed.'),
                ),
              for (final item in agenda)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['activity'] ?? ''),
                    leading: SizedBox(
                        width: 62,
                        child: Text(item['time'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    trailing: Wrap(children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editAgenda(context, item)),
                      IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              Db.removeAgendaItem(widget.eventId, item)),
                    ]),
                    onTap: () => _editAgenda(context, item)),
              OutlinedButton.icon(
                  onPressed: () => _editAgenda(context, null),
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
                        : Db.removeFacility(widget.eventId, facility.key)),
              const SizedBox(height: 16),
              if (status == 'draft' || status == 'changes_requested')
                FilledButton.icon(
                    onPressed: () async {
                      await Db.publishEvent(widget.eventId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Published for admin review')));
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.publish_outlined),
                    label: const Text('Publish for Admin Review')),
              if (status == 'pending')
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.hourglass_top),
                  title: Text('Pending admin review'),
                  subtitle: Text(
                      'You can keep this draft data here while the authority officer reviews it.'),
                ),
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
