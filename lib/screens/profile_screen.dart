// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import '../theme/app_theme.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/db.dart';
// import '../widgets/seeker_page_header.dart';
// import '../widgets/ceylona_bottom_navigation.dart';

// class ProfileScreen extends StatefulWidget {
//   final VoidCallback? onOrganizerEnabled;
//   final ValueChanged<bool>? onModeChanged;
//   final bool isOrganizer;
//   final bool organizerMode;
//   const ProfileScreen({
//     super.key,
//     this.onOrganizerEnabled,
//     this.onModeChanged,
//     this.isOrganizer = false,
//     this.organizerMode = false,
//   });
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late final TextEditingController nameController;
//   String? profileImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: userName);
//     _loadProfileImage();
//   }

//   Future<void> _loadProfileImage() async {
//     final profile = (await Db.userProfile()).data();
//     if (mounted) {
//       setState(() => profileImageUrl = profile?['photoUrl']?.toString());
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }

//   Future<void> deleteAccount() async {
//     final password = TextEditingController();
//     final confirmed = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete account?'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//                 'This permanently deletes your profile and saved events.'),
//             const SizedBox(height: 12),
//             TextField(
//               controller: password,
//               obscureText: true,
//               decoration: const InputDecoration(
//                   labelText: 'Current password', border: OutlineInputBorder()),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel')),
//           FilledButton(
//             onPressed: () => Navigator.pop(dialogContext, password.text),
//             style: FilledButton.styleFrom(backgroundColor: AppColors.error),
//             child: const Text('Delete account'),
//           ),
//         ],
//       ),
//     );
//     password.dispose();
//     if (confirmed == null || confirmed.isEmpty) return;
//     try {
//       await Db.deleteAccount(password: confirmed);
//     } on FirebaseAuthException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(error.code == 'wrong-password'
//                 ? 'Current password is incorrect'
//                 : error.message ?? 'Could not delete account')));
//       }
//     } on FirebaseException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Could not delete account: ${error.message}')));
//       }
//     } on StateError catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(error.message)));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfffbfaf7),
//       body: ListView(
//         padding: const EdgeInsets.only(bottom: 24),
//         children: [
//           const SeekerPageHeader(
//               title: 'Your Profile', subtitle: 'Account and preferences'),
//           const SizedBox(height: 16),
//           CircleAvatar(
//               radius: 36,
//               backgroundColor: AppColors.warning.withValues(alpha: .16),
//               backgroundImage:
//                   profileImageUrl != null && profileImageUrl!.isNotEmpty
//                       ? NetworkImage(profileImageUrl!)
//                       : null,
//               child: profileImageUrl == null || profileImageUrl!.isEmpty
//                   ? Text(
//                       userName.isEmpty
//                           ? 'U'
//                           : userName.substring(0, 1).toUpperCase(),
//                       style: const TextStyle(
//                           fontSize: 28, fontWeight: FontWeight.bold))
//                   : null),
//           const SizedBox(height: 8),
//           Center(
//               child: Text(userName,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.w700))),
//           Center(
//               child: Text(FirebaseAuth.instance.currentUser?.email ?? '',
//                   style: const TextStyle(color: Colors.grey))),
//           const SizedBox(height: 20),
//           const Text('Account & Settings',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 8),
//           _ProfileRow(
//               icon: Icons.person_outline,
//               title: 'Personal Information',
//               onTap: _openPersonalInformation),
//           const _ProfileRow(icon: Icons.language, title: 'Language'),
//           const _ProfileRow(
//               icon: Icons.notifications_none, title: 'Notification Settings'),
//           const _ProfileRow(
//               icon: Icons.lock_outline, title: 'Privacy & Security'),
//           const _ProfileRow(icon: Icons.help_outline, title: 'Help & Support'),
//           const SizedBox(height: 8),
//           TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Full name')),
//           const SizedBox(height: 12),
//           FilledButton(
//               onPressed: () async {
//                 await Db.updateName(nameController.text.trim());
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Profile updated')));
//                 }
//               },
//               child: const Text('Save changes')),
//           const SizedBox(height: 8),
//           if (!widget.isOrganizer)
//             OutlinedButton.icon(
//               icon: const Icon(Icons.business),
//               label: const Text('Become an Organizer'),
//               onPressed: () async {
//                 final organization = TextEditingController();
//                 await showDialog<void>(
//                   context: context,
//                   builder: (dialogContext) => AlertDialog(
//                     title: const Text('Become an Organizer'),
//                     content: TextField(
//                       controller: organization,
//                       decoration:
//                           const InputDecoration(labelText: 'Organization name'),
//                     ),
//                     actions: [
//                       TextButton(
//                           onPressed: () => Navigator.pop(dialogContext),
//                           child: const Text('Cancel')),
//                       FilledButton(
//                         onPressed: () async {
//                           if (organization.text.trim().isEmpty) return;
//                           await Db.becomeOrganizer(organization.text.trim());
//                           widget.onOrganizerEnabled?.call();
//                           if (dialogContext.mounted) {
//                             Navigator.pop(dialogContext);
//                           }
//                           if (context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('Organizer mode enabled')));
//                           }
//                         },
//                         child: const Text('Continue'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           else
//             SwitchListTile(
//               secondary: const Icon(Icons.swap_horiz),
//               title: const Text('Organizer mode'),
//               subtitle: Text(widget.organizerMode
//                   ? 'Manage your events'
//                   : 'Discover events as a seeker'),
//               value: widget.organizerMode,
//               onChanged: widget.onModeChanged,
//             ),
//           const SizedBox(height: 8),
//           OutlinedButton.icon(
//             onPressed: deleteAccount,
//             icon: const Icon(Icons.delete_forever),
//             label: const Text('Delete account'),
//             style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
//           ),
//           OutlinedButton(
//               onPressed: () => FirebaseAuth.instance.signOut(),
//               child: const Text('Log out')),
//         ],
//       ),
//     );
//   }

