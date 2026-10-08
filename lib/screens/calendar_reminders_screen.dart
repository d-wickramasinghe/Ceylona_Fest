import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/db.dart';
import '../services/event_utils.dart';
import '../services/notifications.dart';
import '../widgets/ceylona_bottom_navigation.dart';

class CalendarRemindersScreen extends StatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? eventData;

  const CalendarRemindersScreen({super.key, this.eventId, this.eventData});
  @override
  State<CalendarRemindersScreen> createState() =>
      _CalendarRemindersScreenState();
}

class _CalendarRemindersScreenState extends State<CalendarRemindersScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final eventDate =
        widget.eventData == null ? null : parseEventDateTime(widget.eventData!);
    if (eventDate != null) {
      selectedDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      focusedDay = selectedDay;
    }
  }

  Future<void> _updateReminder(
      String eventId, Map<String, dynamic> event, int minutesBefore) async {
    final eventTime = parseEventDateTime(event);
    if (eventTime == null) return;
    final reminderAt = eventTime.subtract(Duration(minutes: minutesBefore));
    await Db.saveReminder(eventId, minutesBefore, reminderAt);
    await NotificationsService.instance.scheduleReminder(
        eventId: eventId,
        title: event['title'] ?? 'Your event is starting',
        reminderAt: reminderAt);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reminder updated')));
    }
  }

  Future<void> _addToCalendar(Map<String, dynamic> event) async {
    final eventTime = parseEventDateTime(event);
    if (eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This event has no valid date and time.')));
      return;
    }
    final endTime = eventTime.add(const Duration(hours: 1));
    final title =
        Uri.encodeComponent(event['title']?.toString() ?? 'Ceylona event');
    final details = Uri.encodeComponent(event['description']?.toString() ?? '');
    final location = Uri.encodeComponent(event['location']?.toString() ?? '');
    final uri = Uri.parse(
        'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=${_calendarDate(eventTime)}/${_calendarDate(endTime)}&details=$details&location=$location');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _calendarDate(DateTime value) =>
      '${value.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
          title: const Text('Calendar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 2),
        body: StreamBuilder(
          stream: Db.saved(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final events = snapshot.data!.docs
                .map((doc) => {...doc.data(), '_id': doc.id})
                .toList();
            final byDay = <DateTime, List<Map<String, dynamic>>>{};
            for (final event in events) {
              final date = parseEventDateTime(event);
              if (date != null) {
                byDay[DateTime(date.year, date.month, date.day)] = [
                  ...(byDay[DateTime(date.year, date.month, date.day)] ?? []),
                  event
                ];
              }
            }
            final selected = byDay[DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day)] ??
                [];
            return ListView(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xffd9dde5)),
                        borderRadius: BorderRadius.circular(8)),
                    child: TableCalendar<Map<String, dynamic>>(
                      firstDay: DateTime.utc(2020),
                      lastDay: DateTime.utc(2035),
                      focusedDay: focusedDay,
                      headerStyle: const HeaderStyle(
                          titleTextStyle: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                          formatButtonVisible: false,
                          titleCentered: false,
                          leftChevronIcon: Icon(Icons.chevron_left, size: 17),
                          rightChevronIcon:
                              Icon(Icons.chevron_right, size: 17)),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle:
                              TextStyle(fontSize: 8, color: Color(0xff667085)),
                          weekendStyle:
                              TextStyle(fontSize: 8, color: Color(0xff667085))),
                      calendarStyle: const CalendarStyle(
                          cellMargin: EdgeInsets.all(2),
                          defaultTextStyle: TextStyle(fontSize: 9),
                          weekendTextStyle: TextStyle(fontSize: 9),
                          outsideTextStyle:
                              TextStyle(fontSize: 9, color: Color(0xffb5bac5)),
                          selectedDecoration: BoxDecoration(
                              color: Color(0xff111827), shape: BoxShape.circle),
                          selectedTextStyle:
                              TextStyle(color: Colors.white, fontSize: 9),
                          markerDecoration: BoxDecoration(
                              color: Color(0xff19a974), shape: BoxShape.circle),
                          markerSize: 4),
                      selectedDayPredicate: (day) =>
                          isSameDay(day, selectedDay),
                      eventLoader: (day) =>
                          byDay[DateTime(day.year, day.month, day.day)] ?? [],
                      onDaySelected: (day, focused) => setState(() {
                        selectedDay = day;
                        focusedDay = focused;
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Events on this Day',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (selected.isEmpty) const _EmptyEventCard(),
                  for (final event in selected) _EventCard(event: event),
                  const SizedBox(height: 10),
                  _ReminderCard(
                      event: selected.isEmpty ? null : selected.first,
                      onChanged: selected.isEmpty
                          ? null
                          : (minutesBefore) => _updateReminder(
                              selected.first['_id'] as String,
                              selected.first,
                              minutesBefore)),
                  const SizedBox(height: 10),
                  SizedBox(
                      height: 44,
                      child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xff111827),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6))),
                          onPressed: selected.isEmpty
                              ? null
                              : () => _addToCalendar(selected.first),
                          child: const Text('Add to Calendar',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)))),
                ]);
          },
        ),
      );
}

