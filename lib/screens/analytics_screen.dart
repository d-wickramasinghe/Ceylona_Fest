import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/db.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Organizer Analytics')),
        body: StreamBuilder(
          stream: Db.myEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Could not load analytics: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final events = snapshot.data!.docs;
            final published = events
                .where((event) => event.data()['status'] == 'approved')
                .length;
            final pending = events
                .where((event) => event.data()['status'] == 'pending')
                .length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Performance overview',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Text('Track how your published events are performing',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _Metric(
                          label: 'Total events',
                          value: '${events.length}',
                          icon: Icons.event)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _Metric(
                          label: 'Published',
                          value: '$published',
                          icon: Icons.verified)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _Metric(
                          label: 'Pending review',
                          value: '$pending',
                          icon: Icons.hourglass_top)),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: _Metric(
                          label: 'Interested users',
                          value: '0',
                          icon: Icons.people)),
                ]),
                const SizedBox(height: 24),
                const Text('Registration Trend',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Last 7 days'),
                            Chip(
                                label: Text('+24%',
                                    style: TextStyle(color: AppColors.success))),
                          ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (final height in <double>[
                              42,
                              68,
                              52,
                              92,
                              74,
                              110,
                              84
                            ])
                              Container(
                                  width: 22,
                                  height: height,
                                  decoration: BoxDecoration(
                                      color: Colors.amber.shade600,
                                      borderRadius: BorderRadius.circular(5))),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Attendance Breakup',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Card(
                    child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: AppColors.success.withValues(alpha: .12),
                            child: const Icon(Icons.pie_chart_outline)),
                        title: const Text('Registrations enabled soon'),
                        subtitle: const Text(
                            'Attendance and attendee analytics will appear when registration data is available.'))),
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ]),
        ),
      );
}
