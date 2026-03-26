import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../utils/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      if (token == null) {
        setState(() => _message = "Not logged in");
        return;
      }
      final boostService = BoostService(token);
      final stats = await boostService.getMemberStats();
      setState(() => _message = "Stats loaded: $stats");
    } catch (e) {
      setState(() => _message = "Error: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}