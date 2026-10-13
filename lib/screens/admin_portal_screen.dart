// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../services/db.dart';
// import '../theme/app_theme.dart';
// import 'admin_review_checklist_screen.dart';
// import '../widgets/event_image.dart';
// import 'event_gallery_screen.dart';
// import '../widgets/admin_brand_bar.dart';
// import '../widgets/admin_design.dart';

// class AdminPortalScreen extends StatefulWidget {
//   const AdminPortalScreen({super.key});
//   @override
//   State<AdminPortalScreen> createState() => _AdminPortalScreenState();
// }

// class _AdminPortalScreenState extends State<AdminPortalScreen> {
//   int index = 0;
//   @override
//   Widget build(BuildContext context) {
//     final pages = const [
//       AdminDashboardScreen(),
//       AdminApprovalsScreen(),
//       ReviewChecklistScreen(),
//       AdminNotificationsScreen(),
//       AdminProfileScreen(),
//     ];
//     return Theme(
//       data: AppTheme.light,
//       child: Scaffold(
//         body: pages[index],
//         bottomNavigationBar: NavigationBar(
//           backgroundColor: AppColors.surface,
//           indicatorColor: AppColors.primary.withValues(alpha: .22),
//           surfaceTintColor: Colors.transparent,
//           elevation: 2,
//           height: 72,
//           labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//           selectedIndex: index,
//           onDestinationSelected: (value) => setState(() => index = value),
//           destinations: const [
//             NavigationDestination(
//                 icon: Icon(Icons.dashboard_outlined),
//                 selectedIcon: Icon(Icons.dashboard),
//                 label: 'Dashboard'),
//             NavigationDestination(
//                 icon: Icon(Icons.verified_outlined),
//                 selectedIcon: Icon(Icons.verified),
//                 label: 'Approvals'),
//             NavigationDestination(
//                 icon: Icon(Icons.checklist_outlined),
//                 selectedIcon: Icon(Icons.checklist),
//                 label: 'Checklist'),
//             NavigationDestination(
//                 icon: Icon(Icons.notifications_outlined),
//                 selectedIcon: Icon(Icons.notifications),
//                 label: 'Alerts'),
//             NavigationDestination(
//                 icon: Icon(Icons.person_outline),
//                 selectedIcon: Icon(Icons.person),
//                 label: 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   final search = TextEditingController();
//   String status = 'All statuses';

//   @override
//   void dispose() {
//     search.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: const AdminBrandBar(title: 'Command centre'),
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: Db.adminEvents(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text('Could not load submissions: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final docs = snapshot.data!.docs;
//             final query = search.text.toLowerCase();
//             final filtered = docs.where((doc) {
//               final data = doc.data();
//               final matchesStatus = status == 'All statuses' ||
//                   data['status'] == status.toLowerCase();
//               final text =
//                   '${data['title'] ?? ''} ${data['organizerName'] ?? ''}'
//                       .toLowerCase();
//               return matchesStatus && text.contains(query);
//             }).toList();
//             return ListView(
//               padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     color: AppColors.surface,
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: AppColors.border),
//                   ),
//                   child: const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Good to see you, Admin',
//                           style: TextStyle(
//                               color: AppColors.primaryDark,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700)),
//                       SizedBox(height: 6),
//                       Text(
//                           'Keep Ceylona events safe, accurate and ready to discover.',
//                           style: TextStyle(
//                               color: AppColors.secondaryText, height: 1.35)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     mainAxisExtent: 104,
//                     children: [
//                       _StatCard(
//                           label: 'Pending',
//                           value: _count(docs, 'pending'),
//                           color: AppColors.warning),
//                       _StatCard(
//                           label: 'Approved',
//                           value: _count(docs, 'approved'),
//                           color: AppColors.success),
//                       _StatCard(
//                           label: 'Rejected',
//                           value: _count(docs, 'rejected'),
//                           color: AppColors.error),
//                       _StatCard(
//                           label: 'Total',
//                           value: docs.length,
//                           color: AppColors.info),
//                     ]),
//                 const SizedBox(height: 16),
//                 const Text('SUBMISSIONS',
//                     style: TextStyle(
//                         fontSize: 11,
//                         letterSpacing: 1.1,
//                         color: AppColors.secondaryText,
//                         fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 8),
//                 TextField(
//                     controller: search,
//                     onChanged: (_) => setState(() {}),
//                     decoration: const InputDecoration(
//                         prefixIcon: Icon(Icons.search),
//                         hintText: 'Search events or organizers',
//                         isDense: true,
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12))))),
//                 const SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                     initialValue: status,
//                     isDense: true,
//                     decoration: const InputDecoration(
//                         labelText: 'Filter by status',
//                         border: OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12)))),
//                     items: const [
//                       'All statuses',
//                       'Pending',
//                       'Approved',
//                       'Rejected',
//                       'Changes_requested'
//                     ]
//                         .map((value) =>
//                             DropdownMenuItem(value: value, child: Text(value)))
//                         .toList(),
//                     onChanged: (value) => setState(() => status = value!)),
//                 const SizedBox(height: 12),
//                 Text('${filtered.length} submissions found',
//                     style: const TextStyle(
//                         color: AppColors.secondaryText,
//                         fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 6),
//                 if (filtered.isEmpty) const Text('No submissions found.'),
//                 for (final doc in filtered) _DashboardSubmissionCard(doc: doc),
//               ],
//             );
//           },
//         ),
//       );

//   static int _count(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
//           String status) =>
//       docs.where((doc) => doc.data()['status'] == status).length;
// }

// class _DashboardSubmissionCard extends StatelessWidget {
//   final QueryDocumentSnapshot<Map<String, dynamic>> doc;
//   const _DashboardSubmissionCard({required this.doc});

