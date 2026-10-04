import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOrganizerEnabled;
  final ValueChanged<bool>? onModeChanged;
  final bool isOrganizer;
  final bool organizerMode;
  const ProfileScreen({
    super.key,
    this.onOrganizerEnabled,
    this.onModeChanged,
    this.isOrganizer = false,
    this.organizerMode = false,
  });
  @override
  Widget build(BuildContext context) {
    final n = TextEditingController(text: userName);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(FirebaseAuth.instance.currentUser?.email ?? ''),
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: () async {
                await Db.updateName(n.text.trim());
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              },
              child: const Text('Save changes')),
          const SizedBox(height: 8),
          if (!isOrganizer)
            OutlinedButton.icon(
              icon: const Icon(Icons.business),
              label: const Text('Become an Organizer'),
              onPressed: () async {
              final organization = TextEditingController();
              await showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Become an Organizer'),
                  content: TextField(
                    controller: organization,
                    decoration: const InputDecoration(labelText: 'Organization name'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () async {
                        if (organization.text.trim().isEmpty) return;
                        await Db.becomeOrganizer(organization.text.trim());
                        onOrganizerEnabled?.call();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organizer mode enabled')));
                        }
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              );
              },
            )
          else
            SwitchListTile(
              secondary: const Icon(Icons.swap_horiz),
              title: const Text('Organizer mode'),
              subtitle: Text(organizerMode ? 'Manage your events' : 'Discover events as a seeker'),
              value: organizerMode,
              onChanged: onModeChanged,
            ),
          OutlinedButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Log out')),
        ]),
      ),
    );
  }
}
