import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final _db = FirebaseFirestore.instance;
String get uid => FirebaseAuth.instance.currentUser!.uid;
String get userName => FirebaseAuth.instance.currentUser?.displayName ?? 'User';

class Db {
  static DocumentReference<Map<String, dynamic>> userRef(String userId) =>
      _db.collection('users').doc(userId);

  static Future<void> ensureUserProfile({String? name, String? email}) async {
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
      (await _db.collection('admins').doc(userId ?? uid).get()).exists;

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminEvents() =>
      _db.collection('events').orderBy('created', descending: true).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminNotifications() => _db
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
    final event = (await eventRef.get()).data() ?? <String, dynamic>{};
    final cleanStatus = status.trim().toLowerCase();
    final cleanAction = action.trim().toLowerCase();
    debugPrint(
        'Admin decision: eventId=$eventId status=$cleanStatus action=$cleanAction');
    final admin = FirebaseAuth.instance.currentUser;
    final adminName = admin?.displayName ?? admin?.email ?? 'Authority Officer';
    final cleanReason = reason?.trim() ?? '';
    final timestamp = FieldValue.serverTimestamp();

    final logRef = eventRef.collection('decision_log').doc();
    await eventRef.update({
      'status': cleanStatus,
      'adminFeedback': cleanReason,
      'internalNotes': internalNotes?.trim() ?? '',
      'reviewedBy': uid,
      'reviewedByName': adminName,
      'reviewedAt': timestamp,
      'lastDecisionAction': cleanAction,
      'lastDecisionReason': cleanReason,
    });
    final savedStatus = (await eventRef.get())
        .data()?['status']
        ?.toString()
        .trim()
        .toLowerCase();
    debugPrint('Admin decision saved: eventId=$eventId status=$savedStatus');
    if (savedStatus != cleanStatus) {
      throw StateError(
          'Event status was not saved. Expected $cleanStatus, got $savedStatus.');
    }
    await logRef.set({
      'admin': adminName,
      'adminId': uid,
      'action': cleanAction,
      'reason': cleanReason,
      'timestamp': timestamp,
    });
    final title = event['title'] ?? 'your event';
    final message = switch (cleanAction) {
      'approved' => 'Your event "$title" has been approved.',
      'changes_requested' =>
        'Changes are requested for "$title". ${cleanReason.isEmpty ? '' : 'Reason: $cleanReason'}',
      'rejected' =>
        'Your event "$title" was rejected. ${cleanReason.isEmpty ? '' : 'Reason: $cleanReason'}',
      'suspended' =>
        'Your event "$title" has been suspended. Reason: $cleanReason',
      'revoked' =>
        'Approval for "$title" has been revoked. Reason: $cleanReason',
      're-approved' =>
        'Your event "$title" has been reinstated and is public again.',
      _ => 'Your event "$title" was updated by an administrator.',
    };
    final organizerId = event['organizerId'];
    if (organizerId is String && organizerId.isNotEmpty) {
      try {
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
      } on FirebaseException catch (error) {
        debugPrint('Organizer notification failed: ${error.code}');
      }
    }

    if (cleanAction == 'suspended' ||
        cleanAction == 'revoked' ||
        cleanAction == 're-approved') {
      final saved = await _db
          .collectionGroup('saved')
          .where(FieldPath.documentId, isEqualTo: eventId)
          .get();
      await Future.wait(saved.docs
          .where((doc) => doc.reference.parent.parent?.id != organizerId)
          .map((doc) {
        final seekerId = doc.reference.parent.parent!.id;
        return _db
            .collection('users')
            .doc(seekerId)
            .collection('notifications')
            .add({
          'title': cleanAction == 're-approved'
              ? 'Saved event reinstated'
              : 'Saved event unavailable',
          'message': cleanAction == 're-approved'
              ? '"$title" has been reinstated and is public again.'
              : '"$title" has been ${cleanAction == 'suspended' ? 'suspended' : 'removed from public listings'}.',
          'createdAt': timestamp,
          'read': false,
        });
      }));
    }
  }

  static Future<Map<String, dynamic>> appAccess() async {
    final admin = await isAdmin();
    if (!admin) {
      await ensureUserProfile();
    }
    final profile = await userProfile();
    return {
      'profile': profile.data() ?? <String, dynamic>{},
      'isAdmin': admin,
    };
  }

  static Future<void> becomeOrganizer(String organizationName) async {
    await userRef(uid).set({
      'isOrganizer': true,
      'organizationName': organizationName,
      'role': 'organizer',
    }, SetOptions(merge: true));
  }

