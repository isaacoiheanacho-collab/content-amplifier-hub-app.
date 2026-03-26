import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final boostService = BoostService(token);
      final stats = await boostService.getMemberStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stats == null) {
      return const Center(child: Text('Could not load profile data.'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_stats!['email']}'),
            const SizedBox(height: 8),
            Text('Membership Active: ${_stats!['membership_active'] ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Boosts Used: ${_stats!['monthly_boosts_used']}/${_stats!['max_monthly_boosts']}'),
            const SizedBox(height: 8),
            Text('Supports Given: ${_stats!['supports_given']}'),
            const SizedBox(height: 8),
            Text('Supports Received: ${_stats!['supports_received']}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}