import 'package:flutter/material.dart';
import '../services/db.dart';

enum OrganizerView { dashboard, events, create }

class OrganizerScreen extends StatelessWidget {
  final OrganizerView view;
  const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

  void form(BuildContext ctx, {String? id, Map<String, dynamic>? d}) {
    final t = TextEditingController(text: d?['title']),
        date = TextEditingController(text: d?['date']),
        time = TextEditingController(text: d?['time']),
        loc = TextEditingController(text: d?['location']),
        price = TextEditingController(text: d?['price']),
        desc = TextEditingController(text: d?['description']);
    String cat = d?['category'] ?? 'Music';
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(c).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(id == null ? 'Create Event' : 'Edit Event', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: t, decoration: const InputDecoration(labelText: 'Event name')),
              DropdownButtonFormField<String>(
                initialValue: cat,
                items: ['Music', 'Cultural', 'Food', 'Sports', 'University'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => set(() => cat = v!),
              ),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date (e.g. 2026-10-25)')),
              TextField(controller: time, decoration: const InputDecoration(labelText: 'Time (e.g. 9:00 AM)')),
              TextField(controller: loc, decoration: const InputDecoration(labelText: 'Venue / Location')),
              TextField(controller: price, decoration: const InputDecoration(labelText: 'Ticket price (or Free)')),
              TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final data = {'title': t.text, 'category': cat, 'date': date.text, 'time': time.text, 'location': loc.text, 'price': price.text.isEmpty ? 'Free' : price.text, 'description': desc.text};
                  id == null ? await Db.createEvent(data) : await Db.updateEvent(id, data);
                  if (c.mounted) Navigator.pop(c);
                },
                child: const Text('Submit for approval'),
              )
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (view == OrganizerView.create) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Event')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => form(context),
            icon: const Icon(Icons.add),
            label: const Text('Start a new event submission'),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(title: Text(view == OrganizerView.events ? 'My Events' : 'Organizer Dashboard')),
        floatingActionButton: FloatingActionButton.extended(onPressed: () => form(context), icon: const Icon(Icons.add), label: const Text('Create Event')),
        body: StreamBuilder(
          stream: Db.myEvents(),
          builder: (c, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            if (s.data!.docs.isEmpty) return const Center(child: Text('No events created yet'));
            return ListView(children: [
              for (final d in s.data!.docs)
                Card(
                  child: ListTile(
                    title: Text(d['title']),
                    subtitle: Text('${d['date']} • Status: ${d['status']}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => form(c, id: d.id, d: d.data())),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => Db.deleteEvent(d.id)),
                    ]),
                  ),
                )
            ]);
          },
        ),
      );
  }
}
