import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../utils/routes.dart';

class LoginMenuScreen extends StatelessWidget {
  const LoginMenuScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text("Logout"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
