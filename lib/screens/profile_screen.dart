

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/db.dart';



const Color profileYellow = Color(0xFFFFC107);

const Color profileBackground = Color(0xFFFFFBF4);

const Color profileDark = Color(0xFF111827);

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

  String? photoUrl;

  bool uploadingPhoto = false;

  @override

  void initState() {

    super.initState();

    loadPhoto();

  }

  Future<void> loadPhoto() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      final doc = await FirebaseFirestore.instance

          .collection('users')

          .doc(user.uid)

          .get();

      if (!mounted) return;

      setState(() {

        photoUrl = doc.data()?['photoUrl'] as String?;

      });

    } catch (_) {

      // Keep the default profile icon if no photo is available.

    }

  }

  Future<void> pickAndUploadPhoto() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      final picker = ImagePicker();

      final image = await picker.pickImage(

        source: ImageSource.gallery,

        imageQuality: 75,

      );

      if (image == null || !mounted) return;

      setState(() => uploadingPhoto = true);

      final ref = FirebaseStorage.instance

          .ref()

          .child('profile_photos')

          .child('${user.uid}.jpg');
      final imageBytes = await image.readAsBytes();
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance

          .collection('users')

          .doc(user.uid)

          .set({'photoUrl': url}, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {

        photoUrl = url;

        uploadingPhoto = false;

      });

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Profile photo updated')),

      );

    } catch (e) {

      if (!mounted) return;

      setState(() => uploadingPhoto = false);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Photo upload failed: $e')),

      );

    }

  }

  @override

  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    final name = userName.trim().isEmpty ? 'User Name' : userName;

    return Scaffold(

      backgroundColor: profileBackground,

      appBar: AppBar(

        backgroundColor: profileYellow,

        foregroundColor: profileDark,

        title: const Text(

          'Profile & Settings',

          style: TextStyle(fontWeight: FontWeight.bold),

        ),

      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          InkWell(

            borderRadius: BorderRadius.circular(20),

            onTap: () => Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => PersonalInformationScreen(

                  photoUrl: photoUrl,

                  onPhotoChanged: (url) {

                    setState(() => photoUrl = url);

                  },

                ),

              ),

            ),

            child: Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                border: Border.all(color: profileYellow),

                borderRadius: BorderRadius.circular(20),

              ),

              child: Row(

                children: [

                  ProfileAvatar(photoUrl: photoUrl, radius: 36),

                  const SizedBox(width: 16),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          name,

                          style: const TextStyle(

                            fontSize: 18,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 6),

                        Text(

                          user?.email ?? '',

                          style: const TextStyle(color: Colors.grey),

                        ),

                      ],

                    ),

                  ),

                  const Icon(Icons.chevron_right, color: profileYellow),

                ],

              ),

            ),

          ),

          const SizedBox(height: 26),

          _settingsItem(

            icon: Icons.person_outline,

            title: 'Personal Information',

            onTap: () => Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => PersonalInformationScreen(

                  photoUrl: photoUrl,

                  onPhotoChanged: (url) {

                    setState(() => photoUrl = url);

                  },

                ),

              ),

            ),

          ),

          _settingsItem(

            icon: Icons.language,

            title: 'Language',

            trailing: const Text(

              'English',

              style: TextStyle(color: Colors.grey),

            ),

            onTap: () => _showInfo('Language settings are not available yet.'),

          ),

          _settingsItem(

            icon: Icons.notifications_none,

            title: 'Notification Settings',

            onTap: () => _showInfo(

              'Notification settings are not available yet.',

            ),

          ),

          _settingsItem(

            icon: Icons.shield_outlined,

            title: 'Privacy & Security',

            onTap: () => _showInfo(

              'Privacy & Security settings are not available yet.',

            ),

          ),

          _settingsItem(

            icon: Icons.help_outline,

            title: 'Help & Support',

            onTap: () => _showInfo('Help & Support'),

          ),

          _settingsItem(

            icon: Icons.info_outline,

            title: 'About Us',

            onTap: () => _showInfo('Ceylona - Event Discovery App'),

          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(

            icon: const Icon(Icons.business),

            label: const Text('Become an Organizer'),

            style: OutlinedButton.styleFrom(

              foregroundColor: profileDark,

              side: const BorderSide(color: profileYellow),

              padding: const EdgeInsets.symmetric(vertical: 14),

            ),

            onPressed: widget.isOrganizer ? null : _becomeOrganizer,

          ),

          if (widget.isOrganizer) ...[

            const SizedBox(height: 12),

            SwitchListTile(

              title: const Text('Organizer mode'),

              subtitle: Text(

                widget.organizerMode

                    ? 'Manage your events'

                    : 'Discover events as a seeker',

              ),

              value: widget.organizerMode,

              activeThumbColor: profileYellow,

              onChanged: widget.onModeChanged,

            ),

          ],

          const SizedBox(height: 16),

          OutlinedButton.icon(

            icon: const Icon(Icons.logout),

            label: const Text('Log Out'),

            style: OutlinedButton.styleFrom(

              foregroundColor: Colors.brown,

              side: const BorderSide(color: profileYellow),

              padding: const EdgeInsets.symmetric(vertical: 14),

            ),

            onPressed: () async {

              await FirebaseAuth.instance.signOut();

            },

          ),

        ],

      ),

    );

  }

  Widget _settingsItem({

  required IconData icon,

  required String title,

  required VoidCallback onTap,

  Widget? trailing,

}) {

  return Container(

    margin: const EdgeInsets.only(bottom: 10),

    decoration: BoxDecoration(

      color: Colors.white,

      border: Border.all(color: profileYellow, width: 0.7),

      borderRadius: BorderRadius.circular(15),

    ),

    child: Material(

      color: Colors.transparent,

      borderRadius: BorderRadius.circular(15),

      clipBehavior: Clip.antiAlias,

      child: ListTile(

        tileColor: Colors.transparent,

        leading: Icon(icon, color: profileYellow),

        title: Text(title),

        trailing: trailing ??

            const Icon(Icons.chevron_right, color: profileYellow),

        onTap: onTap,

      ),

    ),

  );

}

  Future<void> _becomeOrganizer() async {

    final organization = TextEditingController();

    await showDialog<void>(

      context: context,

      builder: (dialogContext) => AlertDialog(

        title: const Text('Become an Organizer'),

        content: TextField(

          controller: organization,

          decoration: const InputDecoration(

            labelText: 'Organization name',

          ),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(dialogContext),

            child: const Text('Cancel'),

          ),

          FilledButton(

            onPressed: () async {

              if (organization.text.trim().isEmpty) return;

              try {

                await Db.becomeOrganizer(organization.text.trim());

                widget.onOrganizerEnabled?.call();

                if (dialogContext.mounted) {

                  Navigator.pop(dialogContext);

                }

                if (mounted) {

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text('Organizer mode enabled'),

                    ),

                  );

                }

              } catch (e) {

                if (mounted) {

                  ScaffoldMessenger.of(context).showSnackBar(

                    SnackBar(content: Text('Could not enable organizer: $e')),

                  );

                }

              }

            },

            child: const Text('Continue'),

          ),

        ],

      ),

    );

  }

  void _showInfo(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message)),

    );

  }

}

