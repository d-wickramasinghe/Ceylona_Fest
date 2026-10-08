# Ceylona - Local Event & Festival Discovery App (IT3060 Milestone 03)
Flutter + Firebase (Auth, Firestore, Storage).

## Setup
1. Install Flutter SDK (3.x) and run `flutter doctor`.
2. Create a Firebase project; enable Email/Password auth, Firestore, and Storage.
3. `dart pub global activate flutterfire_cli` then `flutterfire configure` (overwrites lib/firebase_options.dart).
4. If android/ios folders are missing: `flutter create .` inside this folder (keeps lib/ and pubspec).
5. `flutter pub get` then `flutter run`. APK: `flutter build apk`.
6. Deploy the included Firebase rules with `firebase deploy --only firestore:rules,storage`.

### Run on an Android emulator

1. Open Android Studio, go to **Device Manager**, and start an Android Virtual Device
   (Android  API  35 or newer is recommended).
2. From this project folder, verify that Flutter can see the emulator:

   ```bash
   flutter devices
   ```

3. Start the app on the detected emulator:

   ```bash
   flutter pub get
   flutter run -d emulator-5554
   ```

   Replace `emulator-5554` with the device ID shown by `flutter devices` if it is
   different. Use `r` for hot reload and `q` to stop the app.

If no emulator is running, list the available AVDs and launch one with:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter run
```

### Enable event image uploads

Before deploying Storage rules, open the [Firebase Storage console](https://console.firebase.google.com/project/ceylona-a096f/storage) for the project and click **Get started**. Choose a Storage location, then run:

```bash
firebase deploy --only firestore:rules,storage
```

When an organizer creates an event, the selected gallery image is uploaded to
`events/{organizerUid}/...` in Storage. The resulting download URL is saved as
`imageUrl` in `events/{eventId}`. The app uses that URL on the home cards and
event details page.

## Firestore structure
events/{id} (+ comments subcollection), users/{uid}/saved/{eventId}, users/{uid}.
Event lifecycle: organizer creates -> status "pending" -> admin approves/rejects -> visible on Home when "approved".

## CRUD map
Events: create/edit/delete (Organizer), read (Home), and an optional gallery image upload stored in Firebase Storage. Saved: create/read/delete. Comments: create/read/delete. Profile: update. Approvals: update status.

## Map and reminders
Map and calendar/reminder flows are implemented from Event Details and Saved Events:

- Organizers can enter optional latitude, longitude, transport, and parking details.
- Seekers can open an OpenStreetMap view and launch Google Maps directions.
- Seekers can set a reminder for 1 day before, 1 hour before, or the event time.
- Reminder metadata is stored in `users/{uid}/saved/{eventId}`, with a local device notification scheduled through `flutter_local_notifications`.
- The calendar is available through the calendar icon on Saved Events and highlights saved event dates.

Run `flutter pub get` after pulling the new packages. Android 13+ asks for notification permission at runtime. The map needs an internet connection to load OpenStreetMap tiles. Events without coordinates use Colombo as the map fallback.

## Remaining work
Gallery, analytics, multilingual support, and role-based navigation enhancements remain. Add per member workload as needed.
