// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../services/db.dart';
// import '../services/event_utils.dart';
// import '../services/notifications.dart';
// import '../widgets/ceylona_bottom_navigation.dart';
// import '../widgets/event_image.dart';
// import '../widgets/seeker_page_header.dart';

// class CalendarRemindersScreen extends StatefulWidget {
//   final String? eventId;
//   final Map<String, dynamic>? eventData;

//   const CalendarRemindersScreen({super.key, this.eventId, this.eventData});
//   @override
//   State<CalendarRemindersScreen> createState() =>
//       _CalendarRemindersScreenState();
// }

// class _CalendarRemindersScreenState extends State<CalendarRemindersScreen> {
//   DateTime selectedDay = DateTime.now();
//   DateTime focusedDay = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     final eventDate =
//         widget.eventData == null ? null : parseEventDateTime(widget.eventData!);
//     if (eventDate != null) {
//       selectedDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
//       focusedDay = selectedDay;
//     }
//   }

//   Future<void> _saveReminder(
//       Map<String, dynamic> event, DateTime reminderAt) async {
//     final eventId = event['_id'] as String;
//     await Db.setReminder(
//         eventId, event['title']?.toString() ?? 'Event', reminderAt);
//     await NotificationsService.instance.scheduleReminder(
//         eventId: eventId,
//         title: event['title'] ?? 'Your event is starting',
//         reminderAt: reminderAt);
//     if (mounted) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Reminder saved')));
//     }
//   }

//   Future<void> _removeReminder(String eventId) async {
//     await NotificationsService.instance.cancelReminder(eventId);
//     await Db.removeReminder(eventId);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reminder removed')),
//       );
//     }
//   }

//   Future<void> _openReminderSheet(
//       Map<String, dynamic> event, DocumentSnapshot<Map<String, dynamic>>? doc) async {
//     final existingTime = doc != null && doc.exists
//       ? _reminderTime(doc.data())
//       : null;
//     final action = await showModalBottomSheet<String>(
//       context: context,
//       builder: (sheetContext) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Text(event['title']?.toString() ?? 'Event',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             if (existingTime != null) ...[
//               const SizedBox(height: 8),
//               Text('Current reminder: ${_formatTime(existingTime)}'),
//             ],
//             const SizedBox(height: 16),
//             FilledButton.icon(
//               onPressed: () => Navigator.pop(sheetContext, 'edit'),
//               icon: Icon(existingTime == null ? Icons.add_alert : Icons.edit),
//               label: Text(existingTime == null ? 'Set Reminder' : 'Edit Reminder'),
//             ),
//             if (existingTime != null)
//               TextButton.icon(
//                 onPressed: () => Navigator.pop(sheetContext, 'delete'),
//                 icon: const Icon(Icons.delete_outline),
//                 label: const Text('Remove Reminder'),
//               ),
//           ]),
//         ),
//       ),
//     );
//     if (!mounted || action == null) return;
//     if (action == 'delete') {
//       await _removeReminder(event['_id'] as String);
//       return;
//     }
//     final now = DateTime.now();
//     final initialDate = existingTime != null && existingTime.isBefore(now)
//         ? now
//         : existingTime ?? parseEventDateTime(event) ?? now;
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: now,
//       lastDate: DateTime(2035),
//     );
//     if (!mounted || pickedDate == null) return;
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: existingTime == null
//           ? TimeOfDay.fromDateTime(parseEventDateTime(event) ?? DateTime.now())
//           : TimeOfDay.fromDateTime(existingTime),
//     );
//     if (pickedTime == null) return;
//     await _saveReminder(
//         event,
//         DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
//             pickedTime.hour, pickedTime.minute));
//   }

//   Future<void> _showReminderDetails(
//       Map<String, dynamic> reminder, Map<String, dynamic>? event) async {
//     final reminderTime = _reminderTime(reminder);
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(event?['title'] ?? reminder['eventTitle'] ?? 'Event'),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           if (event?['location'] != null)
//             ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.place_outlined),
//                 title: Text(event!['location'].toString())),
//           if (event?['date'] != null)
//             ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.event_outlined),
//                 title: Text('${event!['date']} ${event['time'] ?? ''}')),
//           if (reminderTime != null)
//             ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.notifications_active_outlined),
//                 title: Text('Reminder: ${_formatTime(reminderTime)}')),
//           if (event?['description'] != null)
//             Text(event!['description'].toString()),
//         ]),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Close')),
//         ],
//       ),
//     );
//   }

