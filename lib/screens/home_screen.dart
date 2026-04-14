import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/support_service.dart';
import '../services/boost_service.dart';
import '../models/member_profile.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/profile_avatar.dart';

class SupportHomeScreen extends StatefulWidget {
  const SupportHomeScreen({super.key});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen> {
  late SupportService _supportService;
  BoostService? _boostService;
  MemberProfile? _profile;
  int _points = 0;
  double _stars = 0.0;
  int _supportsGiven = 0;
  bool _hasBankInfo = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    _supportService = SupportService(token);
    _boostService = BoostService(token);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _supportService.getStats();
      setState(() {
        _points = stats['points'];
        _stars = stats['stars'];
        _supportsGiven = stats['supportsGiven'];
        _hasBankInfo = stats['hasBankInfo'];
      });

      if (_boostService != null) {
        final profile = await _boostService!.getMemberProfile();
        setState(() {
          _profile = profile;
        });
      }
    } catch (e) {
      print('Error loading support data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward() async {
    if (!_hasBankInfo) {
      final result = await Navigator.pushNamed(context, AppRoutes.bankInfo);
      if (result == true) {
        await _loadData();
        if (_hasBankInfo) {
          // Retry claim after bank info added
          _claimReward();
        }
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Claim Reward'),
        content: Text('You have $_stars stars. Claiming will deduct 20 stars and send you \$20. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Claim')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _supportService.claimReward();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim submitted! You will receive \$20 within 5-7 days.')),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim failed. Please contact support.')),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = (_profile?.name != null && _profile!.name!.trim().isNotEmpty)
        ? _profile!.name!
        : 'Supporter';

    return Scaffold(
      appBar: AppBar(title: const Text('Support Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile card
              Row(
                children: [
                  ProfileAvatar(radius: 30, imageUrl: _profile?.profilePhotoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, $displayName', style: Theme.of(context).textTheme.titleLarge),
                        const Chip(label: Text('Support Member', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statColumn('Points', _points, AppColors.primary),
                      _statColumn('Stars', _stars.toStringAsFixed(2), AppColors.accent),
                      _statColumn('Supports', _supportsGiven, AppColors.success),
                    ],
                  ),
                ),
              ),

              // Claim Reward button (only if stars >= 20)
              if (_stars >= 20)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _claimReward,
                      icon: const Icon(Icons.payment),
                      label: const Text('Claim Your Reward ($20)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Menu items
              _menuCard(
                icon: Icons.person_outline,
                title: 'Account Information',
                subtitle: 'Update your name, photo, region, and social links',
                onTap: () => Navigator.pushNamed(context, AppRoutes.accountInfo),
              ),
              const SizedBox(height: 12),

              _menuCard(
                icon: Icons.account_balance,
                title: 'Bank Details',
                subtitle: 'Update your bank account information for payouts',
                onTap: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.bankInfo);
                  if (result == true) await _loadData();
                },
              ),
              const SizedBox(height: 12),

              _menuCard(
                icon: Icons.settings_outline,
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
              const SizedBox(height: 24),

              // Reminder if bank info missing
              if (!_hasBankInfo)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bank info missing', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Add your bank account details to claim rewards.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, AppRoutes.bankInfo);
                            if (result == true) await _loadData();
                          },
                          child: const Text('Add Now'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
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
        leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : null)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}