//   Future<void> _openPersonalInformation() async {
//     await Navigator.push(context,
//         MaterialPageRoute(builder: (_) => const PersonalInformationScreen()));
//     await _loadProfileImage();
//   }
// }

// class PersonalInformationScreen extends StatefulWidget {
//   const PersonalInformationScreen({super.key});

//   @override
//   State<PersonalInformationScreen> createState() =>
//       _PersonalInformationScreenState();
// }

// class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
//   final name = TextEditingController();
//   final phone = TextEditingController();
//   final city = TextEditingController();
//   final bio = TextEditingController();
//   Uint8List? selectedImage;
//   String? imageUrl;
//   bool loading = true;
//   bool saving = false;

//   ImageProvider<Object>? get profileImage {
//     if (selectedImage != null) return MemoryImage(selectedImage!);
//     if (imageUrl != null && imageUrl!.isNotEmpty)
//       return NetworkImage(imageUrl!);
//     return null;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }

//   Future<void> _loadProfile() async {
//     final profile = (await Db.userProfile()).data() ?? {};
//     name.text = profile['name']?.toString() ?? userName;
//     phone.text = profile['phone']?.toString() ?? '';
//     city.text = profile['city']?.toString() ?? '';
//     bio.text = profile['bio']?.toString() ?? '';
//     if (mounted) {
//       setState(() {
//         imageUrl = profile['photoUrl']?.toString();
//         loading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final file = await ImagePicker().pickImage(
//         source: ImageSource.gallery, imageQuality: 85, maxWidth: 900);
//     if (file == null) return;
//     final bytes = await file.readAsBytes();
//     if (bytes.length > 5 * 1024 * 1024) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('Please choose an image smaller than 5 MB')));
//       }
//       return;
//     }
//     setState(() => selectedImage = bytes);
//   }

//   Future<void> _save() async {
//     final displayName = name.text.trim();
//     if (displayName.length < 2) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Enter your full name')));
//       return;
//     }
//     setState(() => saving = true);
//     try {
//       String? savedImageUrl = imageUrl;
//       if (selectedImage != null) {
//         savedImageUrl = await Db.uploadProfileImage(selectedImage!, 'jpg');
//       }
//       await Db.updateProfile(
//           name: displayName,
//           phone: phone.text.trim(),
//           city: city.text.trim(),
//           bio: bio.text.trim(),
//           photoUrl: savedImageUrl);
//       if (mounted) {
//         setState(() {
//           imageUrl = savedImageUrl;
//           selectedImage = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Personal information updated')));
//       }
//     } on FirebaseException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(error.message ?? 'Could not update profile')));
//       }
//     } on StateError catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(error.message)));
//       }
//     } finally {
//       if (mounted) setState(() => saving = false);
//     }
//   }

