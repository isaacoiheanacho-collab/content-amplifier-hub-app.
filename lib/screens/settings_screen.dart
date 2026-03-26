import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            onTap: () => _openLink(context, 'https://your-terms-url.com'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () => _openLink(context, 'https://your-privacy-url.com'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _openLink(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Link'),
        content: Text('Open $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}