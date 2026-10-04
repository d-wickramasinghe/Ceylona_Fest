import 'package:flutter/material.dart';
import '../services/db.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Event Approvals')),
        body: StreamBuilder(
          stream: Db.pendingEvents(),
          builder: (c, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            if (s.data!.docs.isEmpty) return const Center(child: Text('No pending events'));
            return ListView(children: [
              for (final d in s.data!.docs)
                Card(
                  child: ListTile(
                    title: Text(d['title']),
                    subtitle: Text('${d['date']} • ${d['location']}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => Db.setStatus(d.id, 'approved')),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => Db.setStatus(d.id, 'rejected')),
                    ]),
                  ),
                )
            ]);
          },
        ),
      );
}
