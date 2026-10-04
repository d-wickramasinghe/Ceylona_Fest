import 'package:flutter/material.dart';
import '../services/db.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Organizer Analytics')),
        body: StreamBuilder(
          stream: Db.myEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Could not load analytics: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final events = snapshot.data!.docs;
            final published = events.where((event) => event.data()['status'] == 'approved').length;
            final pending = events.where((event) => event.data()['status'] == 'pending').length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Performance overview', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _Metric(label: 'Total events', value: '${events.length}', icon: Icons.event)),
                  const SizedBox(width: 12),
                  Expanded(child: _Metric(label: 'Published', value: '$published', icon: Icons.verified)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Metric(label: 'Pending review', value: '$pending', icon: Icons.hourglass_top)),
                  const SizedBox(width: 12),
                  const Expanded(child: _Metric(label: 'Interested users', value: '0', icon: Icons.people)),
                ]),
                const SizedBox(height: 24),
                const Text('Registration and attendance analytics will appear as registrations are enabled.'),
              ],
            );
          },
        ),
      );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Metric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ]),
        ),
      );
}