//   static DateTime? _reminderTime(Map<String, dynamic>? data) {
//     final value = data?['time'];
//     if (value is Timestamp) return value.toDate();
//     return value is DateTime ? value : null;
//   }

//   static String _formatTime(DateTime value) =>
//       '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

//   Future<void> _addToCalendar(Map<String, dynamic> event) async {
//     final eventTime = parseEventDateTime(event);
//     if (eventTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('This event has no valid date and time.')));
//       return;
//     }
//     final endTime = eventTime.add(const Duration(hours: 1));
//     final title =
//         Uri.encodeComponent(event['title']?.toString() ?? 'Ceylona event');
//     final details = Uri.encodeComponent(event['description']?.toString() ?? '');
//     final location = Uri.encodeComponent(event['location']?.toString() ?? '');
//     final uri = Uri.parse(
//         'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=${_calendarDate(eventTime)}/${_calendarDate(endTime)}&details=$details&location=$location');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   String _calendarDate(DateTime value) =>
//       '${value.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 2),
//         backgroundColor: const Color(0xfffbfaf7),
//         body: Column(children: [
//           SeekerPageHeader(
//               title: 'My Calendar',
//               subtitle: 'Events and reminders in one place',
//               onBack: () => Navigator.pop(context)),
//           Expanded(child: StreamBuilder(
//           stream: Db.saved(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final events = snapshot.data!.docs
//                 .map((doc) => {...doc.data(), '_id': doc.id})
//                 .toList();
//             final byDay = <DateTime, List<Map<String, dynamic>>>{};
//             for (final event in events) {
//               final date = parseEventDateTime(event);
//               if (date != null) {
//                 byDay[DateTime(date.year, date.month, date.day)] = [
//                   ...(byDay[DateTime(date.year, date.month, date.day)] ?? []),
//                   event
//                 ];
//               }
//             }
//             final selected = byDay[DateTime(
//                     selectedDay.year, selectedDay.month, selectedDay.day)] ??
//                 [];
//             return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: Db.allReminders(),
//               builder: (context, reminderSnapshot) {
//                 if (!reminderSnapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final reminderDocs = reminderSnapshot.data!.docs;
//                 final remindersById = {
//                   for (final doc in reminderDocs) doc.id: doc,
//                 };
//                 return ListView(
//                 padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.only(top: 4),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: const Color(0xffd9dde5)),
//                         borderRadius: BorderRadius.circular(8)),
//                     child: TableCalendar<Map<String, dynamic>>(
//                       firstDay: DateTime.utc(2020),
//                       lastDay: DateTime.utc(2035),
//                       focusedDay: focusedDay,
//                       headerStyle: const HeaderStyle(
//                           titleTextStyle: TextStyle(
//                               fontSize: 11, fontWeight: FontWeight.w700),
//                           formatButtonVisible: false,
//                           titleCentered: false,
//                           leftChevronIcon: Icon(Icons.chevron_left, size: 17),
//                           rightChevronIcon:
//                               Icon(Icons.chevron_right, size: 17)),
//                       daysOfWeekStyle: const DaysOfWeekStyle(
//                           weekdayStyle:
//                               TextStyle(fontSize: 8, color: Color(0xff667085)),
//                           weekendStyle:
//                               TextStyle(fontSize: 8, color: Color(0xff667085))),
//                       calendarStyle: const CalendarStyle(
//                           cellMargin: EdgeInsets.all(2),
//                           defaultTextStyle: TextStyle(fontSize: 9),
//                           weekendTextStyle: TextStyle(fontSize: 9),
//                           outsideTextStyle:
//                               TextStyle(fontSize: 9, color: Color(0xffb5bac5)),
//                           selectedDecoration: BoxDecoration(
//                               color: Color(0xff111827), shape: BoxShape.circle),
//                           selectedTextStyle:
//                               TextStyle(color: Colors.white, fontSize: 9),
//                           markerDecoration: BoxDecoration(
//                               color: Color(0xff19a974), shape: BoxShape.circle),
//                           markerSize: 4),
//                       selectedDayPredicate: (day) =>
//                           isSameDay(day, selectedDay),
//                       eventLoader: (day) =>
//                           byDay[DateTime(day.year, day.month, day.day)] ?? [],
//                       onDaySelected: (day, focused) => setState(() {
//                         selectedDay = day;
//                         focusedDay = focused;
//                       }),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   const Text('Events on this Day',
//                       style:
//                           TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 8),
//                   if (selected.isEmpty) const _EmptyEventCard(),
//                   for (final event in selected)
//                     _EventCard(
//                       event: event,
//                       onReminder: () => _openReminderSheet(
//                           event, remindersById[event['_id'] as String]),
//                     ),
//                   const SizedBox(height: 14),
//                   const Text('My Reminders',
//                       style:
//                           TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 8),
//                   if (reminderDocs.isEmpty)
//                     const _EmptyReminderCard()
//                   else
//                     for (final reminder in reminderDocs)
//                       _ReminderSummaryCard(
//                         reminder: reminder.data(),
//                         event: events.cast<Map<String, dynamic>?>().firstWhere(
//                             (event) => event?['_id'] == reminder.id,
//                             orElse: () => null),
//                         onEdit: events.any((event) => event['_id'] == reminder.id)
//                           ? () => _openReminderSheet(
//                             events.firstWhere(
//                               (event) => event['_id'] == reminder.id),
//                             reminder)
//                           : null,
//                         onOpenDetails: () => _showReminderDetails(
//                             reminder.data(),
//                             events.cast<Map<String, dynamic>?>().firstWhere(
//                                 (event) => event?['_id'] == reminder.id,
//                                 orElse: () => null)),
//                         onRemove: () => _removeReminder(reminder.id),
//                       ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                       height: 44,
//                       child: FilledButton(
//                           style: FilledButton.styleFrom(
//                               backgroundColor: const Color(0xff111827),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6))),
//                           onPressed: selected.isEmpty
//                               ? null
//                               : () => _addToCalendar(selected.first),
//                           child: const Text('Add to Calendar',
//                               style: TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.w700)))),
//                 ]);
//               },
//             );
//           },
//         )),
//         ]),
//       );
// }

