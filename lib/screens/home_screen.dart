import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../models/member_stats.dart';
import '../models/member_profile.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MemberStats? _stats;
  MemberProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
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
      final profile = await boostService.getMemberProfile();

      setState(() {
        _stats = stats;
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
              Text('Error loading data: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null || _profile == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final stats = _stats!;
    final profile = _profile!;
    final boostsLeft = stats.maxMonthlyBoosts - stats.monthlyBoostsUsed;

    final displayName = (profile.name != null && profile.name!.trim().isNotEmpty)
        ? profile.name!
        : stats.email.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                ProfileAvatar(
                  radius: 30,
                  imageUrl: profile.profilePhotoUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $displayName',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Chip(
                        label: Text(
                          stats.membershipActive ? 'Active Member' : 'Inactive',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: stats.membershipActive
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: stats.membershipActive
                              ? AppColors.success
                              : AppColors.error,
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
                    _statColumn('Supports given', stats.supportsGiven, AppColors.success),
                    _statColumn('Streak', 0, AppColors.accent),
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

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
