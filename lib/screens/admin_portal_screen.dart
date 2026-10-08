import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/db.dart';
import '../theme/app_theme.dart';
import 'admin_review_checklist_screen.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});
  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardScreen(),
      AdminApprovalsScreen(),
      ReviewChecklistScreen(),
      AdminNotificationsScreen(),
      AdminProfileScreen(),
    ];
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.verified), label: 'Approvals'),
            NavigationDestination(
                icon: Icon(Icons.checklist), label: 'Checklist'),
            NavigationDestination(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Authority Dashboard')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Db.adminEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Could not load submissions: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            final pending = _count(docs, 'pending');
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                    'Welcome Back, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Officer'}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                    'You have $pending pending event submissions awaiting action.'),
                const SizedBox(height: 12),
                const TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search events or organizers',
                        border: OutlineInputBorder())),
                const SizedBox(height: 20),
                GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 132,
                    children: [
                      _StatCard(
                          label: 'Pending',
                          value: pending,
                          color: AppColors.warning),
                      _StatCard(
                          label: 'Approved',
                          value: _count(docs, 'approved'),
                          color: AppColors.success),
                      _StatCard(
                          label: 'Rejected',
                          value: _count(docs, 'rejected'),
                          color: AppColors.error),
                      _StatCard(
                          label: 'Total',
                          value: docs.length,
                          color: AppColors.info),
                    ]),
                const SizedBox(height: 24),
                Text('Recent activity',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (docs.isEmpty) const Text('No submissions yet.'),
                for (final doc in docs.take(5)) _ActivityTile(data: doc.data()),
              ],
            );
          },
        ),
      );

  static int _count(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
          String status) =>
      docs.where((doc) => doc.data()['status'] == status).length;
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.circle, color: color, size: 14),
            const Spacer(),
            Text('$value', style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ]),
        ),
      );
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityTile({required this.data});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.article_outlined),
        title: Text(data['title'] ?? 'Untitled event'),
        subtitle: Text(
            '${data['organizerName'] ?? 'Unknown organizer'} • ${data['status'] ?? 'pending'}'),
      );
}

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});
  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  String search = '';
  final searchController = TextEditingController();
  static const statuses = [
    'pending',
    'approved',
    'suspended',
    'rejected',
    'changes_requested'
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(
      QueryDocumentSnapshot<Map<String, dynamic>> doc, String action) async {
    if (action == 'view') {
      if (mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AdminSubmissionDetailsScreen(
                    id: doc.id, data: doc.data())));
      }
      return;
    }
    final reason = await _showModerationDialog(context, action);
    if (reason == null) return;
    try {
      await Db.transitionEvent(
          eventId: doc.id,
          status: action == 're-approved'
              ? 'approved'
              : action == 'revoked'
                  ? 'rejected'
                  : 'suspended',
          action: action,
          reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_actionLabel(action))));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Could not update event: ${error.message ?? error.code}')));
      }
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtered(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
          String status) =>
      docs.where((doc) {
        final data = doc.data();
        final text = '${data['title'] ?? ''} ${data['organizerName'] ?? ''}'
            .toLowerCase();
        return data['status'] == status && text.contains(search.toLowerCase());
      }).toList();

  Widget _eventList(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String status) {
    final filtered = _filtered(docs, status);
    if (filtered.isEmpty) {
      return Center(
          child: Text('No ${_statusLabel(status).toLowerCase()} events'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final doc = filtered[index];
        final data = doc.data();
        final actions = switch (status) {
          'approved' => const ['view', 'suspend', 'revoked'],
          'suspended' => const ['view', 're-approved', 'revoked'],
          _ => const ['view'],
        };
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            title: Text(data['title'] ?? 'Untitled event',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                    'by ${data['organizerName'] ?? 'Unknown organizer'}\n${data['date'] ?? ''} • ${data['location'] ?? ''}')),
            isThreeLine: true,
            leading: _StatusIcon(status: status),
            trailing: PopupMenuButton<String>(
              tooltip: 'Event actions',
              onSelected: (action) => _handleAction(doc, action),
              itemBuilder: (_) => [
                for (final action in actions)
                  PopupMenuItem(
                      value: action,
                      child: Text(action == 'view'
                          ? 'View details'
                          : _actionLabel(action))),
              ],
            ),
            onTap: () => _handleAction(doc, 'view'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: statuses.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Event Approvals'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Suspended'),
                Tab(text: 'Rejected'),
                Tab(text: 'Changes requested'),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: Db.adminEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Could not load approvals: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search events or organizers',
                        border: const OutlineInputBorder(),
                        suffixIcon: search.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => search = '');
                                })),
                    onChanged: (value) => setState(() => search = value),
                  ),
                ),
                Expanded(
                    child: TabBarView(children: [
                  for (final status in statuses)
                    _eventList(context, docs, status)
                ])),
              ]);
            },
          ),
        ),
      );
}

