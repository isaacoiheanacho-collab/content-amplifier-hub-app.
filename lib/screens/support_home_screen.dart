import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/support_service.dart';
import '../services/boost_service.dart';
import '../models/boost.dart';
import '../models/member_profile.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/profile_avatar.dart';
import 'image_viewer_screen.dart';
import 'reward_analyses_screen.dart';

class SupportHomeScreen extends StatefulWidget {
  const SupportHomeScreen({super.key});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen> {
  late SupportService _supportService;
  BoostService? _boostService;

  MemberProfile? _profile;
  List<Boost> _boosts = [];

  final Map<int, Timer?> _timers = {};
  final Map<int, int> _secondsRemaining = {};
  final Map<int, bool> _confirmEnabled = {};

  bool _isLoading = true;
  int _points = 0;
  double _stars = 0.0;
  int _supportsGiven = 0;
  bool _hasBankInfo = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();

    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    _supportService = SupportService(token);
    _boostService = BoostService(token);

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Load support stats
      final stats = await _supportService.getStats();
      setState(() {
        _points = stats['points'];
        _stars = (stats['stars'] is num)
            ? (stats['stars'] as num).toDouble()
            : double.tryParse(stats['stars'].toString()) ?? 0.0;
        _supportsGiven = stats['supportsGiven'];
        _hasBankInfo = stats['hasBankInfo'];
      });

      // 2. Load profile (name, photo) – same pattern as HomeScreen
      if (_boostService != null) {
        try {
          final profile = await _boostService!.getMemberProfile();
          setState(() {
            _profile = profile;
          });
        } catch (e) {
          // Profile failing should not break the whole screen
          debugPrint('Error loading member profile: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not load profile details')),
            );
          }
        }
      }

      // 3. Load available boosts
      final boosts = await _supportService.getAvailableBoosts();
      setState(() {
        _boosts = boosts;
        for (final b in boosts) {
          _secondsRemaining[b.id] = 0;
          _confirmEnabled[b.id] = false;
        }
      });
    } catch (e) {
      debugPrint('Error loading support data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBoostClick(Boost boost) async {
    if (_timers[boost.id] != null) return;

    await _supportService.recordClick(boost.id);
    await _supportService.openBoostLink(boost.contentUrl);

    setState(() {
      _secondsRemaining[boost.id] = 30;
      _confirmEnabled[boost.id] = false;
    });

    _timers[boost.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final current = _secondsRemaining[boost.id] ?? 0;
        if (current > 0) {
          _secondsRemaining[boost.id] = current - 1;
        }
        if (_secondsRemaining[boost.id] == 0) {
          timer.cancel();
          _timers[boost.id] = null;
          _confirmEnabled[boost.id] = true;
        }
      });
    });
  }

  Future<void> _confirmEngagement(Boost boost) async {
    try {
      final result = await _supportService.confirmEngagement(boost.id);

      setState(() {
        _boosts.removeWhere((b) => b.id == boost.id);
        _timers[boost.id]?.cancel();
        _timers.remove(boost.id);
        _secondsRemaining.remove(boost.id);
        _confirmEnabled.remove(boost.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Engagement confirmed! Points: ${result['points']}, Stars: ${result['stars']}',
            ),
          ),
        );
      }

      final stats = await _supportService.getStats();
      setState(() {
        _points = stats['points'];
        _stars = (stats['stars'] is num)
            ? (stats['stars'] as num).toDouble()
            : double.tryParse(stats['stars'].toString()) ?? 0.0;
        _supportsGiven = stats['supportsGiven'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Fallback logic: prefer profile.name, then profile.email prefix, then "Supporter"
    final displayName = (() {
      final p = _profile;
      if (p != null && p.name != null && p.name!.trim().isNotEmpty) {
        return p.name!;
      }
      if (p != null && p.email.isNotEmpty) {
        return p.email.split('@').first;
      }
      return 'Supporter';
    })();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar + name
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final url = _profile?.profilePhotoUrl;
                      if (url != null && url.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewerScreen(
                              imageUrl: url,
                              heroTag: 'support_profile_photo',
                            ),
                          ),
                        );
                      }
                    },
                    child: ProfileAvatar(
                      radius: 30,
                      imageUrl: _profile?.profilePhotoUrl,
                    ),
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
                        const Chip(
                          label: Text(
                            'Support Member',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statColumn('Points', _points.toString(), AppColors.primary),
                      _statColumn('Stars', _stars.toStringAsFixed(2), AppColors.accent),
                      _statColumn('Supports', _supportsGiven.toString(), AppColors.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Support Now section
              Text(
                'Support Now',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (_boosts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'No boosts available at the moment. Check back later!',
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _boosts.length,
                  itemBuilder: (context, index) {
                    final boost = _boosts[index];
                    final timerActive = _timers[boost.id] != null;
                    final seconds = _secondsRemaining[boost.id] ?? 0;
                    final canConfirm = _confirmEnabled[boost.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    boost.platform,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const Spacer(),
                                if (timerActive)
                                  Chip(
                                    label: Text('Wait $seconds s'),
                                    backgroundColor: Colors.orange.shade100,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              boost.contentUrl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            if (!timerActive && !canConfirm)
                              ElevatedButton(
                                onPressed: () => _handleBoostClick(boost),
                                child: const Text('Boost Now'),
                              ),
                            if (timerActive && !canConfirm)
                              const OutlinedButton(
                                onPressed: null,
                                child: Text('Wait for timer...'),
                              ),
                            if (canConfirm)
                              ElevatedButton(
                                onPressed: () => _confirmEngagement(boost),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('I engaged! Confirm'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Profile menu
              const Text(
                'Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _menuCard(
                icon: Icons.person_outline,
                title: 'Account Information',
                subtitle: 'Update your name, photo, region, and social links',
                onTap: () => Navigator.pushNamed(context, AppRoutes.accountInfo),
              ),
              const SizedBox(height: 12),
              _menuCard(
                icon: Icons.analytics_outlined,
                title: 'Reward Analyses',
                subtitle: 'View your earnings and claim rewards',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RewardAnalysesScreen(
                      points: _points,
                      stars: _stars,
                      hasBankInfo: _hasBankInfo,
                      onRewardClaimed: _loadData,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _menuCard(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Terms, Privacy, Disclaimer, Help',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settingsMenu),
              ),
              const SizedBox(height: 12),
              _menuCard(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: _logout,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : null),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    super.dispose();
  }
}
