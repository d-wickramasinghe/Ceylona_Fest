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
      name = TextEditingController(),
      confirmPass = TextEditingController();
  bool register = false;
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmation = true;

  Future<void> submit() async {
    final displayName = name.text.trim();
    final emailAddress = email.text.trim();
    if (register && displayName.length < 2) {
      _showError('Enter your full name');
      return;
    }
    if (emailAddress.isEmpty || !emailAddress.contains('@')) {
      _showError('Enter a valid email address');
      return;
    }
    if (pass.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (register && pass.text != confirmPass.text) {
      _showError('Passwords do not match');
      return;
    }
    setState(() => loading = true);
    try {
      final a = FirebaseAuth.instance;
      if (register) {
        await Db.registerUser(
            name: displayName,
            email: emailAddress,
            password: pass.text);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        if (mounted) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      EmailVerificationScreen(email: emailAddress)));
        }
      } else {
        await a.signInWithEmailAndPassword(
            email: emailAddress, password: pass.text);
        await Db.ensureUserProfile();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final message = switch (e.code) {
          'email-already-in-use' => 'An account already exists for this email',
          'invalid-email' => 'Enter a valid email address',
          'weak-password' => 'Choose a stronger password',
          'invalid-credential' || 'wrong-password' || 'user-not-found' =>
            'Invalid email or password',
          _ => e.message ?? 'Could not complete the request',
        };
        _showError(message);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    name.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  InputDecoration deco({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      );

  Future<void> _googleSignIn() async {
    _showError('Google sign-in is not configured yet');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: 232,
                  width: double.infinity,
                  child: Stack(children: [
                    ClipPath(
                        clipper: _AuthHeaderClipper(),
                        child: Container(color: AppColors.primary)),
                    if (Navigator.canPop(context))
                      Positioned(
                          top: 12,
                          left: 16,
                          child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back))),
                    Positioned(
                      left: 28,
                      bottom: 46,
                      child: Text(register ? 'Create account' : 'Login',
                          style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                    ),
                  ]),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Welcome Back',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          register
                              ? 'Create your Ceylona account.\nYour journey begins here.'
                              : 'to Ceylona\nYour journey begins here.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 22),
                      if (register) ...[
                        TextField(
                            controller: name,
                            textCapitalization: TextCapitalization.words,
                            decoration: deco(
                                label: 'Full name',
                                icon: Icons.person_outline,
                                hint: 'Your name')),
                        const SizedBox(height: 14),
                      ],
                      TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: deco(
                              label: 'Email',
                              icon: Icons.alternate_email,
                              hint: 'abc@example.com')),
                      const SizedBox(height: 14),
                      TextField(
                          controller: pass,
                          obscureText: obscurePassword,
                          decoration: deco(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              hint: '••••••••',
                              suffix: IconButton(
                                  tooltip: 'Show password',
                                  onPressed: () => setState(() =>
                                      obscurePassword = !obscurePassword),
                                  icon: Icon(obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined)))),
                      if (register) ...[
                        const SizedBox(height: 14),
                        TextField(
                            controller: confirmPass,
                            obscureText: obscureConfirmation,
                            decoration: deco(
                                label: 'Confirm password',
                                icon: Icons.lock_outline,
                                hint: 'Repeat your password',
                                suffix: IconButton(
                                    tooltip: 'Show password',
                                    onPressed: () => setState(() =>
                                        obscureConfirmation =
                                            !obscureConfirmation),
                                    icon: Icon(obscureConfirmation
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined)))),
                      ],
                      if (!register)
                        Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: _resetPassword,
                                child: const Text('Forgot Password?'))),
                      const SizedBox(height: 6),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              onPressed: loading ? null : submit,
                              child: Text(loading
                                  ? (register
                                      ? 'Creating account...'
                                      : 'Signing in...')
                                  : (register ? 'Register' : 'Login')))),
                      const SizedBox(height: 18),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Or',
                                style: TextStyle(
                                    color: Colors.grey.shade600))),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 14),
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                              onPressed: loading ? null : _googleSignIn,
                              icon: const Icon(Icons.g_mobiledata, size: 26),
                              label: const Text('Continue with Google'))),
                      const SizedBox(height: 18),
                      Center(
                          child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                            Text(register
                                ? 'Already have an account? '
                                : 'Already haven\'t an account? '),
                            GestureDetector(
                                onTap: loading
                                    ? null
                                    : () => setState(() => register = !register),
                                child: Text(register ? 'Login' : 'Register',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700))),
                          ])),
                      const SizedBox(height: 8),
                      Center(
                          child: TextButton.icon(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminLoginScreen())),
                              icon: const Icon(Icons.admin_panel_settings,
                                  size: 18),
                              label: const Text('Authority Officer Login'))),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );

  Future<void> _resetPassword() async {
    if (email.text.trim().isEmpty) {
      _showError('Enter your email first');
      return;
    }
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email.text.trim());
    if (mounted) _showError('Password reset email sent');
  }
}

class _AuthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .72);
    path.cubicTo(size.width * .18, size.height, size.width * .28,
        size.height * .62, size.width * .48, size.height * .72);
    path.cubicTo(size.width * .68, size.height * .84, size.width * .78,
        size.height * .45, size.width, size.height * .62);
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AuthHeaderClipper oldClipper) => false;
}

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool checking = false;

  Future<void> _checkVerification() async {
    setState(() => checking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Open the verification link in your email first')));
      }
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _resend() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification email sent again')));
    }
  }

  Future<void> _backToLogin() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(children: [
              SizedBox(
                height: 232,
                child: Stack(children: [
                  ClipPath(
                      clipper: _AuthHeaderClipper(),
                      child: Container(color: AppColors.primary)),
                  Positioned(
                      top: 12,
                      left: 16,
                      child: IconButton(
                          onPressed: _backToLogin,
                          icon: const Icon(Icons.arrow_back))),
                  const Positioned(
                      left: 28,
                      bottom: 46,
                      child: Text('Email Verification',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark))),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Continue to Ceylona',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('We sent a verification link to:',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(widget.email,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(height: 24),
                      Center(
                          child: Icon(Icons.mark_email_read_outlined,
                              size: 70, color: AppColors.primary)),
                      const SizedBox(height: 18),
                      const Text(
                          'Open the email and tap the verification link. Then return here and press Verify email.'),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              onPressed: checking ? null : _checkVerification,
                              child: Text(
                                  checking ? 'Checking...' : 'Verify email'))),
                      const SizedBox(height: 12),
                      Center(
                          child: TextButton(
                              onPressed: checking ? null : _resend,
                              child: const Text('Didn\'t receive it? Resend email'))),
                    ]),
                  ),
                ),
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