//   @override
//   Widget build(BuildContext context) {
//     final data = doc.data();
//     final status = data['status']?.toString() ?? 'pending';
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             EventImage(
//                 url: data['imageUrl']?.toString(),
//                 width: 54,
//                 height: 54,
//                 borderRadius: const BorderRadius.all(Radius.circular(6))),
//             const SizedBox(width: 10),
//             Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                   Text(data['title'] ?? 'Untitled event',
//                       style: const TextStyle(fontWeight: FontWeight.w700)),
//                   Text('by ${data['organizerName'] ?? 'Unknown organizer'}',
//                       style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                   const SizedBox(height: 4),
//                   Chip(
//                       label: Text(_statusLabel(status)),
//                       visualDensity: VisualDensity.compact),
//                 ])),
//           ]),
//           const SizedBox(height: 7),
//           Text('CATEGORY  ${data['category'] ?? 'Uncategorized'}',
//               style: const TextStyle(fontSize: 10, color: AppColors.primary)),
//           Text('EVENT DATE  ${data['date'] ?? ''}',
//               style: const TextStyle(fontSize: 10, color: Colors.black54)),
//           Text('VENUE / LOCATION  ${data['location'] ?? ''}',
//               style: const TextStyle(fontSize: 10, color: Colors.black54)),
//           const SizedBox(height: 6),
//           Align(
//               alignment: Alignment.centerRight,
//               child: FilledButton.icon(
//                   onPressed: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => AdminSubmissionDetailsScreen(
//                               id: doc.id, data: data))),
//                   icon: const Icon(Icons.arrow_forward, size: 14),
//                   label: const Text('View Details'),
//                   style: FilledButton.styleFrom(
//                       minimumSize: const Size(0, 34),
//                       padding: const EdgeInsets.symmetric(horizontal: 12)))),
//         ]),
//       ),
//     );
//   }

//   String _statusLabel(String status) => switch (status) {
//         'pending' => 'Pending Review',
//         'approved' => 'Approved',
//         'rejected' => 'Rejected',
//         'changes_requested' => 'Changes Requested',
//         _ => status,
//       };
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final Color color;
//   const _StatCard(
//       {required this.label, required this.value, required this.color});

//   @override
//   Widget build(BuildContext context) => Card(
//         clipBehavior: Clip.antiAlias,
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(children: [
//             Container(
//               width: 5,
//               height: 48,
//               decoration: BoxDecoration(
//                   color: color, borderRadius: BorderRadius.circular(8)),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('$value',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 2),
//                   Text(label,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                           color: AppColors.secondaryText,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ),
//           ]),
//         ),
//       );
// }

// class AdminApprovalsScreen extends StatefulWidget {
//   const AdminApprovalsScreen({super.key});
//   @override
//   State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
// }

// class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
//   String search = '';
//   final searchController = TextEditingController();
//   static const statuses = [
//     'pending',
//     'approved',
//     'suspended',
//     'rejected',
//     'changes_requested'
//   ];

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleAction(
//       QueryDocumentSnapshot<Map<String, dynamic>> doc, String action) async {
//     if (action == 'view') {
//       if (mounted) {
//         await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => AdminSubmissionDetailsScreen(
//                     id: doc.id, data: doc.data())));
//       }
//       return;
//     }
//     final reason = await _showModerationDialog(context, action);
//     if (reason == null) return;
//     try {
//       await Db.transitionEvent(
//           eventId: doc.id,
//           status: action == 're-approved'
//               ? 'approved'
//               : action == 'revoked'
//                   ? 'rejected'
//                   : 'suspended',
//           action: action,
//           reason: reason);
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(_actionLabel(action))));
//       }
//     } on FirebaseException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//                 'Could not update event: ${error.message ?? error.code}')));
//       }
//     }
//   }

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtered(
//           List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
//           String status) =>
//       docs.where((doc) {
//         final data = doc.data();
//         final text = '${data['title'] ?? ''} ${data['organizerName'] ?? ''}'
//             .toLowerCase();
//         return data['status'] == status && text.contains(search.toLowerCase());
//       }).toList();

//   Widget _eventList(BuildContext context,
//       List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String status) {
//     final filtered = _filtered(docs, status);
//     if (filtered.isEmpty) {
//       return Center(
//           child: Text('No ${_statusLabel(status).toLowerCase()} events'));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.only(top: 4, bottom: 16),
//       itemCount: filtered.length,
//       itemBuilder: (context, index) {
//         final doc = filtered[index];
//         final data = doc.data();
//         final actions = switch (status) {
//           'approved' => const ['view', 'suspend', 'revoked'],
//           'suspended' => const ['view', 're-approved', 'revoked'],
//           _ => const ['view'],
//         };
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//           child: ListTile(
//             contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
//             leading: EventImage(
//                 url: data['imageUrl']?.toString(),
//                 width: 56,
//                 height: 56,
//                 borderRadius: const BorderRadius.all(Radius.circular(6))),
//             title: Text(data['title'] ?? 'Untitled event',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.w700)),
//             subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: Text(
//                     '${data['organizerName'] ?? 'Unknown organizer'}\n${data['date'] ?? ''} • ${data['location'] ?? ''}',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         color: AppColors.secondaryText, fontSize: 12))),
//             isThreeLine: true,
//             trailing: PopupMenuButton<String>(
//               tooltip: 'Event actions',
//               onSelected: (action) => _handleAction(doc, action),
//               itemBuilder: (_) => [
//                 for (final action in actions)
//                   PopupMenuItem(
//                       value: action,
//                       child: Text(action == 'view'
//                           ? 'View details'
//                           : _actionLabel(action))),
//               ],
//             ),
//             onTap: () => _handleAction(doc, 'view'),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) => DefaultTabController(
//         length: statuses.length,
//         child: Scaffold(
//           appBar: const AdminBrandBar(
//             title: 'Event Approvals',
//             bottom: TabBar(
//               isScrollable: true,
//               tabs: [
//                 Tab(text: 'Pending'),
//                 Tab(text: 'Approved'),
//                 Tab(text: 'Suspended'),
//                 Tab(text: 'Rejected'),
//                 Tab(text: 'Changes requested'),
//               ],
//             ),
//           ),
//           body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//             stream: Db.adminEvents(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(
//                     child: Text('Could not load approvals: ${snapshot.error}'));
//               }
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final docs = snapshot.data!.docs;
//               return Column(children: [
//                 const Padding(
//                   padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   child: AdminPageIntro(
//                     eyebrow: 'Moderation queue',
//                     title: 'Review submissions',
//                     description:
//                         'Make confident decisions and keep event quality high.',
//                     icon: Icons.verified_outlined,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//                   child: TextField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                         prefixIcon: const Icon(Icons.search),
//                         hintText: 'Search events or organizers',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: search.isEmpty
//                             ? null
//                             : IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: () {
//                                   searchController.clear();
//                                   setState(() => search = '');
//                                 })),
//                     onChanged: (value) => setState(() => search = value),
//                   ),
//                 ),
//                 Expanded(
//                     child: TabBarView(children: [
//                   for (final status in statuses)
//                     _eventList(context, docs, status)
//                 ])),
//               ]);
//             },
//           ),
//         ),
//       );
// }

// Future<String?> _showModerationDialog(BuildContext context, String action) {
//   if (action == 're-approved') {
//     return showDialog<String>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Re-approve this event?'),
//         content: const Text(
//             'The event will become publicly visible again and saved seekers will be notified.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel')),
//           FilledButton(
//               onPressed: () => Navigator.pop(dialogContext, ''),
//               child: const Text('Re-approve')),
//         ],
//       ),
//     );
//   }

//   final note = TextEditingController();
//   final categories = <String>{};
//   const categoryLabels = [
//     'Fraud reported',
//     'Policy violation discovered',
//     'Organizer misconduct',
//     'Venue no longer valid',
//     'Other'
//   ];
//   return showDialog<String>(
//     context: context,
//     builder: (dialogContext) =>
//         StatefulBuilder(builder: (context, setDialogState) {
//       final title = action == 'suspend' ? 'Suspend event' : 'Revoke approval';
//       final button = action == 'suspend' ? 'Suspend event' : 'Revoke approval';
//       return AlertDialog(
//         title: Text(title),
//         content: SingleChildScrollView(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(action == 'suspend'
//                 ? 'Why are you suspending this approved event?'
//                 : 'Why are you revoking this approval?'),
//             const SizedBox(height: 12),
//             const Text('Select all that apply',
//                 style: TextStyle(fontWeight: FontWeight.w600)),
//             for (final category in categoryLabels)
//               CheckboxListTile(
//                 dense: true,
//                 contentPadding: EdgeInsets.zero,
//                 value: categories.contains(category),
//                 title: Text(category),
//                 onChanged: (value) => setDialogState(() => value == true
//                     ? categories.add(category)
//                     : categories.remove(category)),
//               ),
//             TextField(
//                 controller: note,
//                 maxLines: 3,
//                 onChanged: (_) => setDialogState(() {}),
//                 decoration: const InputDecoration(
//                     labelText: 'Reason (required)',
//                     hintText: 'Add context for the organizer',
//                     border: OutlineInputBorder())),
//           ]),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel')),
//           FilledButton(
//             onPressed: categories.isEmpty && note.text.trim().isEmpty
//                 ? null
//                 : () {
//                     final reason = [
//                       ...categories,
//                       if (note.text.trim().isNotEmpty) note.text.trim()
//                     ].join('. ');
//                     Navigator.pop(dialogContext, reason);
//                   },
//             child: Text(button),
//           ),
//         ],
//       );
//     }),
//   );
// }

// String _actionLabel(String action) => switch (action) {
//       'suspend' => 'Suspend event',
//       'revoked' => 'Revoke approval',
//       're-approved' => 'Re-approve',
//       _ => 'View details',
//     };

// IconData _decisionIcon(String action) => switch (action) {
//       'approved' || 're-approved' => Icons.check_circle,
//       'suspended' => Icons.pause_circle,
//       'rejected' || 'revoked' => Icons.cancel,
//       'changes_requested' => Icons.edit_note,
//       _ => Icons.history,
//     };

// Color _decisionColor(String action) => switch (action) {
//       'approved' || 're-approved' => AppColors.success,
//       'suspended' => Colors.deepOrange,
//       'rejected' || 'revoked' => AppColors.error,
//       'changes_requested' => AppColors.info,
//       _ => AppColors.secondaryText,
//     };

// class AdminSubmissionDetailsScreen extends StatefulWidget {
//   final String id;
//   final Map<String, dynamic> data;
//   const AdminSubmissionDetailsScreen(
//       {super.key, required this.id, required this.data});
//   @override
//   State<AdminSubmissionDetailsScreen> createState() =>
//       _AdminSubmissionDetailsScreenState();
// }

// class _AdminSubmissionDetailsScreenState
//     extends State<AdminSubmissionDetailsScreen> {
//   String? currentStatus;

//   Future<void> decide(String status) async {
//     final category = status == 'approved'
//         ? 'approval'
//         : status == 'rejected'
//             ? 'rejection'
//             : 'changes';
//     final checklistSnapshot = await Db.reviewChecklistItems().first;
//     if (!mounted) return;
//     final checklistItems = checklistSnapshot.docs
//         .where((doc) =>
//             (doc.data()['category']?.toString() ?? 'approval') == category)
//         .map((doc) => doc.data()['title']?.toString() ?? '')
//         .where((title) => title.isNotEmpty)
//         .toList();
//     final selectedChecklist = <String>{};
//     final feedback = TextEditingController();
//     final internalNotes = TextEditingController();
//     final reasons = <String>{};
//     final reasonLabels = const [
//       'Incomplete event info',
//       'Organizer verification needed',
//       'Venue or date issue',
//       'Media quality issue',
//       'Policy or safety concern'
//     ];
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) =>
//           StatefulBuilder(builder: (context, setDialogState) {
//         final needsCategories = status != 'approved';
//         return AlertDialog(
//           title: Text(status == 'approved'
//               ? 'Approve event?'
//               : status == 'rejected'
//                   ? 'Reject event'
//                   : 'Request changes'),
//           content: SizedBox(
//             width: 440,
//             child: SingleChildScrollView(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                         '${status == 'approved' ? 'Approval' : status == 'rejected' ? 'Rejection' : 'Changes requested'} checklist',
//                         style: const TextStyle(fontWeight: FontWeight.w700)),
//                     if (checklistItems.isEmpty)
//                       const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 8),
//                           child: Text('No checklist items configured.')),
//                     for (final item in checklistItems)
//                       CheckboxListTile(
//                           value: selectedChecklist.contains(item),
//                           title: Text(item),
//                           contentPadding: EdgeInsets.zero,
//                           onChanged: (value) => setDialogState(() =>
//                               value == true
//                                   ? selectedChecklist.add(item)
//                                   : selectedChecklist.remove(item))),
//                     if (needsCategories) ...[
//                       const Text('Reason categories'),
//                       for (final reason in reasonLabels)
//                         CheckboxListTile(
//                             value: reasons.contains(reason),
//                             title: Text(reason),
//                             contentPadding: EdgeInsets.zero,
//                             onChanged: (value) => setDialogState(() =>
//                                 value == true
//                                     ? reasons.add(reason)
//                                     : reasons.remove(reason))),
//                     ],
//                     TextField(
//                         controller: feedback,
//                         maxLines: 3,
//                         onChanged: (_) => setDialogState(() {}),
//                         decoration: InputDecoration(
//                             labelText: status == 'approved'
//                                 ? 'Approval reason (optional)'
//                                 : 'Admin feedback (required)',
//                             border: const OutlineInputBorder())),
//                     const SizedBox(height: 12),
//                     TextField(
//                         controller: internalNotes,
//                         maxLines: 2,
//                         onChanged: (_) => setDialogState(() {}),
//                         decoration: const InputDecoration(
//                             labelText: 'Internal notes',
//                             border: OutlineInputBorder())),
//                   ]),
//             ),
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel')),
//             FilledButton(
//                 onPressed: selectedChecklist.length != checklistItems.length ||
//                         (status != 'approved' && feedback.text.trim().isEmpty)
//                     ? null
//                     : () => Navigator.pop(dialogContext, true),
//                 child: const Text('Submit decision')),
//           ],
//         );
//       }),
//     );
//     if (result != true) return;
//     await _submitDecision(status, feedback.text.trim(),
//         internalNotes.text.trim(), selectedChecklist.toList());
//   }

//   Future<void> _submitDecision(String status, String feedback,
//       String internalNotes, List<String> checklistItems) async {
//     try {
//       await Db.reviewEvent(
//           eventId: widget.id,
//           status: status,
//           feedback: feedback,
//           internalNotes: internalNotes,
//           checklistItems: checklistItems);
//       final savedEvent = await Db.eventOnce(widget.id);
//       final savedStatus =
//           savedEvent.data()?['status']?.toString().trim().toLowerCase();
//       if (savedStatus != status) {
//         throw StateError(
//             'Firestore saved status "$savedStatus" instead of "$status".');
//       }
//       if (!mounted) return;
//       await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (_) => AdminDecisionConfirmationScreen(
//                   status: savedStatus ?? status, eventId: widget.id)));
//     } on FirebaseException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//                 'Decision could not be saved: ${error.message ?? error.code}')));
//       }
//     } on StateError catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(error.message)));
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Decision failed: $error')));
//       }
//     }
//   }

//   Future<void> moderate(String action) async {
//     final reason = await _showModerationDialog(context, action);
//     if (reason == null) return;
//     await Db.transitionEvent(
//         eventId: widget.id,
//         status: action == 're-approved'
//             ? 'approved'
//             : action == 'revoked'
//                 ? 'rejected'
//                 : 'suspended',
//         action: action,
//         reason: reason);
//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AdminBrandBar(
//             title: 'Submission Details', onBack: () => Navigator.pop(context)),
//         body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//           stream: Db.event(widget.id),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text('Could not load submission: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final event = snapshot.data!.data() ?? widget.data;
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 EventImage(url: event['imageUrl']?.toString(), height: 190),
//                 const SizedBox(height: 12),
//                 Text(event['title'] ?? 'Untitled event',
//                     style: Theme.of(context).textTheme.headlineSmall),
//                 const SizedBox(height: 8),
//                 _StatusBadge(
//                     status: currentStatus ?? event['status'] ?? 'pending'),
//                 ListTile(
//                     leading: const Icon(Icons.category),
//                     title: Text(event['category'] ?? 'Uncategorized')),
//                 ListTile(
//                     leading: const Icon(Icons.calendar_today),
//                     title:
//                         Text('${event['date'] ?? ''} ${event['time'] ?? ''}')),
//                 ListTile(
//                     leading: const Icon(Icons.place),
//                     title: Text(event['location'] ?? '')),
//                 ListTile(
//                     leading: const Icon(Icons.person),
//                     title: Text(
//                         'Organizer: ${event['organizerName'] ?? 'Unknown'}')),
//                 const Divider(),
//                 Text(event['description'] ?? 'No description provided.'),
//                 OutlinedButton.icon(
//                     onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => EventGalleryScreen(
//                                 eventId: widget.id,
//                                 eventTitle: event['title'] ?? 'Event',
//                                 mode: GalleryMode.admin))),
//                     icon: const Icon(Icons.photo_library_outlined),
//                     label: const Text('Review event gallery')),
//                 const SizedBox(height: 20),
//                 Text('Decision history',
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('events')
//                       .doc(widget.id)
//                       .collection('decision_log')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return const Text('Decision history unavailable');
//                     }
//                     if (!snapshot.hasData) {
//                       return const LinearProgressIndicator();
//                     }
//                     if (snapshot.data!.docs.isEmpty) {
//                       return const Text('No decisions recorded yet.');
//                     }
//                     return Column(children: [
//                       for (final log in snapshot.data!.docs)
//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: Icon(
//                               _decisionIcon(
//                                   log.data()['action'] as String? ?? 'updated'),
//                               color: _decisionColor(
//                                   log.data()['action'] as String? ??
//                                       'updated')),
//                           title: Text(
//                               '${_actionLabel(log.data()['action'] as String? ?? 'updated')} by ${log.data()['admin'] ?? 'Authority Officer'}'),
//                           subtitle: Text(
//                               log.data()['reason']?.toString().isNotEmpty ==
//                                       true
//                                   ? log.data()['reason'].toString()
//                                   : 'No reason provided'),
//                         ),
//                     ]);
//                   },
//                 ),
//                 const Divider(height: 28),
//                 if ((currentStatus ?? event['status']) == 'pending')
//                   Row(children: [
//                     Expanded(
//                         child: FilledButton.icon(
//                             onPressed: () => decide('approved'),
//                             icon: const Icon(Icons.check),
//                             label: const Text('Approve'),
//                             style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.green))),
//                     const SizedBox(width: 8),
//                     Expanded(
//                         child: FilledButton.icon(
//                             onPressed: () => decide('changes_requested'),
//                             icon: const Icon(Icons.edit_note),
//                             label: const Text('Changes'),
//                             style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.orange))),
//                     const SizedBox(width: 8),
//                     Expanded(
//                         child: FilledButton.icon(
//                             onPressed: () => decide('rejected'),
//                             icon: const Icon(Icons.close),
//                             label: const Text('Reject'),
//                             style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.red))),
//                   ]),
//                 if ((currentStatus ?? event['status']) == 'approved')
//                   Row(children: [
//                     Expanded(
//                         child: FilledButton.icon(
//                             onPressed: () => moderate('suspend'),
//                             icon: const Icon(Icons.pause_circle),
//                             label: const Text('Suspend'),
//                             style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.deepOrange))),
//                     const SizedBox(width: 8),
//                     Expanded(
//                         child: OutlinedButton.icon(
//                             onPressed: () => moderate('revoked'),
//                             icon: const Icon(Icons.undo),
//                             label: const Text('Revoke'))),
//                   ]),
//                 if ((currentStatus ?? event['status']) == 'suspended')
//                   Row(children: [
//                     Expanded(
//                         child: FilledButton.icon(
//                             onPressed: () => moderate('re-approved'),
//                             icon: const Icon(Icons.restore),
//                             label: const Text('Re-approve'),
//                             style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.green))),
//                     const SizedBox(width: 8),
//                     Expanded(
//                         child: OutlinedButton.icon(
//                             onPressed: () => moderate('revoked'),
//                             icon: const Icon(Icons.undo),
//                             label: const Text('Revoke'))),
//                   ]),
//               ],
//             );
//           },
//         ),
//       );
// }

// class AdminDecisionConfirmationScreen extends StatelessWidget {
//   final String status;
//   final String eventId;
//   const AdminDecisionConfirmationScreen(
//       {super.key, required this.status, required this.eventId});

//   @override
//   Widget build(BuildContext context) {
//     final approved = status == 'approved';
//     final rejected = status == 'rejected';
//     final title = approved
//         ? 'Event Approved'
//         : rejected
//             ? 'Rejection Notice Sent'
//             : 'Changes Requested';
//     final icon = approved
//         ? Icons.check_circle
//         : rejected
//             ? Icons.cancel
//             : Icons.edit_note;
//     final color = approved
//         ? Colors.green
//         : rejected
//             ? Colors.red
//             : Colors.orange;
//     return Scaffold(
//       appBar: const AdminBrandBar(title: 'Decision Complete'),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(icon, color: color, size: 72),
//             const SizedBox(height: 16),
//             Text(title,
//                 textAlign: TextAlign.center,
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
//             const SizedBox(height: 8),
//             const Text('The event status was saved successfully.',
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 28),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('View Next Submission')),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// class AdminNotificationsScreen extends StatefulWidget {
//   const AdminNotificationsScreen({super.key});

