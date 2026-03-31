import 'package:flutter/material.dart';
import '../utils/routes.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // T&Cs
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms & Conditions"),
            subtitle: const Text("Terms of Service, Terms & Conditions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            subtitle: const Text("Privacy Policy, Intellectual Property Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
          ),

          // Disclaimer
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text("Disclaimer"),
            subtitle: const Text("Disclaimer, Community Guidelines"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRoutes.disclaimer),
          ),

          // Help Centre
          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text("Help Centre"),
            subtitle: const Text("FAQ, Support Email"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCentreScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
