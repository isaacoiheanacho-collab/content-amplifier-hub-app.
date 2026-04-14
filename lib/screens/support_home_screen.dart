import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/support_service.dart';
import '../models/boost.dart';
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
  List<Boost> _boosts = [];
  Map<int, Timer?> _timers = {};
  Map<int, int> _secondsRemaining = {};
  Map<int, bool> _confirmEnabled = {};
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
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    _supportService = SupportService(token);
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
      final boosts = await _supportService.getAvailableBoosts();
      setState(() {
        _boosts = boosts;
        _isLoading = false;
        for (var b in boosts) {
          _secondsRemaining[b.id] = 0;
          _confirmEnabled[b.id] = false;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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
        if (_secondsRemaining[boost.id]! > 0) {
          _secondsRemaining[boost.id] = _secondsRemaining[boost.id]! - 1;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Engagement confirmed! Points: ${result['points']}, Stars: ${result['stars']}')),
      );
      final stats = await _supportService.getStats();
      setState(() {
        _points = stats['points'];
        _stars = stats['stars'];
        _supportsGiven = stats['supportsGiven'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _claimReward() async {
    if (!_hasBankInfo) {
      final result = await Navigator.pushNamed(context, AppRoutes.bankInfo);
      if (result == true) await _loadData();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Support Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                children: [
                  ProfileAvatar(radius: 30, imageUrl: null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hi, Supporter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 24),
              // Support Now section
              Text('Support Now', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_boosts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text('No boosts available at the moment. Check back later!'),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(boost.platform, style: const TextStyle(fontSize: 12)),
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
                            Text(boost.contentUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('I engaged! Confirm'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              if (_stars >= 20)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _claimReward,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Claim Your Reward (\$20)'),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.accountInfo),
                  child: const Text('Edit Profile'),
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

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    super.dispose();
  }
}