//   @override
//   State<AdminNotificationsScreen> createState() =>
//       _AdminNotificationsScreenState();
// }

// class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
//   int filter = 0;

//   Future<void> _openNotification(BuildContext context,
//       QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
//     await Db.markAdminNotificationRead(doc.id);
//     final data = doc.data();
//     if (data['action'] == 'gallery_submitted' &&
//         data['eventId']?.toString().isNotEmpty == true &&
//         context.mounted) {
//       await Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => EventGalleryScreen(
//                   eventId: data['eventId'].toString(),
//                   eventTitle: data['eventTitle']?.toString() ?? 'Event',
//                   mode: GalleryMode.admin)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: const AdminBrandBar(title: 'Notifications'),
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: Db.adminNotifications(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child:
//                       Text('Could not load notifications: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final allDocs = snapshot.data!.docs;
//             final docs = allDocs.where((doc) {
//               if (filter == 0) return true;
//               return filter == 1 && doc.data()['read'] != true || filter == 2;
//             }).toList();
//             if (docs.isEmpty) {
//               return const Center(child: Text('No authority notifications'));
//             }
//             return Column(children: [
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
//                 child: AdminPageIntro(
//                   eyebrow: 'Activity centre',
//                   title: 'Stay up to date',
//                   description:
//                       'Submission activity and content updates that need your attention.',
//                   icon: Icons.notifications_active_outlined,
//                 ),
//               ),
//               if (allDocs.any((doc) => doc.data()['read'] != true))
//                 Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton.icon(
//                         onPressed: () =>
//                             Db.markAllAdminNotificationsRead(allDocs),
//                         icon: const Icon(Icons.done_all, size: 18),
//                         label: const Text('Mark all read'))),
//               Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
//                   child: SegmentedButton<int>(
//                       segments: const [
//                         ButtonSegment(value: 0, label: Text('All')),
//                         ButtonSegment(value: 1, label: Text('Unread')),
//                         ButtonSegment(value: 2, label: Text('Submissions'))
//                       ],
//                       selected: {
//                         filter
//                       },
//                       onSelectionChanged: (value) =>
//                           setState(() => filter = value.first))),
//               Expanded(
//                   child: ListView(padding: const EdgeInsets.all(12), children: [
//                 for (final doc in docs)
//                   Card(
//                       child: ListTile(
//                           leading: CircleAvatar(
//                               backgroundColor: Colors.amber.shade100,
//                               child: const Icon(Icons.notifications_none)),
//                           title: Text(doc.data()['title'] ?? 'Notification',
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.w700)),
//                           subtitle: Text(
//                               '${doc.data()['eventTitle'] ?? 'Event'}\n${doc.data()['message'] ?? ''}'),
//                           onTap: () => _openNotification(context, doc),
//                           trailing: doc.data()['read'] == true
//                               ? const Icon(Icons.chevron_right,
//                                   color: AppColors.secondaryText)
//                               : Container(
//                                   padding: const EdgeInsets.all(7),
//                                   decoration: BoxDecoration(
//                                       color: AppColors.primary
//                                           .withValues(alpha: .16),
//                                       shape: BoxShape.circle),
//                                   child: const Icon(
//                                       Icons.mark_email_unread_outlined,
//                                       color: AppColors.primary,
//                                       size: 18))))
//               ])),
//             ]);
//           },
//         ),
//       );
// }

