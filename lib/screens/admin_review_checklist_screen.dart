import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';

class ReviewChecklistScreen extends StatelessWidget {
  const ReviewChecklistScreen({super.key});

  Future<void> _editItem(BuildContext context,
      {String? id, String? currentTitle}) async {
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
      await Db.addReviewChecklistItem(title);
    } else {
      await Db.updateReviewChecklistItem(id, title);
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          title: const Text('Review Checklist'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _editItem(context),
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
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
                if (docs.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.rule_folder_outlined),
                      title: Text('No checklist items yet'),
                      subtitle: Text('Add the first review requirement.'),
                    ),
                  ),
                for (final doc in docs)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.checklist_rtl),
                      title: Text(doc.data()['title'] ?? 'Checklist item'),
                      subtitle: Text(
                        doc.data()['updatedAt'] == null
                            ? 'Template item'
                            : 'Updated',
                      ),
                      trailing: Wrap(children: [
                        IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editItem(context,
                                id: doc.id,
                                currentTitle:
                                    doc.data()['title']?.toString() ?? '')),
                        IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteItem(context, doc.id)),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}
