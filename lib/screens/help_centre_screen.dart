import 'package:flutter/material.dart';

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Centre")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const Text("• How do I boost content?"),
          const Text("• Why do I need to pay maintenance fees?"),
          const Text("• How do I update my profile?"),
          const Text("• Why was my boost rejected?"),
          const SizedBox(height: 20),

          const Text(
            "Support Email",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          const Text("support@contentamplifierhub.com"),
        ],
      ),
    );
  }
}