  static Future<void> ensureOrganizerAccess() async {
    await ensureUserProfile();
    final profile = await userProfile();
    if (profile.data()?['isOrganizer'] == true) return;
    await becomeOrganizer('Independent organizer');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> approvedEvents() => _db
      .collection('events')
      .where('status', isEqualTo: 'approved')
      .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> myEvents() =>
      _db.collection('events').where('organizerId', isEqualTo: uid).snapshots();
  static Stream<DocumentSnapshot<Map<String, dynamic>>> event(String eventId) =>
      _db.collection('events').doc(eventId).snapshots();
  static Future<DocumentSnapshot<Map<String, dynamic>>> eventOnce(
          String eventId) =>
      _db.collection('events').doc(eventId).get();
  static Stream<QuerySnapshot<Map<String, dynamic>>> pendingEvents() => _db
      .collection('events')
      .where('status', isEqualTo: 'pending')
      .snapshots();
  static Future<DocumentReference<Map<String, dynamic>>> createEvent(
      Map<String, dynamic> d,
      {String status = 'pending'}) async {
    await ensureOrganizerAccess();
    return _db.collection('events').add({
      ...d,
      'organizerId': uid,
      'organizerName': userName,
      'status': status,
      'created': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateEvent(String id, Map<String, dynamic> d,
          {String? status}) =>
      _db.collection('events').doc(id).update({
        ...d,
        if (status != null) 'status': status,
      });
  static Future<void> publishEvent(String id) =>
      _db.collection('events').doc(id).update({
        'status': 'pending',
        'publishedAt': FieldValue.serverTimestamp(),
      });
  static Future<void> deleteEvent(String id) =>
      _db.collection('events').doc(id).delete();
  static Future<void> setStatus(String id, String status) =>
      _db.collection('events').doc(id).update({'status': status});
  static Future<void> saveReviewChecklist(
          String eventId, List<bool> checks, String notes) =>
      _db.collection('events').doc(eventId).update({
        'reviewChecklist': checks,
        'reviewNotes': notes.trim(),
        'reviewChecklistUpdatedAt': FieldValue.serverTimestamp(),
      });
  static Future<void> deleteReviewChecklist(String eventId) =>
      _db.collection('events').doc(eventId).update({
        'reviewChecklist': FieldValue.delete(),
        'reviewNotes': FieldValue.delete(),
        'reviewChecklistUpdatedAt': FieldValue.delete(),
      });
  static Stream<QuerySnapshot<Map<String, dynamic>>> reviewChecklistItems() =>
      _db.collection('review_checklist_items').orderBy('createdAt').snapshots();
  static Future<void> addReviewChecklistItem(String title) =>
      _db.collection('review_checklist_items').add({
        'title': title.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });
  static Future<void> updateReviewChecklistItem(String id, String title) =>
      _db.collection('review_checklist_items').doc(id).update({
        'title': title.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': uid,
      });
  static Future<void> deleteReviewChecklistItem(String id) =>
      _db.collection('review_checklist_items').doc(id).delete();
  static Future<void> addAgendaItem(
          String eventId, String time, String activity) =>
      _db.collection('events').doc(eventId).update({
        'agenda': FieldValue.arrayUnion([
          {'time': time, 'activity': activity}
        ]),
      });
  static Future<void> removeAgendaItem(
          String eventId, Map<String, dynamic> item) =>
      _db.collection('events').doc(eventId).update({
        'agenda': FieldValue.arrayRemove([item])
      });
  static Future<void> setFacility(String eventId, String key, String note) =>
      _db.collection('events').doc(eventId).update({'facilities.$key': note});
  static Future<void> removeFacility(String eventId, String key) => _db
      .collection('events')
      .doc(eventId)
      .update({'facilities.$key': FieldValue.delete()});

  static Stream<QuerySnapshot<Map<String, dynamic>>> saved() =>
      _db.collection('users').doc(uid).collection('saved').snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> notifications() => _db
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots();
  static Future<void> saveEvent(String id, Map<String, dynamic> d) =>
      _db.collection('users').doc(uid).collection('saved').doc(id).set(d);
  static Future<void> unsaveEvent(String id) =>
      _db.collection('users').doc(uid).collection('saved').doc(id).delete();
  static Future<void> saveReminder(
          String id, int minutesBefore, DateTime reminderAt) =>
      _db.collection('users').doc(uid).collection('saved').doc(id).set({
        'reminderMinutesBefore': minutesBefore,
        'reminderAt': Timestamp.fromDate(reminderAt),
      }, SetOptions(merge: true));
  static Future<void> removeReminder(String id) async {
    await _db.collection('users').doc(uid).collection('saved').doc(id).update({
      'reminderMinutesBefore': FieldValue.delete(),
      'reminderAt': FieldValue.delete(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> comments(String eventId) =>
      _db
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .orderBy('time', descending: true)
          .snapshots();
  static Future<void> addComment(String eventId, String text) =>
      _db.collection('events').doc(eventId).collection('comments').add({
        'text': text,
        'userId': uid,
        'userName': userName,
        'time': FieldValue.serverTimestamp()
      });
  static Future<void> deleteComment(String eventId, String id) => _db
      .collection('events')
      .doc(eventId)
      .collection('comments')
      .doc(id)
      .delete();

  static Future<void> updateName(String name) async {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
    await _db
        .collection('users')
        .doc(uid)
        .set({'name': name}, SetOptions(merge: true));
  }
}