class _EmptyEventCard extends StatelessWidget {
  const _EmptyEventCard();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd9dde5)),
          borderRadius: BorderRadius.circular(8)),
      child: const Text('No saved events on this date.',
          style: TextStyle(fontSize: 10, color: Color(0xff667085))));
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});
  @override
  Widget build(BuildContext context) {
    final date = parseEventDateTime(event);
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffd9dde5)),
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xffe9edf3),
                  borderRadius: BorderRadius.circular(5)),
              child: const Icon(Icons.image_outlined,
                  size: 17, color: Color(0xff667085))),
          const SizedBox(width: 9),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(event['title'] ?? 'Event',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(event['location'] ?? 'Location',
                    style:
                        const TextStyle(fontSize: 8, color: Color(0xff667085))),
                Text(
                    '${date?.day ?? ''} ${_month(date?.month)} ${date?.year ?? ''} • ${event['time'] ?? ''}',
                    style:
                        const TextStyle(fontSize: 8, color: Color(0xff667085)))
              ]))
        ]));
  }

  String _month(int? month) => month == null
      ? ''
      : const [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ][month - 1];
}

class _ReminderCard extends StatefulWidget {
  final Map<String, dynamic>? event;
  final Future<void> Function(int minutesBefore)? onChanged;
  const _ReminderCard({required this.event, required this.onChanged});

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard> {
  int? selectedMinutes;

  @override
  void didUpdateWidget(covariant _ReminderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event?['_id'] != widget.event?['_id']) {
      selectedMinutes = null;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd9dde5)),
          borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reminder Settings',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffd9dde5)),
                borderRadius: BorderRadius.circular(5)),
            child: Row(children: [
              const Icon(Icons.schedule, size: 13, color: Color(0xff667085)),
              const SizedBox(width: 6),
              Expanded(
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedMinutes ??
                              widget.event?['reminderMinutesBefore'] as int?,
                          hint: const Text('Select reminder',
                              style: TextStyle(
                                  fontSize: 9, color: Color(0xff667085))),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xff667085)),
                          items: const [
                            DropdownMenuItem(
                                value: 1440, child: Text('1 day before')),
                            DropdownMenuItem(
                                value: 60, child: Text('1 hour before')),
                            DropdownMenuItem(
                                value: 0, child: Text('At event time')),
                          ],
                          onChanged: widget.onChanged == null
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => selectedMinutes = value);
                                  widget.onChanged!(value);
                                }))),
            ])),
        const SizedBox(height: 7),
        if (widget.event?['reminderMinutesBefore'] != null)
          const Text('Reminder set for this event',
              style: TextStyle(fontSize: 8, color: Color(0xff19a974)))
      ]));
}