// class AdminProfileScreen extends StatelessWidget {
//   const AdminProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     return Scaffold(
//       appBar: const AdminBrandBar(title: 'Admin Profile'),
//       body: ListView(padding: const EdgeInsets.all(16), children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: const Row(children: [
//             CircleAvatar(
//                 radius: 30,
//                 backgroundColor: AppColors.primary,
//                 child: Icon(Icons.admin_panel_settings,
//                     size: 32, color: AppColors.primaryDark)),
//             SizedBox(width: 14),
//             Expanded(
//                 child: Text('Administrator workspace',
//                     style: TextStyle(
//                         color: AppColors.primaryDark,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700))),
//           ]),
//         ),
//         const SizedBox(height: 12),
//         Center(
//             child: Text(user?.displayName ?? 'Authority Officer',
//                 style: Theme.of(context).textTheme.titleLarge)),
//         FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//             future:
//                 FirebaseFirestore.instance.collection('admins').doc(uid).get(),
//             builder: (context, snapshot) {
//               final role = snapshot.data?.data()?['role']?.toString();
//               return Center(
//                   child: Text(
//                       role == 'admin_officer' ? 'Admin Officer' : 'Admin'));
//             }),
//         const SizedBox(height: 24),
//         const AdminSectionLabel(
//             title: 'Account settings',
//             subtitle: 'Manage access and preferences'),
//         Card(
//             child: Column(children: [
//           ListTile(
//               leading: const Icon(Icons.email),
//               title: const Text('Email'),
//               subtitle: Text(user?.email ?? '')),
//           const ListTile(
//               leading: Icon(Icons.phone),
//               title: Text('Phone'),
//               subtitle: Text('Not added')),
//           const ListTile(
//               leading: Icon(Icons.calendar_today),
//               title: Text('Member since'),
//               subtitle: Text('Ceylona account'))
//         ])),
//         const SizedBox(height: 16),
//         OutlinedButton.icon(
//             onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AdminManagementScreen())),
//             icon: const Icon(Icons.manage_accounts_outlined),
//             label: const Text('Manage admins')),
//         const Text('Security & preferences',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//         const SizedBox(height: 6),
//         SwitchListTile(
//             value: false,
//             onChanged: (_) {},
//             title: const Text('Two-factor authentication')),
//         SwitchListTile(
//             value: true,
//             onChanged: (_) {},
//             title: const Text('Email notifications')),
//         SwitchListTile(
//             value: false, onChanged: (_) {}, title: const Text('SMS alerts')),
//         SwitchListTile(
//             value: true,
//             onChanged: (_) {},
//             title: const Text('Weekly summary digest')),
//         const SizedBox(height: 12),
//         OutlinedButton(
//             onPressed: () => FirebaseAuth.instance.signOut(),
//             child: const Text('Log out')),
//       ]),
//     );
//   }
// }

