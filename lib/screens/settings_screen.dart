import 'package:flutter/material.dart';
import '../utils/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.accountInfo),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Billing'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.billing),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settingsMenu),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Login'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.loginMenu),
          ),
        ],
      ),
    );
  }
}
