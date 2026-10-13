// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../services/db.dart';
// import '../theme/app_theme.dart';
// import '../widgets/admin_brand_bar.dart';
// import '../widgets/admin_design.dart';

// class ReviewChecklistScreen extends StatelessWidget {
//   const ReviewChecklistScreen({super.key});

//   Future<void> _editItem(BuildContext context,
//       {required String category, String? id, String? currentTitle}) async {
//     final controller = TextEditingController(text: currentTitle ?? '');
//     final saved = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(id == null ? 'Add checklist item' : 'Edit checklist item'),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           decoration: const InputDecoration(
//             labelText: 'Checklist item',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: const Text('Cancel')),
//           FilledButton(
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: const Text('Save')),
//         ],
//       ),
//     );
//     final title = controller.text.trim();
//     if (saved != true || title.isEmpty) return;
//     if (id == null) {
//       await Db.addReviewChecklistItem(title, category: category);
//     } else {
//       await Db.updateReviewChecklistItem(id, title, category: category);
//     }
//   }

//   Future<void> _deleteItem(BuildContext context, String id) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete checklist item?'),
//         content: const Text(
//             'This removes the item from the admin review checklist template.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: const Text('Cancel')),
//           FilledButton(
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: const Text('Delete')),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       await Db.deleteReviewChecklistItem(id);
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: const AdminBrandBar(title: 'Review Checklist'),
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: Db.reviewChecklistItems(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text('Could not load checklist: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final docs = snapshot.data!.docs;
//             return ListView(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
//               children: [
//                 const AdminPageIntro(
//                   eyebrow: 'Governance',
//                   title: 'Review standards',
//                   description:
//                       'Keep decisions consistent with clear, reusable review criteria.',
//                   icon: Icons.rule_outlined,
//                 ),
//                 const SizedBox(height: 16),
//                 _section(context, 'approval', 'Approve checklist', docs),
//                 _section(context, 'changes', 'Request changes checklist', docs),
//                 _section(context, 'rejection', 'Reject checklist', docs),
//               ],
//             );
//           },
//         ),
//       );

//   Widget _section(BuildContext context, String category, String title,
//       List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
//     final items = docs
//         .where((doc) =>
//             (doc.data()['category']?.toString() ?? 'approval') == category)
//         .toList();
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 12),
//       Row(children: [
//         Expanded(child: AdminSectionLabel(title: title)),
//         IconButton(
//             tooltip: 'Add checklist item',
//             onPressed: () => _editItem(context, category: category),
//             icon: const Icon(Icons.add_circle_outline)),
//       ]),
//       if (items.isEmpty)
//         const Card(
//             child: ListTile(
//                 leading: Icon(Icons.rule_folder_outlined),
//                 title: Text('No items in this section'))),
//       for (final doc in items)
//         Card(
//             child: ListTile(
//                 leading: const Icon(Icons.checklist_rtl),
//                 title: Text(doc.data()['title'] ?? 'Checklist item'),
//                 subtitle: Text(doc.data()['updatedAt'] == null
//                     ? 'Template item'
//                     : 'Updated'),
//                 trailing: Wrap(children: [
//                   IconButton(
//                       tooltip: 'Edit',
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: () => _editItem(context,
//                           category: category,
//                           id: doc.id,
//                           currentTitle: doc.data()['title']?.toString() ?? '')),
//                   IconButton(
//                       tooltip: 'Delete',
//                       icon: const Icon(Icons.delete_outline),
//                       onPressed: () => _deleteItem(context, doc.id)),
//                 ]))),
//     ]);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_brand_bar.dart';

class ReviewChecklistScreen extends StatelessWidget {
  const ReviewChecklistScreen({super.key});

  // ============================================================
  // ADD / EDIT CHECKLIST ITEM - ORIGINAL BACKEND
  // ============================================================

  Future<void> _editItem(
    BuildContext context, {
    required String category,
    String? id,
    String? currentTitle,
  }) async {
    final controller = TextEditingController(
      text: currentTitle ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                id == null
                    ? Icons.playlist_add_rounded
                    : Icons.edit_note_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                id == null
                    ? 'Add Checklist Item'
                    : 'Edit Checklist Item',
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REVIEW CRITERION',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Checklist item',
                  hintText: 'Enter a review requirement',
                  prefixIcon: const Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.fromLTRB(20, 0, 20, 17),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.check_rounded, size: 17),
            label: const Text('Save'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();

    // ORIGINAL VALIDATION AND DB CALLS
    if (saved != true || title.isEmpty) {
      return;
    }

    if (id == null) {
      await Db.addReviewChecklistItem(
        title,
        category: category,
      );
    } else {
      await Db.updateReviewChecklistItem(
        id,
        title,
        category: category,
      );
    }
  }

  // ============================================================
  // DELETE CHECKLIST ITEM - ORIGINAL BACKEND
  // ============================================================

  Future<void> _deleteItem(
    BuildContext context,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Delete checklist item?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        content: const Text(
          'This removes the item from the admin review checklist template.',
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
            ),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Db.deleteReviewChecklistItem(id);
    }
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // EXISTING ADMIN BRAND BAR
      appBar: const AdminBrandBar(
        title: 'Review Checklist',
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: Db.reviewChecklistItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ChecklistMessage(
              icon: Icons.error_outline_rounded,
              title: 'Could Not Load Checklist',
              message:
                  'Could not load checklist: ${snapshot.error}',
              color: AppColors.error,
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          final approvalCount = _countCategory(
            docs,
            'approval',
          );

          final changesCount = _countCategory(
            docs,
            'changes',
          );

          final rejectionCount = _countCategory(
            docs,
            'rejection',
          );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16, 20, 16, 96,
            ),
            children: [
              // PAGE INTRO
              const _ChecklistIntro(),

              const SizedBox(height: 20),

              // SUMMARY
              _ChecklistSummary(
                count: docs.length,
              ),

              const SizedBox(height: 16),

              // CATEGORY COUNTS
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Approval',
                      count: approvalCount,
                      icon:
                          Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: _MiniStatCard(
                      label: 'Changes',
                      count: changesCount,
                      icon: Icons.edit_note_rounded,
                      color: AppColors.info,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: _MiniStatCard(
                      label: 'Rejection',
                      count: rejectionCount,
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // APPROVAL CHECKLIST
              _section(
                context,
                'approval',
                'Approve Checklist',
                'Requirements before approving events',
                Icons.verified_outlined,
                AppColors.success,
                docs,
              ),

              const SizedBox(height: 24),

              // CHANGES CHECKLIST
              _section(
                context,
                'changes',
                'Request Changes Checklist',
                'Criteria for requesting corrections',
                Icons.edit_note_rounded,
                AppColors.info,
                docs,
              ),

              const SizedBox(height: 24),

              // REJECTION CHECKLIST
              _section(
                context,
                'rejection',
                'Reject Checklist',
                'Criteria for rejecting submissions',
                Icons.gpp_bad_outlined,
                AppColors.error,
                docs,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // COUNT ITEMS BY CATEGORY
  // ============================================================

  static int _countCategory(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String category,
  ) {
    return docs.where((doc) {
      return (doc.data()['category']?.toString() ??
              'approval') ==
          category;
    }).length;
  }

  // ============================================================
  // CHECKLIST CATEGORY SECTION
  // ============================================================

  Widget _section(
    BuildContext context,
    String category,
    String title,
    String subtitle,
    IconData icon,
    Color accent,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    // ORIGINAL CATEGORY FILTER
    final items = docs.where((doc) {
      return (doc.data()['category']?.toString() ??
              'approval') ==
          category;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION HEADER
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 21,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                  ),
                  const SizedBox(height: 4),
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

            // ==================================================
            // TOOLTIP FIX - CORRECT SECOND METHOD
            // ==================================================
            Tooltip(
              message: 'Add checklist item',
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => _editItem(
                    context,
                    category: category,
                  ),
                  child: const SizedBox(
                    width: 39,
                    height: 39,
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        // SECTION BODY
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 13,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // REQUIREMENTS HEADING
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'REVIEW REQUIREMENTS',
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),

                  Text(
                    '${items.length} '
                    '${items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (items.isEmpty)
                _EmptyChecklistSection(
                  accent: accent,
                )
              else
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      child: Divider(
                        color: AppColors.border,
                        height: 1,
                      ),
                    ),

                  _ChecklistItemCard(
                    title: items[i].data()['title']
                            ?.toString() ??
                        'Checklist item',
                    updated:
                        items[i].data()['updatedAt'] != null,
                    number: i + 1,
                    accent: accent,

                    // ORIGINAL UPDATE METHOD
                    onEdit: () => _editItem(
                      context,
                      category: category,
                      id: items[i].id,
                      currentTitle: items[i]
                              .data()['title']
                              ?.toString() ??
                          '',
                    ),

                    // ORIGINAL DELETE METHOD
                    onDelete: () => _deleteItem(
                      context,
                      items[i].id,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAGE INTRO
// ============================================================

class _ChecklistIntro extends StatelessWidget {
  const _ChecklistIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(width: 8),

            const Text(
              'ADMIN GOVERNANCE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Review ',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
              ),
              TextSpan(
                text: 'Standards',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Keep event decisions consistent with clear,\n'
          'reusable review criteria.',
          style: TextStyle(
            fontSize: 11,
            height: 1.65,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _ChecklistSummary extends StatelessWidget {
  final int count;

  const _ChecklistSummary({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primary,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHECKLIST MANAGEMENT',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$count Review '
                  '${count == 1 ? 'Criterion' : 'Criteria'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Maintain quality across submissions',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL CATEGORY STAT CARDS
// ============================================================

class _MiniStatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 105,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),

          const SizedBox(height: 7),

          Text(
            '$count',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHECKLIST ITEM CARD
// ============================================================

class _ChecklistItemCard extends StatelessWidget {
  final String title;
  final bool updated;
  final int number;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChecklistItemCard({
    required this.title,
    required this.updated,
    required this.number,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    updated
                        ? Icons.update_rounded
                        : Icons.description_outlined,
                    size: 13,
                    color: AppColors.secondaryText,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    updated
                        ? 'Updated'
                        : 'Template item',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        // PopupMenuButton supports tooltip directly.
        PopupMenuButton<String>(
          tooltip: 'Checklist item actions',
          color: AppColors.surface,
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.secondaryText,
            size: 21,
          ),
          onSelected: (action) {
            if (action == 'edit') {
              onEdit();
            } else if (action == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text('Edit Item'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text('Delete Item'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY CATEGORY STATE
// ============================================================

class _EmptyChecklistSection extends StatelessWidget {
  final Color accent;

  const _EmptyChecklistSection({
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rule_folder_outlined,
            size: 30,
            color: accent,
          ),

          const SizedBox(height: 9),

          const Text(
            'No items in this section',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Use the + button to add a review criterion.',
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
// ERROR STATE
// ============================================================

class _ChecklistMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ChecklistMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 43,
            ),

            const SizedBox(height: 13),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}