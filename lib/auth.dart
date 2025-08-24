import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool showRegister = false;
  void toggle() => setState(() => showRegister = !showRegister);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary
              ),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello, ${user.displayName ?? user.email}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete_forever, color: Colors.white),
                          label: const Text('Delete Account', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            side: BorderSide.none,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _confirmDelete(user),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return showRegister ? _RegisterScreen(onCancel: toggle) : _LoginScreen(onSwitch: toggle);
      },
    );
  }

  Future<void> _confirmDelete(User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text('This will permanently delete your account without recovery.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await user.delete();
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'requires-recent-login'
          ? 'Please sign in again before deleting your account.'
          : 'Failed: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

class _LoginScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const _LoginScreen({required this.onSwitch});
  @override
  __LoginScreenState createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  final _form = GlobalKey<FormState>();
  String email = '', password = '';
  bool loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Sign In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v != null && v.contains('@')) ? null : 'Invalid email',
                    onSaved: (v) => email = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 characters',
                    onSaved: (v) => password = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading ? const CircularProgressIndicator() : const Text('Sign In'),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: widget.onSwitch,
                    child: Text('Create a new account', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterScreen extends StatefulWidget {
  final VoidCallback onCancel;
  const _RegisterScreen({required this.onCancel});
  @override
  __RegisterScreenState createState() => __RegisterScreenState();
}

class __RegisterScreenState extends State<_RegisterScreen> {
  final _form = GlobalKey<FormState>();
  String name = '', email = '', password = '';
  bool agreePrivacy = false, confirm19 = false, isProcessing = false;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _privacyTap = TapGestureRecognizer()..onTap = _launchPrivacy;
  }

  @override void dispose() {
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _launchPrivacy() async {
    final uri = Uri.parse('https://docs.google.com/document/d/13vMohp8mmCnU1mIDj0GF3fXmcBGmuefY/edit?usp=sharing&ouid=101016846157835028069&rtpof=true&sd=true');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Privacy Policy link')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || !agreePrivacy || !confirm19) return;
    _form.currentState!.save();
    setState(() => isProcessing = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter your name' : null,
                      onSaved: (v) => name = v!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v != null && v.contains('@')) ? null : 'Valid email required',
                      onSaved: (v) => email = v!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (v) => (v != null && v.length >= 6) ? null : 'At least 6 characters',
                      onSaved: (v) => password = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _privacyTap,
                            ),
                          ],
                        ),
                      ),
                      value: agreePrivacy,
                      onChanged: (v) => setState(() => agreePrivacy = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('I confirm I am at least 18 years old'),
                      value: confirm19,
                      onChanged: (v) => setState(() => confirm19 = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (!isProcessing && agreePrivacy && confirm19) ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isProcessing 
                          ? const CircularProgressIndicator()
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}