//   @override
//   void dispose() {
//     name.dispose();
//     phone.dispose();
//     city.dispose();
//     bio.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text('Personal Information')),
//       bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 4),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Center(
//             child: Stack(alignment: Alignment.bottomRight, children: [
//               CircleAvatar(
//                 radius: 52,
//                 backgroundImage: profileImage,
//                 child: selectedImage == null &&
//                         (imageUrl == null || imageUrl!.isEmpty)
//                     ? Text(name.text.isEmpty
//                         ? 'U'
//                         : name.text.substring(0, 1).toUpperCase())
//                     : null,
//               ),
//               IconButton.filled(
//                   onPressed: _pickImage,
//                   icon: const Icon(Icons.camera_alt_outlined)),
//             ]),
//           ),
//           const SizedBox(height: 24),
//           TextField(
//               controller: name,
//               textCapitalization: TextCapitalization.words,
//               decoration: const InputDecoration(
//                   labelText: 'Full name', border: OutlineInputBorder())),
//           const SizedBox(height: 12),
//           TextField(
//               controller: phone,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                   labelText: 'Phone number (optional)',
//                   border: OutlineInputBorder())),
//           const SizedBox(height: 12),
//           TextField(
//               controller: city,
//               textCapitalization: TextCapitalization.words,
//               decoration: const InputDecoration(
//                   labelText: 'City (optional)', border: OutlineInputBorder())),
//           const SizedBox(height: 12),
//           TextField(
//               controller: bio,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                   labelText: 'About you (optional)',
//                   border: OutlineInputBorder())),
//           const SizedBox(height: 12),
//           TextFormField(
//               initialValue: FirebaseAuth.instance.currentUser?.email ?? '',
//               readOnly: true,
//               decoration: const InputDecoration(
//                   labelText: 'Email', border: OutlineInputBorder())),
//           const SizedBox(height: 20),
//           FilledButton.icon(
//               onPressed: saving ? null : _save,
//               icon: const Icon(Icons.save_outlined),
//               label: Text(saving ? 'Saving...' : 'Save details')),
//         ],
//       ),
//     );
//   }
// }

// class _ProfileRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback? onTap;
//   const _ProfileRow({required this.icon, required this.title, this.onTap});

//   @override
//   Widget build(BuildContext context) => ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(icon),
//       title: Text(title),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap);
// }



