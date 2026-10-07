
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryColor = Color(0xFFFFC107);

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>>? get notificationCollection {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  Future<void> markAsRead(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    try {
      await reference.update({
        'isRead': true,
        'read': true,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update notification: $e')),
      );
    }
  }

  Future<void> deleteNotification(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    try {
      await reference.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete notification: $e')),
      );
    }
  }

  String timeAgo(dynamic timestamp) {
    if (timestamp is! Timestamp) return '';

    final difference =
        DateTime.now().difference(timestamp.toDate());

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }

    return 'Just now';
  }

  bool matchesFilter(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();

    if (selectedFilter == 'Reminders') {
      return type == 'reminder';
    }

    if (selectedFilter == 'Updates') {
      return type != 'reminder';
    }

    return true;
  }

  void showNotificationDetails(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
  ) {
    markAsRead(reference);

    final title = (data['title'] ?? 'Notification').toString();
    final message = (data['message'] ?? '').toString();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7EBDD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: primaryColor,
            size: 38,
          ),
          title: Text(title),
          content: Text(
            message.isEmpty
                ? 'No additional details available.'
                : message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await deleteNotification(reference);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildFilter(String label) {
    final isSelected = selectedFilter == label;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              selectedFilter = label;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isSelected ? primaryColor : Colors.white,
            foregroundColor:
                isSelected ? Colors.black : Colors.grey.shade700,
            side: const BorderSide(color: primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final title = (data['title'] ?? 'Notification').toString();
    final message = (data['message'] ?? '').toString();
    final type = (data['type'] ?? 'update').toString();
    final isRead = data['isRead'] == true || data['read'] == true;
    final reminder = type.toLowerCase() == 'reminder';

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: primaryColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showNotificationDetails(
          document.reference,
          data,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFFFF2CC),
                child: Icon(
                  reminder
                      ? Icons.notifications_active_outlined
                      : Icons.campaign_outlined,
                  color: primaryColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo(data['createdAt']),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addTestReminder() async {
    final collection = notificationCollection;

    if (collection == null) return;

    try {
      await collection.add({
        'title': 'Event Reminder',
        'message': 'Music Carnival 2025 - Today, 10:00 AM',
        'type': 'reminder',
        'isRead': false,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test reminder created successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = notificationCollection;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add test reminder',
                    onPressed:
                        collection == null ? null : addTestReminder,
                    icon: const Icon(
                      Icons.add_alert,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  buildFilter('All'),
                  buildFilter('Updates'),
                  buildFilter('Reminders'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: collection == null
                  ? const Center(
                      child: Text(
                        'Please sign in to view notifications.',
                      ),
                    )
                  : StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                      stream: collection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Could not load notifications. Please try again.',
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          );
                        }

                        final documents = snapshot.data?.docs ?? [];

                        final filteredDocuments = documents
                            .where(
                              (document) =>
                                  matchesFilter(document.data()),
                            )
                            .toList();

                        filteredDocuments.sort((a, b) {
                          final aTime = a.data()['createdAt'];
                          final bTime = b.data()['createdAt'];

                          final aDate = aTime is Timestamp
                              ? aTime.toDate()
                              : DateTime(2000);

                          final bDate = bTime is Timestamp
                              ? bTime.toDate()
                              : DateTime(2000);

                          return bDate.compareTo(aDate);
                        });

                        if (filteredDocuments.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 58,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'You are all caught up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No notifications available.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tap the alert icon above to test a reminder.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 20,
                          ),
                          itemCount: filteredDocuments.length,
                          itemBuilder: (context, index) {
                            return buildNotificationCard(
                              filteredDocuments[index],
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
}
