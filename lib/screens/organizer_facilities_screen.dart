import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db.dart';

class OrganizerFacilitiesScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerFacilitiesScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrganizerFacilitiesScreen> createState() =>
      _OrganizerFacilitiesScreenState();
}

class _OrganizerFacilitiesScreenState extends State<OrganizerFacilitiesScreen> {
  Future<void> _editFacility(
      _FacilityDefinition facility, String? current) async {
    final note = TextEditingController(text: current);
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(facility.title),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Facility details',
            hintText: 'Add instructions, route, or availability',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (save == true && note.text.trim().isNotEmpty) {
      await Db.setFacility(widget.eventId, facility.key, note.text.trim());
    }
    note.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Facilities • ${widget.eventTitle}')),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: Db.event(widget.eventId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data() ?? <String, dynamic>{};
            final facilities =
                Map<String, dynamic>.from(data['facilities'] as Map? ?? {});
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                    'Facilities are independent event settings. Updating them does not send the event back for approval.'),
                const SizedBox(height: 16),
                for (final facility in _facilityDefinitions)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(facility.icon)),
                      title: Text(facility.title),
                      subtitle: Text(facilities[facility.key]?.toString() ??
                          'Not configured'),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: facilities.containsKey(facility.key)
                                ? 'Edit facility'
                                : 'Add facility',
                            icon: Icon(facilities.containsKey(facility.key)
                                ? Icons.edit
                                : Icons.add),
                            onPressed: () => _editFacility(
                                facility, facilities[facility.key]?.toString()),
                          ),
                          if (facilities.containsKey(facility.key))
                            IconButton(
                              tooltip: 'Delete facility',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => Db.removeFacility(
                                  widget.eventId, facility.key),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
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
