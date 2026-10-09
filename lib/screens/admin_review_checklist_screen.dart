import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_brand_bar.dart';

class ReviewChecklistScreen extends StatelessWidget {
  const ReviewChecklistScreen({super.key});

  Future<void> _editItem(BuildContext context,
      {required String category, String? id, String? currentTitle}) async {
    final controller = TextEditingController(text: currentTitle ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(id == null ? 'Add checklist item' : 'Edit checklist item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Checklist item',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save')),
        ],
      ),
    );
    final title = controller.text.trim();
    if (saved != true || title.isEmpty) return;
    if (id == null) {
      await Db.addReviewChecklistItem(title, category: category);
    } else {
      await Db.updateReviewChecklistItem(id, title, category: category);
    }
  }

  Future<void> _deleteItem(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete checklist item?'),
        content: const Text(
            'This removes the item from the admin review checklist template.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await Db.deleteReviewChecklistItem(id);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminBrandBar(title: 'Review Checklist'),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Db.reviewChecklistItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Could not load checklist: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                Text(
                  'Checklist items used by authority officers when deciding whether to approve, reject, or request changes.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 16),
                _section(context, 'approval', 'Approve checklist', docs),
                _section(context, 'changes', 'Request changes checklist', docs),
                _section(context, 'rejection', 'Reject checklist', docs),
              ],
            );
          },
        ),
      );

      Widget _section(BuildContext context, String category, String title,
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      final items = docs
        .where((doc) => (doc.data()['category']?.toString() ?? 'approval') == category)
        .toList();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        Row(children: [
        Expanded(
          child: Text(title,
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700))),
        IconButton(
          tooltip: 'Add checklist item',
          onPressed: () => _editItem(context, category: category),
          icon: const Icon(Icons.add_circle_outline)),
        ]),
        if (items.isEmpty)
        const Card(
          child: ListTile(
            leading: Icon(Icons.rule_folder_outlined),
            title: Text('No items in this section'))),
        for (final doc in items)
        Card(
          child: ListTile(
            leading: const Icon(Icons.checklist_rtl),
            title: Text(doc.data()['title'] ?? 'Checklist item'),
            subtitle: Text(
              doc.data()['updatedAt'] == null ? 'Template item' : 'Updated'),
            trailing: Wrap(children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editItem(context,
                  category: category,
                  id: doc.id,
                  currentTitle: doc.data()['title']?.toString() ?? '')),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteItem(context, doc.id)),
            ]))),
      ]);
      }
}