Future<String?> _showModerationDialog(BuildContext context, String action) {
  if (action == 're-approved') {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Re-approve this event?'),
        content: const Text(
            'The event will become publicly visible again and saved seekers will be notified.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, ''),
              child: const Text('Re-approve')),
        ],
      ),
    );
  }

  final note = TextEditingController();
  final categories = <String>{};
  const categoryLabels = [
    'Fraud reported',
    'Policy violation discovered',
    'Organizer misconduct',
    'Venue no longer valid',
    'Other'
  ];
  return showDialog<String>(
    context: context,
    builder: (dialogContext) =>
        StatefulBuilder(builder: (context, setDialogState) {
      final title = action == 'suspend' ? 'Suspend event' : 'Revoke approval';
      final button = action == 'suspend' ? 'Suspend event' : 'Revoke approval';
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(action == 'suspend'
                ? 'Why are you suspending this approved event?'
                : 'Why are you revoking this approval?'),
            const SizedBox(height: 12),
            const Text('Select all that apply',
                style: TextStyle(fontWeight: FontWeight.w600)),
            for (final category in categoryLabels)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: categories.contains(category),
                title: Text(category),
                onChanged: (value) => setDialogState(() => value == true
                    ? categories.add(category)
                    : categories.remove(category)),
              ),
            TextField(
                controller: note,
                maxLines: 3,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                    labelText: 'Reason (required)',
                    hintText: 'Add context for the organizer',
                    border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: categories.isEmpty && note.text.trim().isEmpty
                ? null
                : () {
                    final reason = [
                      ...categories,
                      if (note.text.trim().isNotEmpty) note.text.trim()
                    ].join('. ');
                    Navigator.pop(dialogContext, reason);
                  },
            child: Text(button),
          ),
        ],
      );
    }),
  );
}

String _actionLabel(String action) => switch (action) {
      'suspend' => 'Suspend event',
      'revoked' => 'Revoke approval',
      're-approved' => 'Re-approve',
      _ => 'View details',
    };

IconData _decisionIcon(String action) => switch (action) {
      'approved' || 're-approved' => Icons.check_circle,
      'suspended' => Icons.pause_circle,
      'rejected' || 'revoked' => Icons.cancel,
      'changes_requested' => Icons.edit_note,
      _ => Icons.history,
    };

Color _decisionColor(String action) => switch (action) {
      'approved' || 're-approved' => AppColors.success,
      'suspended' => Colors.deepOrange,
      'rejected' || 'revoked' => AppColors.error,
      'changes_requested' => AppColors.info,
      _ => AppColors.secondaryText,
    };

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 18,
        backgroundColor: _statusColor(status).withValues(alpha: 0.15),
        child: Icon(_statusIcon(status), size: 19, color: _statusColor(status)),
      );
}

class AdminSubmissionDetailsScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const AdminSubmissionDetailsScreen(
      {super.key, required this.id, required this.data});
  @override
  State<AdminSubmissionDetailsScreen> createState() =>
      _AdminSubmissionDetailsScreenState();
}