class PersonalInformationScreen extends StatefulWidget {

  final String? photoUrl;

  final ValueChanged<String?>? onPhotoChanged;

  const PersonalInformationScreen({

    super.key,

    this.photoUrl,

    this.onPhotoChanged,

  });

  @override

  State<PersonalInformationScreen> createState() =>

      _PersonalInformationScreenState();

}

class _PersonalInformationScreenState

    extends State<PersonalInformationScreen> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  late final TextEditingController _dobController;

  String? _photoUrl;

  String? _gender;

  bool _saving = false;

  bool _uploadingPhoto = false;

  @override

  void initState() {

    super.initState();

    _nameController = TextEditingController(text: userName);

    _phoneController = TextEditingController();

    _dobController = TextEditingController();

    _photoUrl = widget.photoUrl;

    _loadProfile();

  }

  Future<void> _loadProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      final doc = await FirebaseFirestore.instance

          .collection('users')

          .doc(user.uid)

          .get();

      final data = doc.data();

      if (!mounted || data == null) return;

      setState(() {

        _nameController.text =

            (data['name'] ?? data['userName'] ?? userName).toString();

        _phoneController.text = (data['phoneNumber'] ?? '').toString();

        _dobController.text = (data['dateOfBirth'] ?? '').toString();

        final gender = data['gender']?.toString();

        _gender = ['Male', 'Female', 'Other'].contains(gender)

            ? gender

            : null;

        _photoUrl = data['photoUrl']?.toString() ?? _photoUrl;

      });

    } catch (_) {

      // Keep the available profile details if loading fails.

    }

  }

  Future<void> _changePhoto() async {

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  try {

    final picker = ImagePicker();

    final image = await picker.pickImage(

      source: ImageSource.gallery,

      imageQuality: 75,

    );

    if (image == null || !mounted) return;

    setState(() => _uploadingPhoto = true);

    final imageBytes = await image.readAsBytes();

    final ref = FirebaseStorage.instance

        .ref()

        .child('profile_photos')

        .child('${user.uid}.jpg');

    await ref.putData(

      imageBytes,

      SettableMetadata(contentType: 'image/jpeg'),

    );

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance

        .collection('users')

        .doc(user.uid)

        .set({

      'photoUrl': url,

    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() {

      _photoUrl = url;

      _uploadingPhoto = false;

    });

    widget.onPhotoChanged?.call(url);

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Profile photo updated'),

      ),

    );

  } catch (e) {

    if (!mounted) return;

    setState(() => _uploadingPhoto = false);

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text('Photo upload failed: $e'),

      ),

    );

  }

}

  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {

        throw Exception('Please log in again.');

      }

      await Db.updateName(_nameController.text.trim());

      await FirebaseFirestore.instance

          .collection('users')

          .doc(user.uid)

          .set({

        'name': _nameController.text.trim(),

        'phoneNumber': _phoneController.text.trim(),

        'dateOfBirth': _dobController.text.trim(),

        'gender': _gender,

        'photoUrl': _photoUrl,

      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Profile updated successfully')),

      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Could not save profile: $e')),

      );

    } finally {

      if (mounted) setState(() => _saving = false);

    }

  }

  Future<void> _selectDate() async {

    final now = DateTime.now();

    DateTime initialDate = DateTime(2000, 1, 1);

    try {

      final parsed = DateTime.tryParse(_dobController.text);

      if (parsed != null) initialDate = parsed;

    } catch (_) {}

    final date = await showDatePicker(

      context: context,

      initialDate: initialDate.isAfter(now) ? now : initialDate,

      firstDate: DateTime(1900),

      lastDate: now,

    );

    if (date != null && mounted) {

      setState(() {

        _dobController.text =

            '${date.year.toString().padLeft(4, '0')}-'

            '${date.month.toString().padLeft(2, '0')}-'

            '${date.day.toString().padLeft(2, '0')}';

      });

    }

  }

  @override

  void dispose() {

    _nameController.dispose();

    _phoneController.dispose();

    _dobController.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(

      backgroundColor: profileBackground,

      appBar: AppBar(

        backgroundColor: profileYellow,

        foregroundColor: profileDark,

        title: const Text(

          'Personal Information',

          style: TextStyle(fontWeight: FontWeight.bold),

        ),

      ),

      body: Form(

        key: _formKey,

        child: ListView(

          padding: const EdgeInsets.all(26),

          children: [

            Center(

              child: Column(

                children: [

                  Stack(

                    children: [

                      ProfileAvatar(photoUrl: _photoUrl, radius: 60),

                      Positioned(

                        bottom: 0,

                        right: 0,

                        child: CircleAvatar(

                          backgroundColor: profileDark,

                          radius: 17,

                          child: _uploadingPhoto

                              ? const SizedBox(

                                  width: 17,

                                  height: 17,

                                  child: CircularProgressIndicator(

                                    strokeWidth: 2,

                                    color: Colors.white,

                                  ),

                                )

                              : IconButton(

                                  padding: EdgeInsets.zero,

                                  icon: const Icon(

                                    Icons.camera_alt,

                                    color: Colors.white,

                                    size: 17,

                                  ),

                                  onPressed: _changePhoto,

                                ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 12),

                  TextButton(

                    onPressed: _uploadingPhoto ? null : _changePhoto,

                    child: const Text('Change Photo'),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 20),

            _fieldLabel('Full Name'),

            TextFormField(

              controller: _nameController,

              decoration: _decoration('Enter full name'),

              validator: (value) =>

                  value == null || value.trim().isEmpty

                      ? 'Please enter your name'

                      : null,

            ),

            const SizedBox(height: 20),

            _fieldLabel('Email'),

            TextFormField(

              initialValue: email,

              readOnly: true,

              decoration: _decoration('Email'),

            ),

            const SizedBox(height: 20),

            _fieldLabel('Phone Number'),

            TextFormField(

              controller: _phoneController,

              keyboardType: TextInputType.phone,

              decoration: _decoration('+94 71 123 4567'),

            ),

            const SizedBox(height: 20),

            _fieldLabel('Date of Birth'),

            TextFormField(

              controller: _dobController,

              readOnly: true,

              onTap: _selectDate,

              decoration: _decoration('Select date').copyWith(

                suffixIcon: const Icon(Icons.calendar_month),

              ),

            ),

            const SizedBox(height: 20),

            _fieldLabel('Gender'),

            DropdownButtonFormField<String>(

              initialValue: _gender,

              decoration: _decoration('Select Gender'),

              items: const [

                DropdownMenuItem(value: 'Male', child: Text('Male')),

                DropdownMenuItem(value: 'Female', child: Text('Female')),

                DropdownMenuItem(value: 'Other', child: Text('Other')),

              ],

              onChanged: (value) => setState(() => _gender = value),

            ),

            const SizedBox(height: 28),

            SizedBox(

              height: 48,

              child: FilledButton(

                style: FilledButton.styleFrom(

                  backgroundColor: profileYellow,

                  foregroundColor: profileDark,

                ),

                onPressed: _saving ? null : _saveProfile,

                child: _saving

                    ? const SizedBox(

                        height: 22,

                        width: 22,

                        child: CircularProgressIndicator(strokeWidth: 2),

                      )

                    : const Text(

                        'Save Changes',

                        style: TextStyle(fontWeight: FontWeight.bold),

                      ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _fieldLabel(String label) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 8),

      child: Text(

        label,

        style: const TextStyle(

          color: profileDark,

          fontWeight: FontWeight.w600,

        ),

      ),

    );

  }

  InputDecoration _decoration(String hint) {

    return InputDecoration(

      hintText: hint,

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(

        horizontal: 18,

        vertical: 17,

      ),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: profileYellow),

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: profileYellow),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(

          color: profileYellow,

          width: 2,

        ),

      ),

    );

  }

}

class ProfileAvatar extends StatelessWidget {

  final String? photoUrl;

  final double radius;

  const ProfileAvatar({

    super.key,

    required this.photoUrl,

    required this.radius,

  });

  @override

  Widget build(BuildContext context) {

    return CircleAvatar(

      radius: radius,

      backgroundColor: const Color(0xFFFFE6A3),

      backgroundImage:

          photoUrl != null && photoUrl!.isNotEmpty

              ? NetworkImage(photoUrl!)

              : null,

      child: photoUrl == null || photoUrl!.isEmpty

          ? Icon(

              Icons.person_outline,

              color: profileDark,

              size: radius,

            )

          : null,

    );

  }

}
