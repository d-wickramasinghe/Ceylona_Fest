import 'package:flutter/material.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import 'calendar_reminders_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Saved Events'), actions: [
          IconButton(
              tooltip: 'Calendar & reminders',
              icon: const Icon(Icons.calendar_month),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CalendarRemindersScreen())))
        ]),
        body: StreamBuilder(
          stream: Db.saved(),
          builder: (c, s) {
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.data!.docs.isEmpty) {
              return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bookmark_border, size: 48),
                SizedBox(height: 8),
                Text('No More Saved Events',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                    'Browse events and tap the bookmark icon to save them here')
              ]));
            }
            return ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [
                  Text('Upcoming Saved Events (${s.data!.docs.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final d in s.data!.docs)
                    Card(
                      child: ListTile(
                        title: Text(d['title']),
                        subtitle: Text('${d['date']} • ${d['location']}'),
                        onTap: () => Navigator.push(
                            c,
                            MaterialPageRoute(
                                builder: (_) => EventDetailsScreen(
                                    id: d.id, data: d.data()))),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => Db.unsaveEvent(d.id)),
                      ),
                    )
                ]);
          },
        ),
      );
}