// class AdminManagementScreen extends StatelessWidget {
//   const AdminManagementScreen({super.key});

//   static const categories = [
//     'Event Approvals',
//     'Content Moderation',
//     'User Management',
//     'Reports & Analytics',
//   ];
//   static const accessOptions = {
//     'approvals': 'Review event submissions',
//     'checklist': 'Manage review checklist',
//     'notifications': 'View admin notifications',
//     'analytics': 'View reports and analytics',
//   };

//   Future<Map<String, dynamic>?> _form(BuildContext context,
//       {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
//     final userId = TextEditingController();
//     final email = TextEditingController();
//     final name = TextEditingController();
//     final data = existing?.data();
//     userId.text = existing?.id ?? '';
//     email.text = data?['email']?.toString() ?? '';
//     name.text = data?['name']?.toString() ?? '';
//     var category = data?['category']?.toString() ?? categories.first;
//     var access = {
//       ...((data?['access'] as List?)?.whereType<String>() ?? const [])
//     };
//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(existing == null ? 'Add admin' : 'Update admin details'),
//         content: StatefulBuilder(builder: (context, setDialogState) {
//           return SingleChildScrollView(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//             TextField(
//                 controller: userId,
//                 readOnly: existing != null,
//                 decoration: const InputDecoration(
//                     labelText: 'Firebase Auth UID',
//                     border: OutlineInputBorder())),
//             const SizedBox(height: 10),
//             TextField(
//                 controller: name,
//                 decoration: const InputDecoration(
//                     labelText: 'Admin name', border: OutlineInputBorder())),
//             const SizedBox(height: 10),
//             TextField(
//                 controller: email,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                     labelText: 'Admin email', border: OutlineInputBorder())),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//                 initialValue: category,
//                 decoration: const InputDecoration(
//                     labelText: 'Admin category', border: OutlineInputBorder()),
//                 items: [
//                   for (final item in categories)
//                     DropdownMenuItem(value: item, child: Text(item))
//                 ],
//                 onChanged: (value) =>
//                     setDialogState(() => category = value ?? category)),
//             const SizedBox(height: 12),
//             const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text('Access granted',
//                     style: TextStyle(fontWeight: FontWeight.w700))),
//             for (final entry in accessOptions.entries)
//               CheckboxListTile(
//                   dense: true,
//                   contentPadding: EdgeInsets.zero,
//                   value: access.contains(entry.key),
//                   title: Text(entry.value),
//                   onChanged: (selected) => setDialogState(() {
//                         if (selected == true) {
//                           access.add(entry.key);
//                         } else {
//                           access.remove(entry.key);
//                         }
//                       })),
//           ]));
//         }),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel')),
//           FilledButton(
//               onPressed: () => Navigator.pop(dialogContext, {
//                     'userId': userId.text.trim(),
//                     'email': email.text.trim(),
//                     'name': name.text.trim(),
//                     'category': category,
//                     'access': access.toList(),
//                   }),
//               child: Text(existing == null ? 'Add admin' : 'Save changes')),
//         ],
//       ),
//     );
//     userId.dispose();
//     email.dispose();
//     name.dispose();
//     return result;
//   }

//   Future<void> _save(BuildContext context,
//       {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
//     final result = await _form(context, existing: existing);
//     if (result == null || result['userId'].toString().isEmpty) return;
//     try {
//       if (existing == null) {
//         await Db.addAdmin(
//             userId: result['userId'],
//             email: result['email'],
//             name: result['name'],
//             category: result['category'],
//             access: List<String>.from(result['access']));
//       } else {
//         await Db.updateAdmin(
//             userId: result['userId'],
//             email: result['email'],
//             name: result['name'],
//             category: result['category'],
//             access: List<String>.from(result['access']));
//       }
//     } on FirebaseException catch (error) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(error.message ?? 'Could not save admin')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) => FutureBuilder<bool>(
//         future: Db.isAdmin(),
//         builder: (context, adminSnapshot) {
//           final canManage = adminSnapshot.data == true;
//           return Scaffold(
//               appBar: const AdminBrandBar(title: 'Admin Management'),
//               floatingActionButton: canManage
//                   ? FloatingActionButton.extended(
//                       onPressed: () => _save(context),
//                       icon: const Icon(Icons.person_add_alt_1),
//                       label: const Text('Add admin'))
//                   : null,
//               body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                 stream: Db.adminUsers(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   return ListView(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
//                       children: [
//                         AdminPageIntro(
//                           eyebrow: 'Access control',
//                           title: 'Administrator directory',
//                           description: canManage
//                               ? 'Manage roles, categories and permissions across the admin team.'
//                               : 'You have view-only access to the administrator directory.',
//                           icon: Icons.manage_accounts_outlined,
//                         ),
//                         const SizedBox(height: 12),
//                         for (final doc in snapshot.data!.docs)
//                           _AdminListCard(
//                               doc: doc,
//                               canManage: canManage,
//                               onEdit: () => _save(context, existing: doc),
//                               onDelete: () async {
//                                 try {
//                                   await Db.removeAdmin(doc.id);
//                                 } on FirebaseException catch (error) {
//                                   if (context.mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                             content: Text(error.message ??
//                                                 'Could not delete admin')));
//                                   }
//                                 }
//                               })
//                       ]);
//                 },
//               ));
//         },
//       );
// }

