import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'cloudinary_config.dart';

final _db = FirebaseFirestore.instance;
String get uid => FirebaseAuth.instance.currentUser!.uid;
String get userName => FirebaseAuth.instance.currentUser?.displayName ?? 'User';

class Db {
  static DocumentReference<Map<String, dynamic>> userRef(String userId) =>
      _db.collection('users').doc(userId);

  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) throw StateError('Registration did not create a user.');
    await user.updateDisplayName(name);
    await ensureUserProfile(name: name, email: email);
  }

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

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminUsers() =>
      _db.collection('admins').snapshots();

  static Future<void> addAdmin({
    required String userId,
    required String email,
    required String name,
  }) =>
      _db.collection('admins').doc(userId.trim()).set({
        'email': email.trim(),
        'name': name.trim(),
        'role': 'authority_officer',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });

  static Future<void> removeAdmin(String userId) =>
      _db.collection('admins').doc(userId).delete();

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminEvents() =>
      _db.collection('events').orderBy('created', descending: true).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> adminNotifications() =>
      _db.collection('admin_notifications').orderBy('createdAt', descending: true).snapshots();

  static Future<void> markAdminNotificationRead(String id) =>
      _db.collection('admin_notifications').doc(id).update({'read': true});

  static Future<void> markAllAdminNotificationsRead(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> notifications) async {
    final batch = _db.batch();
    for (final notification in notifications) {
      if (notification.data()['read'] != true) {
        batch.update(notification.reference, {'read': true});
      }
    }
    await batch.commit();
  }

  static Future<void> reviewEvent({
    required String eventId,
    required String status,
    String? feedback,
    String? internalNotes,
    List<String>? checklistItems,
  }) =>
      transitionEvent(
        eventId: eventId,
        status: status,
        reason: feedback,
        action: status == 'approved' ? 'approved' : status,
        internalNotes: internalNotes,
        checklistItems: checklistItems,
      );

  static Future<void> transitionEvent({
    required String eventId,
    required String status,
    required String action,
    String? reason,
    String? internalNotes,
    List<String>? checklistItems,
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
      if (checklistItems != null) 'decisionChecklist': checklistItems,
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
  static Stream<QuerySnapshot<Map<String, dynamic>>> eventGallery(
        String eventId,
        {bool includePending = false, bool organizerOnly = false}) =>
      organizerOnly
        ? _db
          .collection('events')
          .doc(eventId)
          .collection('gallery')
          .where('uploadedBy', isEqualTo: uid)
          .snapshots()
        : includePending
        ? _db
          .collection('events')
          .doc(eventId)
          .collection('gallery')
          .snapshots()
            : _db
              .collection('events')
              .doc(eventId)
              .collection('gallery')
              .where('status', isEqualTo: 'approved')
              .snapshots();

  static Future<void> addGalleryImage(
      String eventId, String imageUrl, String caption) async {
    await _db.collection('events').doc(eventId).collection('gallery').add({
      'imageUrl': imageUrl,
      'caption': caption.trim(),
      'status': 'pending',
      'uploadedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final event = await eventOnce(eventId);
    await _db.collection('admin_notifications').add({
      'eventId': eventId,
      'eventTitle': event.data()?['title'] ?? 'Event',
      'action': 'gallery_submitted',
      'message': 'A new gallery image is waiting for approval.',
      'organizerId': uid,
      'organizerName': userName,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> reviewGalleryImage(
      String eventId, String imageId, String status) async {
    final image = await _db
        .collection('events')
        .doc(eventId)
        .collection('gallery')
        .doc(imageId)
        .get();
    await image.reference.update({
      'status': status,
      'reviewedBy': uid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    final event = await eventOnce(eventId);
    final organizerId = event.data()?['organizerId']?.toString();
    if (organizerId != null && organizerId.isNotEmpty) {
      await userRef(organizerId).collection('notifications').add({
        'title': 'Gallery image ${status == 'approved' ? 'approved' : 'rejected'}',
        'message': 'An admin reviewed a gallery image for "${event.data()?['title'] ?? 'your event'}".',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  static Future<void> deleteGalleryImage(String eventId, String imageId) =>
      _db.collection('events').doc(eventId).collection('gallery').doc(imageId).delete();
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
    final event = await _db.collection('events').add({
      ...d,
      'organizerId': uid,
      'organizerName': userName,
      'status': status,
      'created': FieldValue.serverTimestamp(),
    });
    await _notifyAdmins(event.id, d['title']?.toString() ?? 'Untitled event',
        'created', 'A new event was submitted for review.');
    return event;
  }

  static Future<void> updateEvent(String id, Map<String, dynamic> d,
      {String? status}) async {
    final ref = _db.collection('events').doc(id);
    final existing = (await ref.get()).data() ?? <String, dynamic>{};
    final wasApproved = existing['status'] == 'approved';
    await ref.update({
        ...d,
        'status': wasApproved ? 'pending' : (status ?? existing['status'] ?? 'draft'),
        if (wasApproved) 'previousStatus': 'approved',
        if (wasApproved) 'resubmittedAt': FieldValue.serverTimestamp(),
      });
    await _notifyAdmins(
        id,
        d['title']?.toString() ?? existing['title']?.toString() ?? 'Untitled event',
        wasApproved ? 'updated_approved' : 'updated',
        wasApproved
            ? 'An approved event was edited and needs re-approval.'
            : 'An organizer updated an event.');
  }

  static Future<void> publishEvent(String id) async {
    final event = await eventOnce(id);
    await _db.collection('events').doc(id).update({
        'status': 'pending',
        'publishedAt': FieldValue.serverTimestamp(),
      });
    await _notifyAdmins(id, event.data()?['title']?.toString() ?? 'Untitled event',
        'submitted', 'An organizer submitted an event for review.');
  }

  static Future<void> deleteEvent(String id) async {
    final event = await eventOnce(id);
    await _db.collection('events').doc(id).delete();
    await _notifyAdmins(id, event.data()?['title']?.toString() ?? 'Untitled event',
        'deleted', 'An organizer deleted an event.');
  }

  static Future<void> _notifyAdmins(
      String eventId, String eventTitle, String action, String message) =>
      _db.collection('admin_notifications').add({
        'eventId': eventId,
        'eventTitle': eventTitle,
        'action': action,
        'message': message,
        'organizerId': uid,
        'organizerName': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
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
  static Future<void> addReviewChecklistItem(String title,
          {String category = 'approval'}) =>
      _db.collection('review_checklist_items').add({
        'title': title.trim(),
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });
  static Future<void> updateReviewChecklistItem(String id, String title,
          {String category = 'approval'}) =>
      _db.collection('review_checklist_items').doc(id).update({
        'title': title.trim(),
        'category': category,
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
  static Future<void> setReminder(
          String eventId, String eventTitle, DateTime time) =>
      _db.collection('users').doc(uid).collection('reminders').doc(eventId).set({
        'eventId': eventId,
        'eventTitle': eventTitle,
        'time': Timestamp.fromDate(time),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  static Future<void> updateReminder(
          String eventId, String eventTitle, DateTime newTime) =>
      setReminder(eventId, eventTitle, newTime);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> reminderForEvent(
          String eventId) =>
      _db.collection('users').doc(uid).collection('reminders').doc(eventId).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> allReminders() =>
      _db.collection('users').doc(uid).collection('reminders').orderBy('time').snapshots();

  static Future<void> removeReminder(String eventId) =>
      _db.collection('users').doc(uid).collection('reminders').doc(eventId).delete();

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

    static Future<String> uploadImage(
      Uint8List bytes, String extension, {String folder = 'profiles'}) async {
    if (!CloudinaryConfig.isConfigured) {
      throw StateError(
          'Configure Cloudinary cloud name and unsigned upload preset first.');
    }
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes(
          'file', bytes,
          filename: 'profile.$extension'));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Cloudinary upload failed: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    final url = data['secure_url']?.toString();
    if (url == null || url.isEmpty) {
      throw StateError('Cloudinary did not return an image URL.');
    }
    return url;
  }

  static Future<String> uploadProfileImage(
          Uint8List bytes, String extension) =>
      uploadImage(bytes, extension);

  static Future<void> updateProfile({
    required String name,
    required String phone,
    required String city,
    required String bio,
    String? photoUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.updateDisplayName(name);
    await userRef(user.uid).set({
      'name': name,
      'phone': phone,
      'city': city,
      'bio': bio,
      if (photoUrl != null) 'photoUrl': photoUrl,
    }, SetOptions(merge: true));
  }

  static Future<void> deleteAccount({required String password}) async {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('This account cannot be re-authenticated here.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    final batch = _db.batch();
    final profile = userRef(user.uid);
    final saved = await profile.collection('saved').get();
    final notifications = await profile.collection('notifications').get();
    for (final document in [...saved.docs, ...notifications.docs]) {
      batch.delete(document.reference);
    }
    batch.delete(profile);
    await batch.commit();
    await user.delete();
  }
}