// class _EmptyEventCard extends StatelessWidget {
//   const _EmptyEventCard();
//   @override
//   Widget build(BuildContext context) => Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xffd9dde5)),
//           borderRadius: BorderRadius.circular(8)),
//       child: const Text('No saved events on this date.',
//           style: TextStyle(fontSize: 10, color: Color(0xff667085))));
// }

// class _EventCard extends StatelessWidget {
//   final Map<String, dynamic> event;
//   final VoidCallback onReminder;
//   const _EventCard({required this.event, required this.onReminder});

//   @override
//   Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//     stream: Db.reminderForEvent(event['_id'] as String),
//     builder: (context, snapshot) {
//       final reminder = snapshot.data;
//         final reminderTime = reminder != null && reminder.exists
//           ? _reminderDate(reminder.data()?['time'])
//         : null;
//       final date = parseEventDateTime(event);
//       return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: const Color(0xffd9dde5)),
//         borderRadius: BorderRadius.circular(8)),
//       child: Row(children: [
//           EventImage(
//             url: event['imageUrl']?.toString(),
//             width: 42,
//             height: 42,
//             borderRadius:
//               const BorderRadius.all(Radius.circular(5))),
//         const SizedBox(width: 9),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//           Text(event['title'] ?? 'Event',
//             style: const TextStyle(
//               fontSize: 10, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 3),
//           Text(event['location'] ?? 'Location',
//             style: const TextStyle(
//               fontSize: 8, color: Color(0xff667085))),
//           Text(
//             '${date?.day ?? ''} ${_month(date?.month)} ${date?.year ?? ''} • ${event['time'] ?? ''}',
//             style: const TextStyle(
//               fontSize: 8, color: Color(0xff667085))),
//           if (reminderTime != null)
//             Text('Reminder: ${_formatTime(reminderTime)}',
//               style: const TextStyle(
//                 fontSize: 8, color: Color(0xff19a974))),
//           ])),
//         IconButton(
//           tooltip: reminderTime == null
//             ? 'Set reminder'
//             : 'Edit reminder',
//           icon: Icon(
//             reminderTime == null
//               ? Icons.notifications_none
//               : Icons.notifications_active,
//             color: reminderTime == null
//               ? const Color(0xff667085)
//               : const Color(0xff19a974)),
//           onPressed: onReminder),
//       ]),
//       );
//     },
//     );