// class _AdminListCard extends StatelessWidget {
//   final QueryDocumentSnapshot<Map<String, dynamic>> doc;
//   final bool canManage;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _AdminListCard(
//       {required this.doc,
//       required this.canManage,
//       required this.onEdit,
//       required this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     final data = doc.data();
//     final access =
//         (data['access'] as List?)?.whereType<String>().toList() ?? [];
//     return Card(
//         child: Padding(
//             padding: const EdgeInsets.all(8),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: const Icon(Icons.admin_panel_settings),
//                   title: Text(data['name']?.toString().isNotEmpty == true
//                       ? data['name'].toString()
//                       : doc.id),
//                   subtitle: Text('${data['email'] ?? ''}\nUID: ${doc.id}'),
//                   trailing: canManage
//                       ? Wrap(children: [
//                           IconButton(
//                               tooltip: 'Update details',
//                               icon: const Icon(Icons.edit_outlined),
//                               onPressed: onEdit),
//                           if (doc.id != uid)
//                             IconButton(
//                                 tooltip: 'Delete admin',
//                                 icon: const Icon(Icons.delete_outline),
//                                 onPressed: onDelete),
//                         ])
//                       : null),
//               Wrap(spacing: 6, children: [
//                 Chip(
//                     label:
//                         Text(data['category']?.toString() ?? 'Uncategorized'),
//                     visualDensity: VisualDensity.compact),
//                 for (final item in access)
//                   Chip(label: Text(item), visualDensity: VisualDensity.compact),
//               ])
//             ])));
//   }
// }

// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) => Chip(
//       label: Text(_statusLabel(status),
//           style: TextStyle(
//               color: _statusColor(status),
//               fontSize: 10,
//               fontWeight: FontWeight.w700)),
//       backgroundColor: _statusColor(status).withValues(alpha: 0.14),
//       side: BorderSide.none,
//       visualDensity: VisualDensity.compact);
// }

// String _statusLabel(String status) => switch (status) {
//       'pending' => 'Pending review',
//       'changes_requested' => 'Changes requested',
//       'approved' => 'Approved',
//       'suspended' => 'Suspended',
//       'rejected' => 'Rejected',
//       _ => status,
//     };

// Color _statusColor(String status) => switch (status) {
//       'approved' => Colors.green,
//       'suspended' => Colors.deepOrange,
//       'rejected' => Colors.red,
//       'changes_requested' => Colors.orange,
//       _ => Colors.blue,
//     };


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/db.dart';
import '../theme/app_theme.dart';
import 'admin_review_checklist_screen.dart';
import '../widgets/event_image.dart';
import 'event_gallery_screen.dart';
import '../widgets/admin_brand_bar.dart';
import '../widgets/admin_design.dart';

// ============================================================
// SHARED ADMIN UI (PRESENTATION ONLY)
// ============================================================

class _AdminWelcomeCard extends StatelessWidget {
  const _AdminWelcomeCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: AppColors.primary.withValues(alpha: .24)),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CEYLONA ADMIN', style: TextStyle(
            fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w700,
            color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Good to see you, Admin',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800, fontSize: 19,
              color: AppColors.primaryDark)),
          const SizedBox(height: 6),
          const Text('Keep events safe, accurate and ready to discover.',
            style: TextStyle(fontSize: 11, height: 1.5,
              color: AppColors.secondaryText)),
        ])),
      const SizedBox(width: 10),
      Container(width: 48, height: 48,
        decoration: BoxDecoration(color: AppColors.surface,
          borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.admin_panel_settings_rounded,
          size: 25, color: AppColors.primary)),
    ]),
  );
}

class _AdminSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _AdminSectionTitle({required this.icon, required this.title,
    required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 40, height: 40,
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppColors.primary, size: 20)),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700, fontSize: 15,
          color: AppColors.primaryDark)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: AppColors.secondaryText,
          fontSize: 10)),
      ])),
  ]);
}

class _AdminMetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AdminMetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 15, color: AppColors.primary),
    const SizedBox(width: 7),
    Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
  ]);
}

class _AdminDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AdminDetailRow({required this.icon, required this.label,
    required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 38, height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: AppColors.primary, size: 20)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.secondaryText,
          fontSize: 9, letterSpacing: .7, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.primaryDark,
          fontSize: 12, fontWeight: FontWeight.w700)),
      ])),
  ]);
}

class _AdminEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _AdminEmptyState({required this.title, required this.subtitle,
    required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Container(width: 70, height: 70,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12),
          shape: BoxShape.circle),
        child: Icon(icon, size: 32, color: AppColors.primary)),
      const SizedBox(height: 15),
      Text(title, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
          color: AppColors.primaryDark)),
      const SizedBox(height: 7),
      Text(subtitle, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, height: 1.5,
          color: AppColors.secondaryText)),
    ]),
  );
}

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
      data: AppTheme.light.copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          prefixIconColor: AppColors.primary,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.border,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryDark,
        ),
      ),
      child: Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: .22),
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          height: 73,
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.verified_outlined),
                selectedIcon: Icon(Icons.verified),
                label: 'Approvals'),
            NavigationDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist),
                label: 'Checklist'),
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Alerts'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final search = TextEditingController();
  String status = 'All statuses';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminBrandBar(title: 'Command centre'),
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
            final query = search.text.toLowerCase();
            final filtered = docs.where((doc) {
              final data = doc.data();
              final matchesStatus = status == 'All statuses' ||
                  data['status'] == status.toLowerCase();
              final text =
                  '${data['title'] ?? ''} ${data['organizerName'] ?? ''}'
                      .toLowerCase();
              return matchesStatus && text.contains(query);
            }).toList();
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                const _AdminWelcomeCard(),
                const SizedBox(height: 14),
                GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 117,
                    children: [
                      _StatCard(
                          label: 'Pending',
                          value: _count(docs, 'pending'),
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
                const SizedBox(height: 16),
                const _AdminSectionTitle(
                  icon: Icons.assignment_outlined,
                  title: 'Event Submissions',
                  subtitle: 'Search, filter and review event activity',
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search events or organizers',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                    initialValue: status,
                    isDense: true,
                    decoration: const InputDecoration(
                        labelText: 'Filter by status',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)))),
                    items: const [
                      'All statuses',
                      'Pending',
                      'Approved',
                      'Rejected',
                      'Changes_requested'
                    ]
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) => setState(() => status = value!)),
                const SizedBox(height: 12),
                Text('${filtered.length} submissions found',
                    style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _AdminEmptyState(
                    title: 'No submissions found',
                    subtitle: 'Try another search or status filter.',
                    icon: Icons.search_off_rounded,
                  ),
                for (final doc in filtered) _DashboardSubmissionCard(doc: doc),
              ],
            );
          },
        ),
      );

  static int _count(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
          String status) =>
      docs.where((doc) => doc.data()['status'] == status).length;
}

