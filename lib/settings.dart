import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:share2cash/Themes/ThemeProvider.dart';
import 'package:share2cash/card_chekout.dart';
import 'package:share2cash/fireStoreServices.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const double _horizontalPadding = 16.0;
  static const double _verticalSectionGap = 24.0;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    Future<void> _launchPrivacyPolicy() async {
      const url =
          'https://docs.google.com/document/d/13vMohp8mmCnU1mIDj0GF3fXmcBGmuefY/edit?usp=sharing&ouid=101016846157835028069&rtpof=true&sd=true';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    Future<void> signOutAndRedirect() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/LoginScreen', (route) => false);
    }

    Future<void> deleteAccountAndRedirect() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (cx) => AlertDialog(
          title: const Text('Confirm action'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(cx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(cx).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      try {
        await user?.delete();
        await FirebaseAuth.instance.signOut();
        
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/LoginScreen', (route) => false);
      } on FirebaseAuthException catch (e) {
        final msg = e.code == 'requires-recent-login'
            ? 'Please sign in again before deleting your account.'
            : 'Failed to delete account: ${e.message ?? e.code}';

        if (mountedWithContext(context)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
       Navigator.of(
          context,
        ).pop();
    }

    void _withdraw() {
      showMaterialModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Center(
            child: CardEntryPage(firestoreService: FirestoreService()),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SettingsPage._horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Guest User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: user != null ? signOutAndRedirect : null,
                child: Text(user != null ? 'Sign out' : 'Not signed in'),
              ),
              const SizedBox(height: SettingsPage._verticalSectionGap),
              const Divider(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Dark mode'),
                      secondary: Icon(
                        Icons.dark_mode,
                        color: colorScheme.onSurface,
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (v) {
                        setState(() {
                          themeProvider.toggleTheme();
                          Navigator.of(context).pop();
                        });
                        final modeLabel = v
                            ? 'Dark mode enabled'
                            : 'Light mode enabled';
                           
                            
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(modeLabel)));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.credit_card,
                        color: colorScheme.onSurface,
                      ),
                      title: const Text('Withdraw'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _withdraw,
                    ),
                    const Divider(),
                    const SizedBox(height: SettingsPage._verticalSectionGap),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: colorScheme.onSurface,
                      ),
                      title: const Text('FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed('/faq'),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip,
                        color: colorScheme.onSurface,
                      ),
                      title: const Text('Privacy Policy'),
                      trailing: Icon(
                        Icons.open_in_new,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _launchPrivacyPolicy,
                    ),
                    const SizedBox(height: SettingsPage._verticalSectionGap),
                    ListTile(
                      leading: Icon(Icons.delete, color: colorScheme.error),
                      title: Text(
                        'Delete account',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      onTap: user != null ? deleteAccountAndRedirect : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool mountedWithContext(BuildContext context) {
    // Workaround to know if widget is still in tree
    // Alternatively, use StatefulWidget if needed
    return true;
  }
}