//   static DateTime? _reminderDate(dynamic value) {
//   if (value is Timestamp) return value.toDate();
//   return value is DateTime ? value : null;
//   }

//   static String _formatTime(DateTime value) =>
//     '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

//   static String _month(int? month) => month == null
//     ? ''
//     : const [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ][month - 1];
// }

// class _EmptyReminderCard extends StatelessWidget {
//   const _EmptyReminderCard();
//   @override
//   Widget build(BuildContext context) => Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xffd9dde5)),
//           borderRadius: BorderRadius.circular(8)),
//       child: const Text('No reminders set yet.',
//           style: TextStyle(fontSize: 10, color: Color(0xff667085))));
// }

// class _ReminderSummaryCard extends StatelessWidget {
//   final Map<String, dynamic> reminder;
//   final Map<String, dynamic>? event;
//   final VoidCallback? onEdit;
//   final VoidCallback onOpenDetails;
//   final VoidCallback onRemove;
//   const _ReminderSummaryCard(
//       {required this.reminder,
//       required this.event,
//       required this.onEdit,
//       required this.onOpenDetails,
//       required this.onRemove});

//   @override
//   Widget build(BuildContext context) {
//     final reminderAt = _reminderDate(reminder['time']);
//     return InkWell(
//       onTap: onOpenDetails,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xffd9dde5)),
//           borderRadius: BorderRadius.circular(8)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           const Icon(Icons.notifications_active_outlined,
//               size: 16, color: Color(0xff19a974)),
//           const SizedBox(width: 8),
//           Expanded(
//                 child: Text(event?['title'] ?? reminder['eventTitle'] ?? 'Event',
//                   style: const TextStyle(
//                       fontSize: 11, fontWeight: FontWeight.w700))),
//               IconButton(
//                 tooltip: 'Edit reminder',
//                 icon: const Icon(Icons.edit_outlined, size: 18),
//                 onPressed: onEdit),
//           IconButton(
//               tooltip: 'Remove reminder',
//               icon: const Icon(Icons.delete_outline, size: 18),
//               onPressed: onRemove),
//         ]),
//         if (reminderAt != null)
//           Padding(
//             padding: const EdgeInsets.only(left: 24, bottom: 8),
//             child: Text(
//               'Reminder: ${reminderAt.year}-${_two(reminderAt.month)}-${_two(reminderAt.day)} ${_two(reminderAt.hour)}:${_two(reminderAt.minute)}',
//               style: const TextStyle(fontSize: 9, color: Color(0xff667085)),
//             ),
//           ),
//       ]),
//       ),
//     );
//   }

//   static DateTime? _reminderDate(dynamic value) {
//     if (value is Timestamp) return value.toDate();
//     if (value is DateTime) return value;
//     return null;
//   }

//   static String _two(int value) => value.toString().padLeft(2, '0');
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';
import '../services/event_utils.dart';
import '../services/notifications.dart';
import '../widgets/ceylona_bottom_navigation.dart';
import '../widgets/event_image.dart';

class CalendarRemindersScreen extends StatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? eventData;

  const CalendarRemindersScreen({
    super.key,
    this.eventId,
    this.eventData,
  });

  @override
  State<CalendarRemindersScreen> createState() =>
      _CalendarRemindersScreenState();
}

