import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db.dart';
import '../firebase_options.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(),
      pass = TextEditingController(),
      name = TextEditingController();
  bool register = false;

  Future<void> submit() async {
    try {
      final a = FirebaseAuth.instance;
      if (register) {
        final c = await a.createUserWithEmailAndPassword(
            email: email.text.trim(), password: pass.text);
        await c.user!.updateDisplayName(name.text.trim());
        await Db.ensureUserProfile(
            name: name.text.trim(), email: email.text.trim());
      } else {
        await a.signInWithEmailAndPassword(
            email: email.text.trim(), password: pass.text);
        await Db.ensureUserProfile();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
      }
    }
  }

  InputDecoration deco(String l) =>
      InputDecoration(labelText: l, filled: true, fillColor: Colors.white);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Text('Ceylona',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const Text("Discover Sri Lanka's local events"),
              const SizedBox(height: 24),
              if (register)
                TextField(controller: name, decoration: deco('Name')),
              const SizedBox(height: 8),
              TextField(controller: email, decoration: deco('Email')),
              const SizedBox(height: 8),
              TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: deco('Password')),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: submit,
                  child: Text(register ? 'Register' : 'Login')),
              if (!register)
                TextButton(
                  onPressed: () async {
                    if (email.text.trim().isEmpty) return;
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email.text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Password reset email sent')));
                    }
                  },
                  child: const Text('Forgot password?'),
                ),
              TextButton(
                  onPressed: () => setState(() => register = !register),
                  child: Text(register
                      ? 'Have an account? Login'
                      : 'New here? Register')),
              TextButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen())),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Authority Officer Login'),
              ),
            ]),
          ),
        ),
      );
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    final emailAddress = email.text.trim();
    if (emailAddress.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter your official email and password')));
      return;
    }
    setState(() => loading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress, password: password.text);
      final userId = credential.user?.uid;
      if (userId == null || !await Db.isAdmin(userId: userId)) {
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message:
              'Admin record not found. UID: $userId | Project: ${DefaultFirebaseOptions.web.projectId}',
        );
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Invalid official email or password',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'not-admin' =>
          error.message ?? 'This account is not registered as an admin.',
        _ => error.message ?? 'Admin login failed',
      };
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Firebase error: ${error.message ?? error.code}')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Authority Officer Login')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Icon(Icons.admin_panel_settings, size: 64),
              const SizedBox(height: 12),
              const Text('Restricted admin access',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Official email',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: loading ? null : login,
                  child:
                      Text(loading ? 'Checking access...' : 'Login securely')),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        final emailAddress = email.text.trim();
                        if (emailAddress.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Enter your official email first')));
                          return;
                        }
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: emailAddress);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent'),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.message ??
                                    'Could not send reset email'),
                              ),
                            );
                          }
                        }
                      },
                child: const Text('Forgot password?'),
              ),
            ]),
          ),
        ),
      );
}
