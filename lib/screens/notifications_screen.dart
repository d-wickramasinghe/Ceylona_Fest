import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/db.dart';
import '../widgets/seeker_page_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xfffbfaf7),
        body: Column(children: [
          const SeekerPageHeader(
              title: 'Your Alerts', subtitle: 'Updates from Ceylona'),
          Expanded(child: StreamBuilder(
          stream: Db.notifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Could not load notifications: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs.where((doc) {
              if (filter == 0) return true;
              final text =
                  '${doc.data()['title'] ?? ''} ${doc.data()['message'] ?? ''}'
                      .toLowerCase();
              return filter == 1
                  ? !text.contains('reminder')
                  : text.contains('reminder');
            }).toList();
            if (docs.isEmpty) {
              return const Center(child: Text('You are all caught up'));
            }
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('All')),
                        ButtonSegment(value: 1, label: Text('Updates')),
                        ButtonSegment(value: 2, label: Text('Reminders'))
                      ],
                      selected: {
                        filter
                      },
                      onSelectionChanged: (value) =>
                          setState(() => filter = value.first))),
              Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        return Card(
                            child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.warning.withValues(alpha: .16),
                                    child:
                                        const Icon(Icons.notifications_none)),
                                title: Text(data['title'] ?? 'Ceylona update',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text(data['message'] ?? ''),
                                trailing: data['read'] == true
                                    ? null
                                    : const Icon(Icons.fiber_manual_record,
                                        size: 12, color: AppColors.warning)));
                      })),
            ]);
          },
        )),
        ]),
      );
}