class _CalendarRemindersScreenState
    extends State<CalendarRemindersScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    final eventDate = widget.eventData == null
        ? null
        : parseEventDateTime(widget.eventData!);

    if (eventDate != null) {
      selectedDay = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
      );
      focusedDay = selectedDay;
    }
  }

  // ============================================================
  // ORIGINAL BACKEND - SAVE REMINDER
  // ============================================================

  Future<void> _saveReminder(
    Map<String, dynamic> event,
    DateTime reminderAt,
  ) async {
    final eventId = event['_id'] as String;

    await Db.setReminder(
      eventId,
      event['title']?.toString() ?? 'Event',
      reminderAt,
    );

    await NotificationsService.instance.scheduleReminder(
      eventId: eventId,
      title: event['title'] ?? 'Your event is starting',
      reminderAt: reminderAt,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder saved'),
        ),
      );
    }
  }

  // ============================================================
  // ORIGINAL BACKEND - REMOVE REMINDER
  // ============================================================

  Future<void> _removeReminder(String eventId) async {
    await NotificationsService.instance.cancelReminder(eventId);
    await Db.removeReminder(eventId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder removed'),
        ),
      );
    }
  }

  // ============================================================
  // REMINDER BOTTOM SHEET
  // ============================================================

  Future<void> _openReminderSheet(
    Map<String, dynamic> event,
    DocumentSnapshot<Map<String, dynamic>>? doc,
  ) async {
    final existingTime =
        doc != null && doc.exists ? _reminderTime(doc.data()) : null;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                event['title']?.toString() ?? 'Event',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
              ),

              if (existingTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Current reminder: ${_formatTime(existingTime)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.pop(sheetContext, 'edit'),
                  icon: Icon(
                    existingTime == null
                        ? Icons.add_alert_rounded
                        : Icons.edit_calendar_rounded,
                    size: 19,
                  ),
                  label: Text(
                    existingTime == null
                        ? 'Set Reminder'
                        : 'Edit Reminder',
                  ),
                ),
              ),

              if (existingTime != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pop(sheetContext, 'delete'),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Remove Reminder',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'delete') {
      await _removeReminder(event['_id'] as String);
      return;
    }

    // ORIGINAL DATE AND TIME PICKING LOGIC
    final now = DateTime.now();

    final initialDate =
        existingTime != null && existingTime.isBefore(now)
            ? now
            : existingTime ?? parseEventDateTime(event) ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2035),
    );

    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: existingTime == null
          ? TimeOfDay.fromDateTime(
              parseEventDateTime(event) ?? DateTime.now(),
            )
          : TimeOfDay.fromDateTime(existingTime),
    );

    if (pickedTime == null) return;

    await _saveReminder(
      event,
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  // ============================================================
  // REMINDER DETAILS DIALOG
  // ============================================================

  Future<void> _showReminderDetails(
    Map<String, dynamic> reminder,
    Map<String, dynamic>? event,
  ) async {
    final reminderTime = _reminderTime(reminder);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          event?['title'] ?? reminder['eventTitle'] ?? 'Event',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event?['location'] != null)
                _DetailDialogRow(
                  icon: Icons.location_on_outlined,
                  text: event!['location'].toString(),
                ),

              if (event?['date'] != null)
                _DetailDialogRow(
                  icon: Icons.calendar_month_outlined,
                  text:
                      '${event!['date']} ${event['time'] ?? ''}',
                ),

              if (reminderTime != null)
                _DetailDialogRow(
                  icon: Icons.notifications_active_outlined,
                  text:
                      'Reminder: ${_formatTime(reminderTime)}',
                ),

              if (event?['description'] != null) ...[
                const SizedBox(height: 10),
                Text(
                  event!['description'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static DateTime? _reminderTime(
    Map<String, dynamic>? data,
  ) {
    final value = data?['time'];

    if (value is Timestamp) return value.toDate();
    return value is DateTime ? value : null;
  }

  static String _formatTime(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  // ============================================================
  // ORIGINAL GOOGLE CALENDAR INTEGRATION
  // ============================================================

  Future<void> _addToCalendar(
    Map<String, dynamic> event,
  ) async {
    final eventTime = parseEventDateTime(event);

    if (eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This event has no valid date and time.',
          ),
        ),
      );
      return;
    }

    final endTime =
        eventTime.add(const Duration(hours: 1));

    final title = Uri.encodeComponent(
      event['title']?.toString() ?? 'Ceylona event',
    );

    final details = Uri.encodeComponent(
      event['description']?.toString() ?? '',
    );

    final location = Uri.encodeComponent(
      event['location']?.toString() ?? '',
    );

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=${_calendarDate(eventTime)}/${_calendarDate(endTime)}&details=$details&location=$location',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  String _calendarDate(DateTime value) =>
      '${value.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CeylonaBottomNavigation(selectedIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: StreamBuilder(
                stream: Db.saved(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final events = snapshot.data!.docs
                      .map(
                        (doc) => {
                          ...doc.data(),
                          '_id': doc.id,
                        },
                      )
                      .toList();

                  // ORIGINAL EVENT GROUPING
                  final byDay = <
                      DateTime,
                      List<Map<String, dynamic>>>{};

                  for (final event in events) {
                    final date = parseEventDateTime(event);

                    if (date != null) {
                      final key = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );

                      byDay[key] = [
                        ...(byDay[key] ?? []),
                        event,
                      ];
                    }
                  }

                  final selected = byDay[
                          DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          )] ??
                      [];

                  return StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: Db.allReminders(),
                    builder: (context, reminderSnapshot) {
                      if (!reminderSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      final reminderDocs =
                          reminderSnapshot.data!.docs;

                      final remindersById = {
                        for (final doc in reminderDocs)
                          doc.id: doc,
                      };

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          16, 20, 16, 26,
                        ),
                        children: [
                          // Calendar section title
                          _buildSectionHeading(
                            'Event Calendar',
                            'Select a date to explore your events',
                            Icons.calendar_month_rounded,
                          ),

                          const SizedBox(height: 15),

                          _buildCalendar(byDay),

                          const SizedBox(height: 25),

                          _buildSectionHeading(
                            'Events on This Day',
                            '${selected.length} saved events',
                            Icons.event_available_rounded,
                          ),

                          const SizedBox(height: 13),

                          if (selected.isEmpty)
                            const _EmptyEventCard(),

                          for (final event in selected)
                            _EventCard(
                              event: event,
                              onReminder: () =>
                                  _openReminderSheet(
                                event,
                                remindersById[
                                    event['_id'] as String],
                              ),
                            ),

                          const SizedBox(height: 25),

                          _buildSectionHeading(
                            'My Reminders',
                            '${reminderDocs.length} active reminders',
                            Icons.notifications_active_outlined,
                          ),

                          const SizedBox(height: 13),

                          if (reminderDocs.isEmpty)
                            const _EmptyReminderCard()
                          else
                            for (final reminder in reminderDocs)
                              _ReminderSummaryCard(
                                reminder: reminder.data(),
                                event: events
                                    .cast<Map<String, dynamic>?>()
                                    .firstWhere(
                                      (event) =>
                                          event?['_id'] ==
                                          reminder.id,
                                      orElse: () => null,
                                    ),
                                onEdit: events.any(
                                  (event) =>
                                      event['_id'] ==
                                      reminder.id,
                                )
                                    ? () => _openReminderSheet(
                                          events.firstWhere(
                                            (event) =>
                                                event['_id'] ==
                                                reminder.id,
                                          ),
                                          reminder,
                                        )
                                    : null,
                                onOpenDetails: () =>
                                    _showReminderDetails(
                                  reminder.data(),
                                  events
                                      .cast<
                                          Map<String, dynamic>?>()
                                      .firstWhere(
                                        (event) =>
                                            event?['_id'] ==
                                            reminder.id,
                                        orElse: () => null,
                                      ),
                                ),
                                onRemove: () =>
                                    _removeReminder(
                                  reminder.id,
                                ),
                              ),

                          const SizedBox(height: 17),

                          _buildAddCalendarButton(selected),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODERN HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        19, 17, 19, 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(23),
          bottomRight: Radius.circular(23),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.045,
            ),
            blurRadius: 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    height: 42,
                    width: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'MY PLANNER',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const SizedBox(width: 42),
            ],
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              Container(
                height: 3,
                width: 21,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'STAY ORGANIZED',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'My ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Calendar',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Your events and reminders, beautifully organized.\n'
            'Never miss a moment that matters.',
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MODERN CALENDAR
  // ============================================================

  Widget _buildCalendar(
    Map<DateTime, List<Map<String, dynamic>>> byDay,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035),
        focusedDay: focusedDay,

        calendarFormat: CalendarFormat.month,

        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },

        rowHeight: 47,
        daysOfWeekHeight: 24,

        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ) ??
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            size: 22,
            color: AppColors.primaryDark,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.primaryDark,
          ),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
          weekendStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),

        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(5),

          defaultTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryDark,
          ),

          weekendTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryDark,
          ),

          outsideTextStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),

          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),

          selectedTextStyle: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),

          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.15,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
            ),
          ),

          todayTextStyle: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),

          markerDecoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),

          markerSize: 5,
          markersMaxCount: 3,
        ),

        selectedDayPredicate: (day) =>
            isSameDay(day, selectedDay),

        eventLoader: (day) =>
            byDay[
              DateTime(day.year, day.month, day.day)
            ] ??
            [],

        onDaySelected: (day, focused) {
          setState(() {
            selectedDay = day;
            focusedDay = focused;
          });
        },

        onPageChanged: (focused) {
          focusedDay = focused;
        },
      ),
    );
  }

  // ============================================================
  // GOOGLE CALENDAR BUTTON
  // ============================================================

  Widget _buildAddCalendarButton(
    List<Map<String, dynamic>> selected,
  ) {
    return SizedBox(
      height: 49,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: selected.isEmpty
            ? null
            : () => _addToCalendar(selected.first),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(
          Icons.calendar_month_outlined,
          size: 19,
        ),
        label: const Text(
          'Add to Calendar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIALOG DETAIL ROW
// ============================================================

class _DetailDialogRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailDialogRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY EVENT CARD
// ============================================================

class _EmptyEventCard extends StatelessWidget {
  const _EmptyEventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 27,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 31,
            color: AppColors.primary,
          ),
          SizedBox(height: 9),
          Text(
            'No events for this day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'No saved events on this date.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVENT CARD
// ============================================================

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onReminder;

  const _EventCard({
    required this.event,
    required this.onReminder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: Db.reminderForEvent(event['_id'] as String),
      builder: (context, snapshot) {
        final reminder = snapshot.data;

        final reminderTime =
            reminder != null && reminder.exists
                ? _reminderDate(
                    reminder.data()?['time'],
                  )
                : null;

        final date = parseEventDateTime(event);

        return Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              EventImage(
                url: event['imageUrl']?.toString(),
                width: 72,
                height: 82,
                borderRadius: BorderRadius.circular(12),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? 'Event',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    const SizedBox(height: 7),

                    _smallInfo(
                      Icons.location_on_outlined,
                      event['location'] ?? 'Location',
                    ),

                    const SizedBox(height: 4),

                    _smallInfo(
                      Icons.calendar_month_rounded,
                      '${date?.day ?? ''} ${_month(date?.month)} ${date?.year ?? ''} • ${event['time'] ?? ''}',
                    ),

                    if (reminderTime != null) ...[
                      const SizedBox(height: 6),
                      _smallInfo(
                        Icons.notifications_active_rounded,
                        'Reminder: ${_formatTime(reminderTime)}',
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Material(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  onTap: onReminder,
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      reminderTime == null
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      size: 20,
                      color: reminderTime == null
                          ? AppColors.primary
                          : AppColors.success,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _smallInfo(
    IconData icon,
    String text, {
    Color color = AppColors.secondaryText,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: color == AppColors.success
              ? AppColors.success
              : AppColors.primary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  static DateTime? _reminderDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return value is DateTime ? value : null;
  }

  static String _formatTime(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  static String _month(int? month) => month == null
      ? ''
      : const [
          'Jan', 'Feb', 'Mar', 'Apr',
          'May', 'Jun', 'Jul', 'Aug',
          'Sep', 'Oct', 'Nov', 'Dec'
        ][month - 1];
}

// ============================================================
// EMPTY REMINDER CARD
// ============================================================

class _EmptyReminderCard extends StatelessWidget {
  const _EmptyReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 27,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 31,
            color: AppColors.primary,
          ),
          SizedBox(height: 9),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Set a reminder so you never miss an event.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REMINDER SUMMARY CARD
// ============================================================

class _ReminderSummaryCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final Map<String, dynamic>? event;
  final VoidCallback? onEdit;
  final VoidCallback onOpenDetails;
  final VoidCallback onRemove;

  const _ReminderSummaryCard({
    required this.reminder,
    required this.event,
    required this.onEdit,
    required this.onOpenDetails,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final reminderAt = _reminderDate(reminder['time']);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onOpenDetails,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event?['title'] ??
                            reminder['eventTitle'] ??
                            'Event',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                      ),

                      if (reminderAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Reminder: ${reminderAt.year}-${_two(reminderAt.month)}-${_two(reminderAt.day)} ${_two(reminderAt.hour)}:${_two(reminderAt.minute)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Reminder options',
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.secondaryText,
                  ),
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit?.call();
                    } else if (action == 'delete') {
                      onRemove();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10),
                            Text('Edit Reminder'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 10),
                          Text('Remove Reminder'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static DateTime? _reminderDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String _two(int value) =>
      value.toString().padLeft(2, '0');
}