class _AdminSubmissionDetailsScreenState
    extends State<AdminSubmissionDetailsScreen> {
  String? currentStatus;
  final checks = <bool>[false, false, false, false, false, false];
  final reviewNotes = TextEditingController();
  bool checklistLoaded = false;
  final labels = const [
    'Event information is complete',
    'Organizer and contact verified',
    'Date and venue are valid',
    'Description is clear and accurate',
    'Media meets quality requirements',
    'Policy compliance confirmed',
  ];

  @override
  void dispose() {
    reviewNotes.dispose();
    super.dispose();
  }

  void _loadChecklist(Map<String, dynamic> event) {
    if (checklistLoaded) return;
    final saved = event['reviewChecklist'];
    if (saved is List) {
      for (var i = 0; i < checks.length && i < saved.length; i++) {
        checks[i] = saved[i] == true;
      }
    }
    reviewNotes.text = event['reviewNotes']?.toString() ?? '';
    checklistLoaded = true;
  }

  Future<void> _saveChecklist() async {
    await Db.saveReviewChecklist(widget.id, checks, reviewNotes.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Checklist saved')));
    }
  }

  Future<void> _deleteChecklist() async {
    await Db.deleteReviewChecklist(widget.id);
    setState(() {
      for (var i = 0; i < checks.length; i++) {
        checks[i] = false;
      }
      reviewNotes.clear();
    });
  }

  Future<void> decide(String status) async {
    if (status == 'approved') {
      await _submitDecision(status, '', '');
      return;
    }
    final feedback = TextEditingController();
    final internalNotes = TextEditingController();
    final reasons = <String>{};
    final reasonLabels = const [
      'Incomplete event info',
      'Organizer verification needed',
      'Venue or date issue',
      'Media quality issue',
      'Policy or safety concern'
    ];
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (context, setDialogState) {
        final needsCategories = status != 'approved';
        return AlertDialog(
          title: Text(status == 'approved'
              ? 'Approve event?'
              : status == 'rejected'
                  ? 'Reject event'
                  : 'Request changes'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (needsCategories) ...[
                      const Text('Reason categories'),
                      for (final reason in reasonLabels)
                        CheckboxListTile(
                            value: reasons.contains(reason),
                            title: Text(reason),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) => setDialogState(() =>
                                value == true
                                    ? reasons.add(reason)
                                    : reasons.remove(reason))),
                    ],
                    TextField(
                        controller: feedback,
                        maxLines: 3,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                            labelText: status == 'approved'
                                ? 'Approval reason (optional)'
                                : 'Admin feedback (required)',
                            border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                        controller: internalNotes,
                        maxLines: 2,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: const InputDecoration(
                            labelText: 'Internal notes',
                            border: OutlineInputBorder())),
                  ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: status != 'approved' && feedback.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(dialogContext, true),
                child: const Text('Submit decision')),
          ],
        );
      }),
    );
    if (result != true) return;
    await _submitDecision(
        status, feedback.text.trim(), internalNotes.text.trim());
  }

  Future<void> _submitDecision(
      String status, String feedback, String internalNotes) async {
    try {
      await Db.reviewEvent(
          eventId: widget.id,
          status: status,
          feedback: feedback,
          internalNotes: internalNotes);
      final savedEvent = await Db.eventOnce(widget.id);
      final savedStatus =
          savedEvent.data()?['status']?.toString().trim().toLowerCase();
      if (savedStatus != status) {
        throw StateError(
            'Firestore saved status "$savedStatus" instead of "$status".');
      }
      if (!mounted) return;
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => AdminDecisionConfirmationScreen(
                  status: savedStatus ?? status, eventId: widget.id)));
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Decision could not be saved: ${error.message ?? error.code}')));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Decision failed: $error')));
      }
    }
  }

  Future<void> moderate(String action) async {
    final reason = await _showModerationDialog(context, action);
    if (reason == null) return;
    await Db.transitionEvent(
        eventId: widget.id,
        status: action == 're-approved'
            ? 'approved'
            : action == 'revoked'
                ? 'rejected'
                : 'suspended',
        action: action,
        reason: reason);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Submission Details')),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: Db.event(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Could not load submission: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final event = snapshot.data!.data() ?? widget.data;
            _loadChecklist(event);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(event['title'] ?? 'Untitled event',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                _StatusBadge(
                    status: currentStatus ?? event['status'] ?? 'pending'),
                ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(event['category'] ?? 'Uncategorized')),
                ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title:
                        Text('${event['date'] ?? ''} ${event['time'] ?? ''}')),
                ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(event['location'] ?? '')),
                ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                        'Organizer: ${event['organizerName'] ?? 'Unknown'}')),
                const Divider(),
                Text(event['description'] ?? 'No description provided.'),
                const SizedBox(height: 20),
                Text('Decision history',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(widget.id)
                      .collection('decision_log')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Decision history unavailable');
                    }
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Text('No decisions recorded yet.');
                    }
                    return Column(children: [
                      for (final log in snapshot.data!.docs)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                              _decisionIcon(
                                  log.data()['action'] as String? ?? 'updated'),
                              color: _decisionColor(
                                  log.data()['action'] as String? ??
                                      'updated')),
                          title: Text(
                              '${_actionLabel(log.data()['action'] as String? ?? 'updated')} by ${log.data()['admin'] ?? 'Authority Officer'}'),
                          subtitle: Text(
                              log.data()['reason']?.toString().isNotEmpty ==
                                      true
                                  ? log.data()['reason'].toString()
                                  : 'No reason provided'),
                        ),
                    ]);
                  },
                ),
                const Divider(height: 28),
                Text(
                    'Review checklist: ${checks.where((value) => value).length}/6',
                    style: Theme.of(context).textTheme.titleMedium),
                for (var index = 0; index < labels.length; index++)
                  CheckboxListTile(
                      value: checks[index],
                      title: Text(labels[index]),
                      onChanged: (value) =>
                          setState(() => checks[index] = value ?? false)),
                TextField(
                    controller: reviewNotes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Checklist notes',
                        border: OutlineInputBorder())),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: _saveChecklist,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save checklist'))),
                  const SizedBox(width: 8),
                  IconButton(
                      tooltip: 'Clear checklist',
                      onPressed: _deleteChecklist,
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.red)),
                ]),
                const SizedBox(height: 12),
                if ((currentStatus ?? event['status']) == 'pending')
                  Row(children: [
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => decide('approved'),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.green))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => decide('changes_requested'),
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Changes'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => decide('rejected'),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red))),
                  ]),
                if ((currentStatus ?? event['status']) == 'approved')
                  Row(children: [
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => moderate('suspend'),
                            icon: const Icon(Icons.pause_circle),
                            label: const Text('Suspend'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.deepOrange))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => moderate('revoked'),
                            icon: const Icon(Icons.undo),
                            label: const Text('Revoke'))),
                  ]),
                if ((currentStatus ?? event['status']) == 'suspended')
                  Row(children: [
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => moderate('re-approved'),
                            icon: const Icon(Icons.restore),
                            label: const Text('Re-approve'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.green))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => moderate('revoked'),
                            icon: const Icon(Icons.undo),
                            label: const Text('Revoke'))),
                  ]),
              ],
            );
          },
        ),
      );
}

