import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _db = FirebaseFirestore.instance;

String get uid => FirebaseAuth.instance.currentUser!.uid;

String get userName =>
    FirebaseAuth.instance.currentUser?.displayName ?? 'User';

class Db {
  // --------------------------------------------------
  // USER
  // --------------------------------------------------

  static DocumentReference<Map<String, dynamic>> userRef(String userId) =>
      _db.collection('users').doc(userId);

  static Future<void> ensureUserProfile({
    String? name,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = userRef(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists) return;

    await ref.set({
      'name': name ?? user.displayName ?? 'User',
      'email': email ?? user.email ?? '',
      'role': 'seeker',
      'isOrganizer': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> userProfile() =>
      userRef(uid).get();

  static Future<bool> isAdmin({String? userId}) async =>
      (await _db
              .collection('admins')
              .doc(userId ?? uid)
              .get())
          .exists;

  // --------------------------------------------------
  // ADMIN
  // --------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminEvents() =>
      _db
          .collection('events')
          .orderBy('created', descending: true)
          .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      adminNotifications() =>
          _db
              .collection('admins')
              .doc(uid)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots();

  static Future<void> reviewEvent({
    required String eventId,
    required String status,
    String? feedback,
    String? internalNotes,
  }) =>
      transitionEvent(
        eventId: eventId,
        status: status,
        reason: feedback,
        action: status == 'approved' ? 'approved' : status,
        internalNotes: internalNotes,
      );

  static Future<void> transitionEvent({
    required String eventId,
    required String status,
    required String action,
    String? reason,
    String? internalNotes,
  }) async {
    final eventRef = _db.collection('events').doc(eventId);

    final event =
        (await eventRef.get()).data() ?? <String, dynamic>{};

    final admin = FirebaseAuth.instance.currentUser;

    final adminName =
        admin?.displayName ??
        admin?.email ??
        'Authority Officer';

    final cleanReason = reason?.trim() ?? '';

    final timestamp = FieldValue.serverTimestamp();

    final logRef =
        eventRef.collection('decision_log').doc();

    final batch = _db.batch();

    batch.update(eventRef, {
      'status': status,
      'adminFeedback': cleanReason,
      'internalNotes': internalNotes?.trim() ?? '',
      'reviewedBy': uid,
      'reviewedByName': adminName,
      'reviewedAt': timestamp,
      'lastDecisionAction': action,
      'lastDecisionReason': cleanReason,
    });

    batch.set(logRef, {
      'admin': adminName,
      'adminId': uid,
      'action': action,
      'reason': cleanReason,
      'timestamp': timestamp,
    });

    await batch.commit();

    final title = event['title'] ?? 'your event';

    final message = switch (action) {
      'approved' =>
        'Your event "$title" has been approved.',

      'changes_requested' =>
        'Changes are requested for "$title". '
            '${cleanReason.isEmpty ? '' : 'Reason: $cleanReason'}',

      'rejected' =>
        'Your event "$title" was rejected. '
            '${cleanReason.isEmpty ? '' : 'Reason: $cleanReason'}',

      'suspended' =>
        'Your event "$title" has been suspended. '
            'Reason: $cleanReason',

      'revoked' =>
        'Approval for "$title" has been revoked. '
            'Reason: $cleanReason',

      're-approved' =>
        'Your event "$title" has been reinstated and is public again.',

      _ =>
        'Your event "$title" was updated by an administrator.',
    };

    final organizerId = event['organizerId'];

    if (organizerId is String && organizerId.isNotEmpty) {
      await _db
          .collection('users')
          .doc(organizerId)
          .collection('notifications')
          .add({
        'title': 'Event status updated',
        'message': message,
        'createdAt': timestamp,
        'read': false,
      });
    }

    if (action == 'suspended' ||
        action == 'revoked' ||
        action == 're-approved') {
      final saved = await _db
          .collectionGroup('saved')
          .where(
            FieldPath.documentId,
            isEqualTo: eventId,
          )
          .get();

      await Future.wait(
        saved.docs
            .where(
              (doc) =>
                  doc.reference.parent.parent?.id != organizerId,
            )
            .map((doc) {
          final seekerId =
              doc.reference.parent.parent!.id;

          return _db
              .collection('users')
              .doc(seekerId)
              .collection('notifications')
              .add({
            'title': action == 're-approved'
                ? 'Saved event reinstated'
                : 'Saved event unavailable',
            'message': action == 're-approved'
                ? '"$title" has been reinstated and is public again.'
                : '"$title" has been ${action == 'suspended' ? 'suspended' : 'removed from public listings'}.',
            'createdAt': timestamp,
            'read': false,
          });
        }),
      );
    }
  }

  // --------------------------------------------------
  // APP ACCESS
  // --------------------------------------------------

  static Future<Map<String, dynamic>> appAccess() async {
    await ensureUserProfile();

    final profile = await userProfile();

    return {
      'profile': profile.data() ?? <String, dynamic>{},
      'isAdmin': await isAdmin(),
    };
  }

  static Future<void> becomeOrganizer(
      String organizationName) async {
    await userRef(uid).set({
      'isOrganizer': true,
      'organizationName': organizationName,
      'role': 'organizer',
    }, SetOptions(merge: true));
  }

  // --------------------------------------------------
  // EVENTS
  // --------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      approvedEvents() =>
          _db
              .collection('events')
              .where('status', isEqualTo: 'approved')
              .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      myEvents() =>
          _db
              .collection('events')
              .where('organizerId', isEqualTo: uid)
              .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      pendingEvents() =>
          _db
              .collection('events')
              .where('status', isEqualTo: 'pending')
              .snapshots();

  static Future<void> createEvent(
      Map<String, dynamic> d) =>
      _db.collection('events').add({
        ...d,
        'organizerId': uid,
        'organizerName': userName,
        'status': 'pending',
        'created': FieldValue.serverTimestamp(),
      });

  static Future<void> updateEvent(
      String id,
      Map<String, dynamic> d) =>
      _db.collection('events').doc(id).update({
        ...d,
        'status': 'pending',
      });

  static Future<void> deleteEvent(String id) =>
      _db.collection('events').doc(id).delete();

  static Future<void> setStatus(
      String id,
      String status) =>
      _db.collection('events').doc(id).update({
        'status': status,
      });

  // --------------------------------------------------
  // SAVED EVENTS
  // --------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>> saved() =>
      _db
          .collection('users')
          .doc(uid)
          .collection('saved')
          .snapshots();

  static Future<void> saveEvent(
      String id,
      Map<String, dynamic> d) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('saved')
          .doc(id)
          .set(d);

  static Future<void> unsaveEvent(String id) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('saved')
          .doc(id)
          .delete();

  // --------------------------------------------------
  // NOTIFICATIONS
  // --------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      notifications() =>
          _db
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .snapshots();

  // UPDATE - Mark notification as read
  static Future<void> markNotificationAsRead(
      String notificationId) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
      });

  // DELETE - Delete notification
  static Future<void> deleteNotification(
      String notificationId) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();

  // --------------------------------------------------
  // COMMENTS / EVENT DISCUSSION
  // --------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      comments(String eventId) =>
          _db
              .collection('events')
              .doc(eventId)
              .collection('comments')
              .orderBy(
                'time',
                descending: true,
              )
              .snapshots();

  static Future<void> addComment(
      String eventId,
      String text) =>
      _db
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .add({
        'text': text,
        'userId': uid,
        'userName': userName,
        'time': FieldValue.serverTimestamp(),
      });

  static Future<void> deleteComment(
      String eventId,
      String id) =>
      _db
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(id)
          .delete();

  // --------------------------------------------------
  // PROFILE
  // --------------------------------------------------

  static Future<void> updateName(String name) async {
    await FirebaseAuth.instance.currentUser!
        .updateDisplayName(name);

    await _db
        .collection('users')
        .doc(uid)
        .set(
      {
        'name': name,
      },
      SetOptions(merge: true),
    );
  }
}