import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/support_service.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';

class RewardAnalysesScreen extends StatefulWidget {
  final int points;
  final double stars;
  final bool hasBankInfo;
  final VoidCallback onRewardClaimed;

  const RewardAnalysesScreen({
    super.key,
    required this.points,
    required this.stars,
    required this.hasBankInfo,
    required this.onRewardClaimed,
  });

  @override
  State<RewardAnalysesScreen> createState() => _RewardAnalysesScreenState();
}

class _RewardAnalysesScreenState extends State<RewardAnalysesScreen> {
  late SupportService _supportService;
  bool _isLoading = false;
  int _points = 0;
  double _stars = 0.0;
  bool _hasBankInfo = false;

  @override
  void initState() {
    super.initState();
    _points = widget.points;
    _stars = widget.stars;
    _hasBankInfo = widget.hasBankInfo;
    _initService();
  }

  Future<void> _initService() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    if (token != null) {
      _supportService = SupportService(token);
      // Refresh stats from server
      final stats = await _supportService.getStats();
      setState(() {
        _points = stats['points'];
        _stars = stats['stars'];
        _hasBankInfo = stats['hasBankInfo'];
      });
    }
  }

  Future<void> _claimReward() async {
    if (_stars < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least 20 stars to claim a reward.')),
      );
      return;
    }
    if (!_hasBankInfo) {
      final result = await Navigator.pushNamed(context, AppRoutes.bankInfo);
      if (result == true) {
        setState(() => _hasBankInfo = true);
        // Retry claim after adding bank info
        _claimReward();
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await _supportService.claimReward();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim submitted! You will receive \$20 within 5-7 days.')),
        );
        widget.onRewardClaimed(); // refresh parent dashboard
        Navigator.pop(context); // return to dashboard
      } else {
        throw Exception('Claim failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final starsNeeded = 20 - _stars;
    final progress = (_stars / 20).clamp(0.0, 1.0);
    final canClaim = _stars >= 20;

    return Scaffold(
      appBar: AppBar(title: const Text('Reward Analyses')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoColumn('Total Points', _points.toString(), AppColors.primary),
                    _infoColumn('Stars', _stars.toStringAsFixed(2), AppColors.accent),
                    _infoColumn('Approx. Earnings', '\$${_stars.toStringAsFixed(0)}', Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress toward next claim
            const Text('Progress to next reward (20 stars)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: canClaim ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 8),
            Text('${_stars.toStringAsFixed(1)} / 20 stars (${starsNeeded > 0 ? '$starsNeeded more needed' : 'Ready to claim!'})'),
            const SizedBox(height: 24),

            // Claim button (red/green)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _claimReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canClaim ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(canClaim ? 'Claim Your \$20 Reward' : 'Not enough stars ($starsNeeded more needed)'),
              ),
            ),
            const SizedBox(height: 24),

            // Optional: Simple chart placeholder
            const Text('Earnings breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Chart coming soon...', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}