import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';
import '../widgets/ceylona_bottom_navigation.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

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
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userName);
    _loadProfileImage();
  }

  // ORIGINAL BACKEND
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

  // ============================================================
  // ORIGINAL BACKEND - DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    if (_deletingAccount) return;
    String enteredPassword = '';
    final dialogRoute = DialogRoute<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Delete account?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This permanently deletes your profile and saved events.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (value) => enteredPassword = value,
                onSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(dialogContext).pop(value);
                },
                decoration: InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(dialogContext).pop(enteredPassword);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    final confirmed = await Navigator.of(context, rootNavigator: true)
        .push<String>(dialogRoute);
    // Wait until the reverse animation ends and the dialog subtree has been
    // removed from the widget tree before deleting the signed-in user.
    await dialogRoute.completed;
    if (!mounted || confirmed == null || confirmed.trim().isEmpty) return;
    setState(() => _deletingAccount = true);
    try {
      // Original Firestore + Firebase Authentication deletion operation.
      // The root authStateChanges() listener navigates to LoginScreen.
      final deletingUid = FirebaseAuth.instance.currentUser?.uid;
      await Db.deleteAccount(password: confirmed);
      // Usually user.delete() signs out automatically. This covers platforms
      // that might still report the deleted user as the active session.
      if (FirebaseAuth.instance.currentUser?.uid == deletingUid) {
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.code == 'wrong-password' || error.code == 'invalid-credential'
                  ? 'Current password is incorrect'
                  : error.message ?? 'Could not delete account',
            ),
          ),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete account: ${error.message}')),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete account: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  // ============================================================
  // ORIGINAL BACKEND - PERSONAL INFORMATION NAVIGATION
  // ============================================================

  Future<void> _openPersonalInformation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PersonalInformationScreen(),
      ),
    );
    await _loadProfileImage();
  }

  // ============================================================
  // ORGANIZER DIALOG - ORIGINAL BACKEND
  // ============================================================

  Future<void> _becomeOrganizer() async {
    final organization = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Become an Organizer',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: organization,
          decoration: InputDecoration(
            labelText: 'Organization name',
            prefixIcon: const Icon(
              Icons.business_outlined,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
            ),
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
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    // Retain the dialog controller until the dialog closes.
    organization.dispose();
  }

  // ============================================================
  // PROFILE PAGE UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildProfileCard(),

            const SizedBox(height: 27),

            _buildSectionHeading(
              'Account & Settings',
              'Manage your personal preferences',
              Icons.settings_outlined,
            ),

            const SizedBox(height: 13),

            _buildSettingsCard(),

            const SizedBox(height: 24),

            _buildSectionHeading(
              'Quick Profile Update',
              'Update your display name',
              Icons.edit_note_rounded,
            ),

            const SizedBox(height: 13),

            _buildQuickEditCard(),

            const SizedBox(height: 24),

            _buildSectionHeading(
              'Organizer Access',
              'Explore more ways to use Ceylona',
              Icons.business_center_outlined,
            ),

            const SizedBox(height: 13),

            _buildOrganizerCard(),

            const SizedBox(height: 26),

            _buildSectionHeading(
              'Account Actions',
              'Manage your account securely',
              Icons.shield_outlined,
            ),

            const SizedBox(height: 13),

            _buildAccountActions(),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODERN HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.045),
            blurRadius: 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              _ProfileBadge(
                icon: Icons.person_rounded,
                label: 'MY ACCOUNT',
              ),

              const Spacer(),

              const SizedBox(width: 42),
            ],
          ),

          const SizedBox(height: 23),

          const _EyebrowLabel(
            label: 'YOUR PERSONAL SPACE',
          ),

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Your ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Profile',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Manage your account and preferences.\n'
            'Make your Ceylona experience your own.',
            style: TextStyle(
              fontSize: 11,
              height: 1.65,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 21),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.13),
                  backgroundImage: profileImageUrl != null &&
                          profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null ||
                          profileImageUrl!.isEmpty
                      ? Text(
                          userName.isEmpty
                              ? 'U'
                              : userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        )
                      : null,
                ),
              ),

              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _openPersonalInformation,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryDark,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            userName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.isOrganizer ? 'Event Organizer' : 'Event Explorer',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Divider(color: AppColors.border),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPersonalInformation,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: const Text('Edit Personal Information'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: 'Manage your profile details',
            onTap: _openPersonalInformation,
          ),

          const Divider(height: 1, color: AppColors.border),

          const _ProfileRow(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Language preferences',
          ),

          const Divider(height: 1, color: AppColors.border),

          const _ProfileRow(
            icon: Icons.notifications_none_rounded,
            title: 'Notification Settings',
            subtitle: 'Manage event notifications',
          ),

          const Divider(height: 1, color: AppColors.border),

          const _ProfileRow(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy & Security',
            subtitle: 'Account privacy settings',
          ),

          const Divider(height: 1, color: AppColors.border),

          const _ProfileRow(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help with Ceylona',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK EDIT NAME
  // ============================================================

  Widget _buildQuickEditCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISPLAY NAME',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Full name',
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await Db.updateName(nameController.text.trim());

                if (mounted) setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                }
              },
              icon: const Icon(
                Icons.save_outlined,
                size: 18,
              ),
              label: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORGANIZER CARD
  // ============================================================

  Widget _buildOrganizerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.business_center_outlined,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isOrganizer
                          ? 'Organizer Account'
                          : 'Become an Organizer',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.isOrganizer
                          ? 'Switch between your account modes'
                          : 'Start creating and managing events',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (!widget.isOrganizer)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.business_rounded),
                label: const Text('Become an Organizer'),
                onPressed: _becomeOrganizer,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Organizer mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  widget.organizerMode
                      ? 'Manage your events'
                      : 'Discover events as a seeker',
                  style: const TextStyle(fontSize: 10),
                ),
                value: widget.organizerMode,
                activeThumbColor: AppColors.primary,
                onChanged: widget.onModeChanged,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT ACTIONS
  // ============================================================

  Widget _buildAccountActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deletingAccount ? null : deleteAccount,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Delete Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PERSONAL INFORMATION SCREEN
