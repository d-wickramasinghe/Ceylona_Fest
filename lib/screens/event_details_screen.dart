import 'package:flutter/material.dart';
import '../services/db.dart';
import '../services/event_utils.dart';
import '../services/notifications.dart';
import 'calendar_reminders_screen.dart';
import 'map_directions_screen.dart';
import 'schedule_facilities_screen.dart';
import '../widgets/ceylona_bottom_navigation.dart';

class EventDetailsScreen extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  const EventDetailsScreen({super.key, required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
        title: Text(data['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (data['imageUrl']?.toString().trim().isNotEmpty == true)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(data['imageUrl'],
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        if (data['imageUrl']?.toString().trim().isNotEmpty == true)
          const SizedBox(height: 16),
        Text(data['title'], style: Theme.of(context).textTheme.headlineSmall),
        const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
                avatar: Icon(Icons.verified, size: 16),
                label: Text('Verified Organizer'))),
        ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('${data['date']}  ${data['time'] ?? ''}')),
        ListTile(
            leading: const Icon(Icons.place),
            title: Text(data['location'] ?? '')),
        if (data['transportInfo']?.toString().isNotEmpty == true)
          ListTile(
              leading: const Icon(Icons.directions_bus),
              title: Text(data['transportInfo'])),
        if (data['parkingInfo']?.toString().isNotEmpty == true)
          ListTile(
              leading: const Icon(Icons.local_parking),
              title: Text(data['parkingInfo'])),
        ListTile(
            leading: const Icon(Icons.payments),
            title: Text(data['price'] ?? 'Free')),
        Text(data['description'] ?? ''),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.bookmark_add),
          label: const Text('Save event'),
          onPressed: () async {
            await Db.saveEvent(id, data);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Saved')));
            }
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.map),
          label: const Text('View Map'),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MapDirectionsScreen(event: data))),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.alarm_add),
          label: const Text('Set Reminder'),
          onPressed: () => _setReminder(context),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.schedule),
          label: const Text('View Schedule & Facilities'),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ScheduleFacilitiesScreen(eventId: id))),
        ),
        const Divider(height: 32),
        const Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: ctrl,
                  decoration:
                      const InputDecoration(hintText: 'Add a comment'))),
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
                  trailing: d['userId'] == uid
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => Db.deleteComment(id, d.id))
                      : null,
                )
            ]);
          },
        ),
      ]),
      bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
    );
  }

  Future<void> _setReminder(BuildContext context) async {
    final eventTime = parseEventDateTime(data);
    if (eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add a valid event date and time first.')));
      return;
    }
    final choice = await showDialog<int>(
      context: context,
      builder: (dialogContext) =>
          SimpleDialog(title: const Text('Remind me'), children: [
        SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 1440),
            child: const Text('1 day before')),
        SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 60),
            child: const Text('1 hour before')),
        SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 0),
            child: const Text('At event time')),
      ]),
    );
    if (choice == null || !context.mounted) return;
    final reminderAt = eventTime.subtract(Duration(minutes: choice));
    await Db.saveEvent(id, data);
    await Db.saveReminder(id, choice, reminderAt);
    await NotificationsService.instance.scheduleReminder(
        eventId: id,
        title: data['title'] ?? 'Your event is starting',
        reminderAt: reminderAt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reminder saved')));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CalendarRemindersScreen(
                  eventId: id,
                  eventData: data,
                )));
  }
}
