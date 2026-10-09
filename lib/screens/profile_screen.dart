import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db.dart';
import '../widgets/seeker_page_header.dart';

class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController nameController;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userName);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final profile = (await Db.userProfile()).data();
    if (mounted) {
      setState(() => profileImageUrl = profile?['photoUrl']?.toString());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> deleteAccount() async {
    final password = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'This permanently deletes your profile and saved events.'),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, password.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    password.dispose();
    if (confirmed == null || confirmed.isEmpty) return;
    try {
      await Db.deleteAccount(password: confirmed);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.code == 'wrong-password'
                ? 'Current password is incorrect'
                : error.message ?? 'Could not delete account')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not delete account: ${error.message}')));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfaf7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SeekerPageHeader(
              title: 'Your Profile', subtitle: 'Account and preferences'),
          const SizedBox(height: 16),
          CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.warning.withValues(alpha: .16),
              backgroundImage: profileImageUrl != null &&
                  profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : null,
              child: profileImageUrl == null || profileImageUrl!.isEmpty
                ? Text(
                  userName.isEmpty
                    ? 'U'
                    : userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold))
                : null),
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
          _ProfileRow(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: _openPersonalInformation),
          const _ProfileRow(icon: Icons.language, title: 'Language'),
          const _ProfileRow(
              icon: Icons.notifications_none, title: 'Notification Settings'),
          const _ProfileRow(
              icon: Icons.lock_outline, title: 'Privacy & Security'),
          const _ProfileRow(icon: Icons.help_outline, title: 'Help & Support'),
          const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: () async {
                await Db.updateName(nameController.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')));
                }
              },
              child: const Text('Save changes')),
          const SizedBox(height: 8),
          if (!widget.isOrganizer)
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
                          widget.onOrganizerEnabled?.call();
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
              subtitle: Text(widget.organizerMode
                  ? 'Manage your events'
                  : 'Discover events as a seeker'),
              value: widget.organizerMode,
              onChanged: widget.onModeChanged,
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: deleteAccount,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete account'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
          OutlinedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Log out')),
        ],
      ),
    );
  }

  Future<void> _openPersonalInformation() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const PersonalInformationScreen()));
    await _loadProfileImage();
  }
}

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final bio = TextEditingController();
  Uint8List? selectedImage;
  String? imageUrl;
  bool loading = true;
  bool saving = false;

  ImageProvider<Object>? get profileImage {
    if (selectedImage != null) return MemoryImage(selectedImage!);
    if (imageUrl != null && imageUrl!.isNotEmpty) return NetworkImage(imageUrl!);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = (await Db.userProfile()).data() ?? {};
    name.text = profile['name']?.toString() ?? userName;
    phone.text = profile['phone']?.toString() ?? '';
    city.text = profile['city']?.toString() ?? '';
    bio.text = profile['bio']?.toString() ?? '';
    if (mounted) {
      setState(() {
        imageUrl = profile['photoUrl']?.toString();
        loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 900);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please choose an image smaller than 5 MB')));
      }
      return;
    }
    setState(() => selectedImage = bytes);
  }

  Future<void> _save() async {
    final displayName = name.text.trim();
    if (displayName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your full name')));
      return;
    }
    setState(() => saving = true);
    try {
      String? savedImageUrl = imageUrl;
      if (selectedImage != null) {
        savedImageUrl = await Db.uploadProfileImage(selectedImage!, 'jpg');
      }
      await Db.updateProfile(
          name: displayName,
          phone: phone.text.trim(),
          city: city.text.trim(),
          bio: bio.text.trim(),
          photoUrl: savedImageUrl);
      if (mounted) {
        setState(() {
          imageUrl = savedImageUrl;
          selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personal information updated')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.message ?? 'Could not update profile')));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    city.dispose();
    bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(alignment: Alignment.bottomRight, children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: profileImage,
                child: selectedImage == null &&
                        (imageUrl == null || imageUrl!.isEmpty)
                    ? Text(name.text.isEmpty
                        ? 'U'
                        : name.text.substring(0, 1).toUpperCase())
                    : null,
              ),
              IconButton.filled(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined)),
            ]),
          ),
          const SizedBox(height: 24),
          TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Full name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Phone number (optional)',
                  border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'City (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: bio,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'About you (optional)',
                  border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(
              initialValue: FirebaseAuth.instance.currentUser?.email ?? '',
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(saving ? 'Saving...' : 'Save details')),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _ProfileRow({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap);
}