class AdminDecisionConfirmationScreen extends StatelessWidget {
  final String status;
  final String eventId;
  const AdminDecisionConfirmationScreen(
      {super.key, required this.status, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    final rejected = status == 'rejected';
    final title = approved
        ? 'Event Approved'
        : rejected
            ? 'Rejection Notice Sent'
            : 'Changes Requested';
    final icon = approved
        ? Icons.check_circle
        : rejected
            ? Icons.cancel
            : Icons.edit_note;
    final color = approved
        ? Colors.green
        : rejected
            ? Colors.red
            : Colors.orange;
    return Scaffold(
      appBar: AppBar(title: const Text('Decision Complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 72),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('The event status was saved successfully.',
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('View Next Submission')),
            ),
          ]),
        ),
      ),
    );
  }
}

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admin Notifications')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Db.adminNotifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Could not load notifications: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs.where((doc) {
              if (filter == 0) return true;
              return filter == 1 && doc.data()['read'] != true || filter == 2;
            }).toList();
            if (docs.isEmpty) {
              return const Center(child: Text('No authority notifications'));
            }
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('All')),
                        ButtonSegment(value: 1, label: Text('Unread')),
                        ButtonSegment(value: 2, label: Text('Submissions'))
                      ],
                      selected: {
                        filter
                      },
                      onSelectionChanged: (value) =>
                          setState(() => filter = value.first))),
              Expanded(
                  child: ListView(padding: const EdgeInsets.all(12), children: [
                for (final doc in docs)
                  Card(
                      child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.amber.shade100,
                              child: const Icon(Icons.notifications_none)),
                          title: Text(doc.data()['title'] ?? 'Notification',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(doc.data()['message'] ?? ''),
                          trailing: doc.data()['read'] == true
                              ? null
                              : const Icon(Icons.fiber_manual_record,
                                  color: Colors.amber, size: 12)))
              ])),
            ]);
          },
        ),
      );
}

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const CircleAvatar(
            radius: 36, child: Icon(Icons.admin_panel_settings, size: 36)),
        const SizedBox(height: 12),
        Center(
            child: Text(user?.displayName ?? 'Authority Officer',
                style: Theme.of(context).textTheme.titleLarge)),
        const Center(child: Text('Senior Admin')),
        const SizedBox(height: 24),
        Card(
            child: Column(children: [
          ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? '')),
          const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('Not added')),
          const ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Member since'),
              subtitle: Text('Ceylona account'))
        ])),
        const SizedBox(height: 16),
        const Text('Security & preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Two-factor authentication')),
        SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Email notifications')),
        SwitchListTile(
            value: false, onChanged: (_) {}, title: const Text('SMS alerts')),
        SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Weekly summary digest')),
        const SizedBox(height: 12),
        OutlinedButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Log out')),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Chip(
      label: Text(_statusLabel(status),
          style: TextStyle(
              color: _statusColor(status),
              fontSize: 10,
              fontWeight: FontWeight.w700)),
      backgroundColor: _statusColor(status).withValues(alpha: 0.14),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact);
}

String _statusLabel(String status) => switch (status) {
      'pending' => 'Pending review',
      'changes_requested' => 'Changes requested',
      'approved' => 'Approved',
      'suspended' => 'Suspended',
      'rejected' => 'Rejected',
      _ => status,
    };

Color _statusColor(String status) => switch (status) {
      'approved' => Colors.green,
      'suspended' => Colors.deepOrange,
      'rejected' => Colors.red,
      'changes_requested' => Colors.orange,
      _ => Colors.blue,
    };

IconData _statusIcon(String status) => switch (status) {
      'approved' => Icons.verified,
      'suspended' => Icons.pause_circle,
      'rejected' => Icons.cancel,
      'changes_requested' => Icons.edit_note,
      _ => Icons.pending,
    };