// ============================================================

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
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ORIGINAL BACKEND
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

  // ORIGINAL BACKEND
  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 900,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose an image smaller than 5 MB'),
          ),
        );
      }
      return;
    }

    setState(() => selectedImage = bytes);
  }

  // ORIGINAL BACKEND
  Future<void> _save() async {
    final displayName = name.text.trim();

    if (displayName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full name')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      String? savedImageUrl = imageUrl;

      if (selectedImage != null) {
        savedImageUrl =
            await Db.uploadProfileImage(selectedImage!, 'jpg');
      }

      await Db.updateProfile(
        name: displayName,
        phone: phone.text.trim(),
        city: city.text.trim(),
        bio: bio.text.trim(),
        photoUrl: savedImageUrl,
      );

      if (mounted) {
        setState(() {
          imageUrl = savedImageUrl;
          selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information updated'),
          ),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Could not update profile',
            ),
          ),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
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

  // ============================================================
  // PERSONAL INFORMATION UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CeylonaBottomNavigation(selectedIndex: 4),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildPersonalHeader(),

            const SizedBox(height: 24),

            _buildPhotoEditor(),

            const SizedBox(height: 27),

            const _PersonalSectionHeading(
              icon: Icons.person_outline_rounded,
              title: 'Basic Information',
              subtitle: 'Tell us a little about yourself',
            ),

            const SizedBox(height: 14),

            _buildPersonalForm(),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox(
                          height: 17,
                          width: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          size: 19,
                        ),
                  label: Text(
                    saving ? 'Saving...' : 'Save Details',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PERSONAL INFO HEADER
  // ============================================================

  Widget _buildPersonalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    height: 42,
                    width: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const _ProfileBadge(
                icon: Icons.edit_note_rounded,
                label: 'EDIT PROFILE',
              ),

              const Spacer(),

              const SizedBox(width: 42),
            ],
          ),

          const SizedBox(height: 24),

          const _EyebrowLabel(label: 'YOUR INFORMATION'),

          const SizedBox(height: 9),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Personal ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Information',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Keep your information up to date.\n'
            'Personalize your Ceylona profile.',
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO EDITOR
  // ============================================================

  Widget _buildPhotoEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        vertical: 23,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 51,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: profileImage,
                  child: profileImage == null
                      ? Text(
                          name.text.isEmpty
                              ? 'U'
                              : name.text.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        )
                      : null,
                ),
              ),

              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _pickImage,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 19,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Choose a photo smaller than 5 MB',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 13),

          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.upload_rounded,
              size: 18,
            ),
            label: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION FORM
  // ============================================================

  Widget _buildPersonalForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _profileField(
            controller: name,
            label: 'Full name',
            icon: Icons.badge_outlined,
            capitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 15),

          _profileField(
            controller: phone,
            label: 'Phone number (optional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 15),

          _profileField(
            controller: city,
            label: 'City (optional)',
            icon: Icons.location_city_outlined,
            capitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 15),

          _profileField(
            controller: bio,
            label: 'About you (optional)',
            icon: Icons.edit_note_rounded,
            maxLines: 3,
          ),

          const SizedBox(height: 15),

          TextFormField(
            initialValue:
                FirebaseAuth.instance.currentUser?.email ?? '',
            readOnly: true,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              suffixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.secondaryText,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED PROFILE BADGE
// ============================================================

class _ProfileBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED EYEBROW LABEL
// ============================================================

class _EyebrowLabel extends StatelessWidget {
  final String label;

  const _EyebrowLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PERSONAL SECTION HEADING
// ============================================================

class _PersonalSectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PersonalSectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODERN PROFILE SETTINGS ROW
// ============================================================

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 4,
      ),
      leading: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.secondaryText,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 19,
        color: AppColors.secondaryText,
      ),
    );
  }
}