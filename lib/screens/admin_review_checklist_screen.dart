import 'package:flutter/material.dart';

const _checklistGold = Color(0xFFD4A017);
const _checklistCream = Color(0xFFFDF6EC);

class ReviewChecklistScreen extends StatefulWidget {
  const ReviewChecklistScreen({super.key});

  @override
  State<ReviewChecklistScreen> createState() => _ReviewChecklistScreenState();
}

class _ReviewChecklistScreenState extends State<ReviewChecklistScreen> {
  final _checks = <bool>[true, true, true, true, true, false];
  final _notesController = TextEditingController();

  static const _labels = [
    'Event information is complete',
    'Organizer and contact verified',
    'Date and venue are valid',
    'Description is clear and accurate',
    'Media meets quality requirements',
    'Policy compliance confirmed',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _checks.where((value) => value).length;
    return Scaffold(
      backgroundColor: _checklistCream,
      appBar: AppBar(
        backgroundColor: _checklistCream,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(),
        title: const Text('Review Checklist'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Verify every item before deciding on Colombo Cultural Festival.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Verification progress',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  '$completed/6',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: completed / _labels.length,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8DDCE),
                valueColor: const AlwaysStoppedAnimation<Color>(_checklistGold),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Required checks',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9DED0)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _labels.length; i++)
                    CheckboxListTile(
                      value: _checks[i],
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _checklistGold,
                      checkColor: Colors.black,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        _labels[i],
                        style: const TextStyle(fontSize: 14),
                      ),
                      onChanged: (value) =>
                          setState(() => _checks[i] = value ?? false),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Review notes',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              minLines: 5,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Add any notes for the decision...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9DED0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9DED0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
