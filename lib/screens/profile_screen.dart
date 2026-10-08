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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
              radius: 36,
              backgroundColor: Colors.amber.shade100,
              child: Text(
                  userName.isEmpty
                      ? 'U'
                      : userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Center(
              child: Text(userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700))),
          Center(
              child: Text(FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
          const Text('Account & Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _ProfileRow(
              icon: Icons.person_outline, title: 'Personal Information'),
          const _ProfileRow(icon: Icons.language, title: 'Language'),
          const _ProfileRow(
              icon: Icons.notifications_none, title: 'Notification Settings'),
          const _ProfileRow(
              icon: Icons.lock_outline, title: 'Privacy & Security'),
          const _ProfileRow(icon: Icons.help_outline, title: 'Help & Support'),
          const SizedBox(height: 8),
          TextField(
              controller: n,
              decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: () async {
                await Db.updateName(n.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')));
                }
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
                      decoration:
                          const InputDecoration(labelText: 'Organization name'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () async {
                          if (organization.text.trim().isEmpty) return;
                          await Db.becomeOrganizer(organization.text.trim());
                          onOrganizerEnabled?.call();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Organizer mode enabled')));
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
              subtitle: Text(organizerMode
                  ? 'Manage your events'
                  : 'Discover events as a seeker'),
              value: organizerMode,
              onChanged: onModeChanged,
            ),
          OutlinedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Log out')),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ProfileRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right));
}
