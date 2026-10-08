DateTime? parseEventDateTime(Map<String, dynamic> event) {
  final date = event['date']?.toString() ?? '';
  final time = event['time']?.toString().trim() ?? '';
  if (date.isEmpty) return null;

  final parsedDate = DateTime.tryParse(date);
  if (parsedDate == null) return null;
  if (time.isEmpty) return parsedDate;

  final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false).firstMatch(time);
  if (match == null) return parsedDate;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final meridiem = match.group(3)?.toUpperCase();
  if (meridiem == 'PM' && hour < 12) hour += 12;
  if (meridiem == 'AM' && hour == 12) hour = 0;
  return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
}