# Ceylona - Local Event & Festival Discovery App (IT3060 Milestone 03)
Flutter + Firebase (Auth, Firestore).

## Setup
1. Install Flutter SDK (3.x) and run `flutter doctor`.
2. Create a Firebase project; enable Email/Password auth and Firestore (test mode).
3. `dart pub global activate flutterfire_cli` then `flutterfire configure` (overwrites lib/firebase_options.dart).
4. If android/ios folders are missing: `flutter create .` inside this folder (keeps lib/ and pubspec).
5. `flutter pub get` then `flutter run`. APK: `flutter build apk`.

## Firestore structure
events/{id} (+ comments subcollection), users/{uid}/saved/{eventId}, users/{uid}.
Event lifecycle: organizer creates -> status "pending" -> admin approves/rejects -> visible on Home when "approved".

## CRUD map
Events: create/edit/delete (Organizer), read (Home). Saved: create/read/delete. Comments: create/read/delete. Profile: update. Approvals: update status.

## Not yet implemented
Map, calendar/reminders, notifications, gallery, analytics, multilingual, role-based nav. Add per member workload.
