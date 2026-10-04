import 'package:flutter/material.dart';
import '../services/db.dart';
import 'event_details_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Saved Events')),
        body: StreamBuilder(
          stream: Db.saved(),
          builder: (c, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            if (s.data!.docs.isEmpty) return const Center(child: Text('No saved events yet'));
            return ListView(children: [
              for (final d in s.data!.docs)
                Card(
                  child: ListTile(
                    title: Text(d['title']),
                    subtitle: Text('${d['date']} • ${d['location']}'),
                    onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => EventDetailsScreen(id: d.id, data: d.data()))),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => Db.unsaveEvent(d.id)),
                  ),
                )
            ]);
          },
        ),
      );
}
