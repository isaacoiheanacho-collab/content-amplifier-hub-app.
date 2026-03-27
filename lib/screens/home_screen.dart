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
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      if (token == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      final boostService = BoostService(token);
      final stats = await boostService.getMemberStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStats,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final stats = _stats!;
    final boostsLeft = (stats['max_monthly_boosts'] as int) - (stats['monthly_boosts_used'] as int);
    final supportsGiven = stats['supports_given'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${stats['email']}'),
            const SizedBox(height: 8),
            Text('Membership: ${stats['membership_active'] ? 'Active' : 'Inactive'}'),
            const SizedBox(height: 8),
            Text('Boosts used: ${stats['monthly_boosts_used']}/${stats['max_monthly_boosts']}'),
            const SizedBox(height: 8),
            Text('Supports given: $supportsGiven'),
            const SizedBox(height: 8),
            Text('Supports received: ${stats['supports_received']}'),
            const SizedBox(height: 24),
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