import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db.dart';
import '../services/event_utils.dart';
import 'calendar_reminders_screen.dart';
import 'map_directions_screen.dart';
import 'schedule_facilities_screen.dart';
import 'event_gallery_screen.dart';
import '../widgets/ceylona_bottom_navigation.dart';
import '../widgets/event_image.dart';
import '../theme/app_theme.dart';

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
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
        Stack(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: EventImage(
                  url: data['imageUrl']?.toString(),
                  height: 220,
                  borderRadius: BorderRadius.circular(14))),
          Positioned(
              right: 10,
              bottom: 10,
              child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EventGalleryScreen(
                              eventId: id,
                              eventTitle: data['title']?.toString() ?? 'Event',
                              mode: GalleryMode.seeker))),
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('View Photo Gallery'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryDark))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Chip(
              label: Text(data['category']?.toString() ?? 'Event'),
              visualDensity: VisualDensity.compact),
          const SizedBox(width: 8),
          const Icon(Icons.verified, size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          const Text('Verified organizer', style: TextStyle(fontSize: 12)),
        ]),
        Text(data['title']?.toString() ?? 'Event',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
            color: const Color(0xfffff3c4),
            child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(children: [
                  const Icon(Icons.confirmation_number_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Ticket price',
                            style: TextStyle(fontSize: 11)),
                        Text(data['price']?.toString() ?? 'Free',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ])),
                  const Chip(
                      label: Text('Presale active'),
                      visualDensity: VisualDensity.compact),
                ]))),
        const SizedBox(height: 8),
        _EventInfoTile(
            icon: Icons.calendar_month_outlined,
            title: '${data['date'] ?? ''}',
            subtitle: data['time']?.toString() ?? ''),
        _EventInfoTile(
            icon: Icons.location_on_outlined,
            title: data['location']?.toString() ?? 'Location',
            subtitle: data['address']?.toString() ?? 'Sri Lanka'),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: _ActionButton(
                  icon: Icons.map_outlined,
                  label: 'View Map',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MapDirectionsScreen(event: data))))),
          const SizedBox(width: 8),
          Expanded(
              child: _ActionButton(
                  icon: Icons.alarm_add_outlined,
                  label: 'Set Reminder',
                  dark: true,
                  onPressed: () => _setReminder(context))),
          const SizedBox(width: 8),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: Db.saved(),
                builder: (context, snapshot) {
                final isSaved = snapshot.data?.docs
                    .any((doc) => doc.id == id) ??
                  false;
                return _ActionButton(
                  icon: isSaved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                  label: isSaved ? 'Saved' : 'Save',
                  onPressed: isSaved
                    ? null
                    : () async {
                      await Db.saveEvent(id, data);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event saved')));
                      }
                      });
                })),
        ]),
        const SizedBox(height: 22),
        const Text('About the Event',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(data['description']?.toString() ?? 'No description provided.',
            style: const TextStyle(height: 1.45)),
        if (data['transportInfo']?.toString().isNotEmpty == true) ...[
          const SizedBox(height: 18),
          const Text('Getting there',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(data['transportInfo'].toString()),
        ],
        if (data['parkingInfo']?.toString().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text('Parking: ${data['parkingInfo']}',
              style: const TextStyle(color: Colors.black54)),
        ],
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
    await Db.saveEvent(id, data);
    if (!context.mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CalendarRemindersScreen(
                  eventId: id,
                  eventData: data,
                )));
  }
}

class _EventInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EventInfoTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: .14),
              child: Icon(icon, color: AppColors.primaryDark, size: 19)),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onPressed,
      this.dark = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 15),
          label: Text(label, style: const TextStyle(fontSize: 10)),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              backgroundColor:
                  dark ? AppColors.primaryDark : AppColors.primary,
              foregroundColor: dark ? Colors.white : AppColors.primaryDark),
        ),
      );
}