class _DashboardSubmissionCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _DashboardSubmissionCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final status = data['status']?.toString() ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EventImage(url: data['imageUrl']?.toString(), width: 76, height: 83,
            borderRadius: BorderRadius.circular(12)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title']?.toString() ?? 'Untitled event', maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
              const SizedBox(height: 5),
              Text('by ${data['organizerName'] ?? 'Unknown organizer'}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
              const SizedBox(height: 8),
              _StatusBadge(status: status),
            ])),
        ]),
        const SizedBox(height: 13),
        _AdminMetaRow(icon: Icons.category_outlined,
          text: data['category']?.toString() ?? 'Uncategorized'),
        const SizedBox(height: 7),
        _AdminMetaRow(icon: Icons.calendar_month_outlined,
          text: data['date']?.toString() ?? ''),
        const SizedBox(height: 7),
        _AdminMetaRow(icon: Icons.location_on_outlined,
          text: data['location']?.toString() ?? ''),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => AdminSubmissionDetailsScreen(id: doc.id, data: data))),
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: const Text('View Submission Details'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 43),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 33, height: 33,
          decoration: BoxDecoration(color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(_statIcon(label), size: 19, color: color)),
        const Spacer(),
        Container(width: 7, height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ]),
      const Spacer(),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('$value', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        const SizedBox(width: 8),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.secondaryText,
              fontSize: 11, fontWeight: FontWeight.w600)),
        )),
      ]),
    ]),
  );

  IconData _statIcon(String label) => switch (label) {
    'Pending' => Icons.pending_actions_rounded,
    'Approved' => Icons.verified_outlined,
    'Rejected' => Icons.cancel_outlined,
    _ => Icons.dashboard_outlined,
  };
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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            EventImage(url: data['imageUrl']?.toString(), width: 72, height: 82,
              borderRadius: BorderRadius.circular(12)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title']?.toString() ?? 'Untitled event',
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5,
                    fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                const SizedBox(height: 5),
                Text(data['organizerName']?.toString() ?? 'Unknown organizer',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                const SizedBox(height: 6),
                _AdminMetaRow(icon: Icons.calendar_month_outlined,
                  text: '${data['date'] ?? ''} • ${data['location'] ?? ''}'),
                const SizedBox(height: 7),
                _StatusBadge(status: status),
              ])),
            PopupMenuButton<String>(
              tooltip: 'Event actions',
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
              onSelected: (action) => _handleAction(doc, action),
              itemBuilder: (_) => [
                for (final action in actions)
                  PopupMenuItem(value: action,
                    child: Text(action == 'view' ? 'View details' : _actionLabel(action))),
              ],
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: statuses.length,
        child: Scaffold(
          appBar: const AdminBrandBar(
            title: 'Event Approvals',
            bottom: TabBar(
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AdminPageIntro(
                    eyebrow: 'Moderation queue',
                    title: 'Review submissions',
                    description:
                        'Make confident decisions and keep event quality high.',
                    icon: Icons.verified_outlined,
                  ),
                ),
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

  Future<void> decide(String status) async {
    final category = status == 'approved'
        ? 'approval'
        : status == 'rejected'
            ? 'rejection'
            : 'changes';
    final checklistSnapshot = await Db.reviewChecklistItems().first;
    if (!mounted) return;
    final checklistItems = checklistSnapshot.docs
        .where((doc) =>
            (doc.data()['category']?.toString() ?? 'approval') == category)
        .map((doc) => doc.data()['title']?.toString() ?? '')
        .where((title) => title.isNotEmpty)
        .toList();
    final selectedChecklist = <String>{};
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
                    Text(
                        '${status == 'approved' ? 'Approval' : status == 'rejected' ? 'Rejection' : 'Changes requested'} checklist',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (checklistItems.isEmpty)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No checklist items configured.')),
                    for (final item in checklistItems)
                      CheckboxListTile(
                          value: selectedChecklist.contains(item),
                          title: Text(item),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) => setDialogState(() =>
                              value == true
                                  ? selectedChecklist.add(item)
                                  : selectedChecklist.remove(item))),
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
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: selectedChecklist.length != checklistItems.length ||
                        (status != 'approved' && feedback.text.trim().isEmpty)
                    ? null
                    : () => Navigator.pop(dialogContext, true),
                child: const Text('Submit decision')),
          ],
        );
      }),
    );
    if (result != true) return;
    await _submitDecision(status, feedback.text.trim(),
        internalNotes.text.trim(), selectedChecklist.toList());
  }

  Future<void> _submitDecision(String status, String feedback,
      String internalNotes, List<String> checklistItems) async {
    try {
      await Db.reviewEvent(
          eventId: widget.id,
          status: status,
          feedback: feedback,
          internalNotes: internalNotes,
          checklistItems: checklistItems);
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
        appBar: AdminBrandBar(
            title: 'Submission Details', onBack: () => Navigator.pop(context)),
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
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const _AdminSectionTitle(icon: Icons.fact_check_outlined,
                  title: 'Submission Overview',
                  subtitle: 'Review all event information before a decision'),
                const SizedBox(height: 16),
                ClipRRect(borderRadius: BorderRadius.circular(18),
                  child: EventImage(url: event['imageUrl']?.toString(), height: 220)),
                const SizedBox(height: 12),
                Text(event['title']?.toString() ?? 'Untitled event',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark)),
                const SizedBox(height: 8),
                _StatusBadge(
                    status: currentStatus ?? event['status'] ?? 'pending'),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    _AdminDetailRow(icon: Icons.category_outlined, label: 'CATEGORY',
                      value: event['category']?.toString() ?? 'Uncategorized'),
                    const Divider(height: 22, color: AppColors.border),
                    _AdminDetailRow(icon: Icons.calendar_month_outlined, label: 'DATE & TIME',
                      value: '${event['date'] ?? ''} ${event['time'] ?? ''}'),
                    const Divider(height: 22, color: AppColors.border),
                    _AdminDetailRow(icon: Icons.location_on_outlined, label: 'LOCATION',
                      value: event['location']?.toString() ?? ''),
                    const Divider(height: 22, color: AppColors.border),
                    _AdminDetailRow(icon: Icons.person_outline, label: 'ORGANIZER',
                      value: event['organizerName']?.toString() ?? 'Unknown'),
                  ]),
                ),
                const SizedBox(height: 20),
                const _AdminSectionTitle(icon: Icons.article_outlined,
                  title: 'About this event',
                  subtitle: 'Description submitted by the organizer'),
                const SizedBox(height: 12),
                Container(width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border)),
                  child: Text(event['description']?.toString() ?? 'No description provided.',
                    style: const TextStyle(fontSize: 12, height: 1.7,
                      color: AppColors.secondaryText))),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EventGalleryScreen(
                                eventId: widget.id,
                                eventTitle: event['title'] ?? 'Event',
                                mode: GalleryMode.admin))),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Review event gallery')),
                const SizedBox(height: 20),
                const _AdminSectionTitle(icon: Icons.history_rounded,
                  title: 'Decision History',
                  subtitle: 'Recorded review and moderation actions'),
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
      appBar: const AdminBrandBar(title: 'Decision Complete'),
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

  Future<void> _openNotification(BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    await Db.markAdminNotificationRead(doc.id);
    final data = doc.data();
    if (data['action'] == 'gallery_submitted' &&
        data['eventId']?.toString().isNotEmpty == true &&
        context.mounted) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventGalleryScreen(
                  eventId: data['eventId'].toString(),
                  eventTitle: data['eventTitle']?.toString() ?? 'Event',
                  mode: GalleryMode.admin)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AdminBrandBar(title: 'Notifications'),
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
            final allDocs = snapshot.data!.docs;
            final docs = allDocs.where((doc) {
              if (filter == 0) return true;
              return filter == 1 && doc.data()['read'] != true || filter == 2;
            }).toList();
            return Column(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AdminPageIntro(
                  eyebrow: 'Activity centre',
                  title: 'Stay up to date',
                  description:
                      'Submission activity and content updates that need your attention.',
                  icon: Icons.notifications_active_outlined,
                ),
              ),
              if (allDocs.any((doc) => doc.data()['read'] != true))
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                        onPressed: () =>
                            Db.markAllAdminNotificationsRead(allDocs),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark all read'))),
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
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                if (docs.isEmpty)
                  const _AdminEmptyState(
                    title: 'No notifications',
                    subtitle: 'There is nothing to show in this category.',
                    icon: Icons.notifications_off_outlined,
                  ),
                for (final doc in docs)
                  Card(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                          leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: .12),
                              child: const Icon(Icons.notifications_none_rounded,
                                color: AppColors.primary)),
                          title: Text(doc.data()['title'] ?? 'Notification',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              '${doc.data()['eventTitle'] ?? 'Event'}\n${doc.data()['message'] ?? ''}'),
                          onTap: () => _openNotification(context, doc),
                          trailing: doc.data()['read'] == true
                              ? const Icon(Icons.chevron_right,
                                  color: AppColors.secondaryText)
                              : Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: .16),
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                      Icons.mark_email_unread_outlined,
                                      color: AppColors.primary,
                                      size: 18))))
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
      appBar: const AdminBrandBar(title: 'Admin Profile'),
      body: ListView(physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(children: [
            CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.admin_panel_settings,
                    size: 32, color: AppColors.primaryDark)),
            SizedBox(width: 14),
            Expanded(
                child: Text('Administrator workspace',
                    style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 12),
        Center(
            child: Text(user?.displayName ?? 'Authority Officer',
                style: Theme.of(context).textTheme.titleLarge)),
        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future:
                FirebaseFirestore.instance.collection('admins').doc(uid).get(),
            builder: (context, snapshot) {
              final role = snapshot.data?.data()?['role']?.toString();
              return Center(
                  child: Text(
                      role == 'admin_officer' ? 'Admin Officer' : 'Admin'));
            }),
        const SizedBox(height: 24),
        const AdminSectionLabel(
            title: 'Account settings',
            subtitle: 'Manage access and preferences'),
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
        OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminManagementScreen())),
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Manage admins')),
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

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  static const categories = [
    'Event Approvals',
    'Content Moderation',
    'User Management',
    'Reports & Analytics',
  ];
  static const accessOptions = {
    'approvals': 'Review event submissions',
    'checklist': 'Manage review checklist',
    'notifications': 'View admin notifications',
    'analytics': 'View reports and analytics',
  };

  Future<Map<String, dynamic>?> _form(BuildContext context,
      {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
    final userId = TextEditingController();
    final email = TextEditingController();
    final name = TextEditingController();
    final data = existing?.data();
    userId.text = existing?.id ?? '';
    email.text = data?['email']?.toString() ?? '';
    name.text = data?['name']?.toString() ?? '';
    var category = data?['category']?.toString() ?? categories.first;
    var access = {
      ...((data?['access'] as List?)?.whereType<String>() ?? const [])
    };
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add admin' : 'Update admin details'),
        content: StatefulBuilder(builder: (context, setDialogState) {
          return SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: userId,
                readOnly: existing != null,
                decoration: const InputDecoration(
                    labelText: 'Firebase Auth UID',
                    border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: name,
                decoration: const InputDecoration(
                    labelText: 'Admin name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Admin email', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                    labelText: 'Admin category', border: OutlineInputBorder()),
                items: [
                  for (final item in categories)
                    DropdownMenuItem(value: item, child: Text(item))
                ],
                onChanged: (value) =>
                    setDialogState(() => category = value ?? category)),
            const SizedBox(height: 12),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Access granted',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            for (final entry in accessOptions.entries)
              CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: access.contains(entry.key),
                  title: Text(entry.value),
                  onChanged: (selected) => setDialogState(() {
                        if (selected == true) {
                          access.add(entry.key);
                        } else {
                          access.remove(entry.key);
                        }
                      })),
          ]));
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, {
                    'userId': userId.text.trim(),
                    'email': email.text.trim(),
                    'name': name.text.trim(),
                    'category': category,
                    'access': access.toList(),
                  }),
              child: Text(existing == null ? 'Add admin' : 'Save changes')),
        ],
      ),
    );
    userId.dispose();
    email.dispose();
    name.dispose();
    return result;
  }

  Future<void> _save(BuildContext context,
      {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
    final result = await _form(context, existing: existing);
    if (result == null || result['userId'].toString().isEmpty) return;
    try {
      if (existing == null) {
        await Db.addAdmin(
            userId: result['userId'],
            email: result['email'],
            name: result['name'],
            category: result['category'],
            access: List<String>.from(result['access']));
      } else {
        await Db.updateAdmin(
            userId: result['userId'],
            email: result['email'],
            name: result['name'],
            category: result['category'],
            access: List<String>.from(result['access']));
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Could not save admin')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: Db.isAdmin(),
        builder: (context, adminSnapshot) {
          final canManage = adminSnapshot.data == true;
          return Scaffold(
              appBar: const AdminBrandBar(title: 'Admin Management'),
              floatingActionButton: canManage
                  ? FloatingActionButton.extended(
                      onPressed: () => _save(context),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add admin'))
                  : null,
              body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: Db.adminUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      children: [
                        AdminPageIntro(
                          eyebrow: 'Access control',
                          title: 'Administrator directory',
                          description: canManage
                              ? 'Manage roles, categories and permissions across the admin team.'
                              : 'You have view-only access to the administrator directory.',
                          icon: Icons.manage_accounts_outlined,
                        ),
                        const SizedBox(height: 12),
                        for (final doc in snapshot.data!.docs)
                          _AdminListCard(
                              doc: doc,
                              canManage: canManage,
                              onEdit: () => _save(context, existing: doc),
                              onDelete: () async {
                                try {
                                  await Db.removeAdmin(doc.id);
                                } on FirebaseException catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(error.message ??
                                                'Could not delete admin')));
                                  }
                                }
                              })
                      ]);
                },
              ));
        },
      );
}

class _AdminListCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminListCard(
      {required this.doc,
      required this.canManage,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final access =
        (data['access'] as List?)?.whereType<String>().toList() ?? [];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.primary)),
                  title: Text(data['name']?.toString().isNotEmpty == true
                      ? data['name'].toString()
                      : doc.id),
                  subtitle: Text('${data['email'] ?? ''}\nUID: ${doc.id}'),
                  trailing: canManage
                      ? Wrap(children: [
                          IconButton(
                              tooltip: 'Update details',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: onEdit),
                          if (doc.id != uid)
                            IconButton(
                                tooltip: 'Delete admin',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: onDelete),
                        ])
                      : null),
              Wrap(spacing: 6, children: [
                Chip(
                    label:
                        Text(data['category']?.toString() ?? 'Uncategorized'),
                    visualDensity: VisualDensity.compact),
                for (final item in access)
                  Chip(label: Text(item), visualDensity: VisualDensity.compact),
              ])
            ])));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _statusColor(status).withValues(alpha: .11),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(
        color: _statusColor(status), shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Flexible(child: Text(_statusLabel(status),
        style: TextStyle(color: _statusColor(status), fontSize: 10,
          fontWeight: FontWeight.w700))),
    ]),
  );
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