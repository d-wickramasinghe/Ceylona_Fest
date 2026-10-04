import 'package:flutter/material.dart';
import '../services/db.dart';

class EventDetailsScreen extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  const EventDetailsScreen({super.key, required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text(data['title'])),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(data['title'], style: Theme.of(context).textTheme.headlineSmall),
        const Align(alignment: Alignment.centerLeft, child: Chip(avatar: Icon(Icons.verified, size: 16), label: Text('Verified Organizer'))),
        ListTile(leading: const Icon(Icons.calendar_today), title: Text('${data['date']}  ${data['time'] ?? ''}')),
        ListTile(leading: const Icon(Icons.place), title: Text(data['location'] ?? '')),
        ListTile(leading: const Icon(Icons.payments), title: Text(data['price'] ?? 'Free')),
        Text(data['description'] ?? ''),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.bookmark_add),
          label: const Text('Save event'),
          onPressed: () async {
            await Db.saveEvent(id, data);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
          },
        ),
        const Divider(height: 32),
        const Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Add a comment'))),
          IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                Db.addComment(id, ctrl.text.trim());
                ctrl.clear();
              })
        ]),
        StreamBuilder(
          stream: Db.comments(id),
          builder: (c, s) {
            if (!s.hasData) return const SizedBox();
            return Column(children: [
              for (final d in s.data!.docs)
                ListTile(
                  title: Text(d['userName'] ?? ''),
                  subtitle: Text(d['text']),
                  trailing: d['userId'] == uid ? IconButton(icon: const Icon(Icons.delete), onPressed: () => Db.deleteComment(id, d.id)) : null,
                )
            ]);
          },
        ),
      ]),
    );
  }
}
