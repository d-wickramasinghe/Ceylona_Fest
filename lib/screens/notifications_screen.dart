import 'package:flutter/material.dart';
import '../services/db.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: StreamBuilder(
          stream: Db.notifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Could not load notifications: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('You are all caught up'));
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data();
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.notifications)),
                  title: Text(data['title'] ?? 'Ceylona update'),
                  subtitle: Text(data['message'] ?? ''),
                  trailing: data['read'] == true ? null : const Icon(Icons.fiber_manual_record, size: 12),
                );
              },
            );
          },
        ),
      );
}
