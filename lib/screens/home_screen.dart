import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _stats!;
    final boostsLeft = (stats['max_monthly_boosts'] as int) - (stats['monthly_boosts_used'] as int);
    final supportsGiven = stats['supports_given'] ?? 0;
    final streak = 0; // TODO: implement streak tracking

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ProfileAvatar(radius: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${stats['email']?.split('@').first ?? 'Member'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Chip(
                        label: Text(
                          stats['membership_active'] ? 'Active Member' : 'Inactive',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: stats['membership_active']
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: stats['membership_active'] ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statColumn('Boosts left', boostsLeft, AppColors.primary),
                    _statColumn('Supports given', supportsGiven, AppColors.success),
                    _statColumn('Streak', streak, AppColors.accent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _actionCard(
                  icon: Icons.thumb_up,
                  label: 'Support Now',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.supportQueue),
                  color: AppColors.primary,
                ),
                _actionCard(
                  icon: Icons.add,
                  label: 'Submit a Boost',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.submitBoost),
                  color: AppColors.accent,
                ),
                _actionCard(
                  icon: Icons.history,
                  label: 'My Boosts',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.myBoosts),
                  color: AppColors.textSecondary,
                ),
                _actionCard(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}