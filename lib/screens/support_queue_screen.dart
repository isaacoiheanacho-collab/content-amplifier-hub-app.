import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../models/boost.dart';

class SupportQueueScreen extends StatefulWidget {
  const SupportQueueScreen({super.key});

  @override
  State<SupportQueueScreen> createState() => _SupportQueueScreenState();
}

class _SupportQueueScreenState extends State<SupportQueueScreen> {
  List<Boost> _boosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoosts();
  }

  Future<void> _loadBoosts() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final boostService = BoostService(token);
      final boosts = await boostService.getLiveBoosts();
      setState(() {
        _boosts = boosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load boosts: $e')),
      );
    }
  }

  Future<void> _supportNow(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  Future<void> _confirmSupport(int boostId) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      if (token == null) return;
      final boostService = BoostService(token);
      await boostService.recordConfirmedSupport(boostId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support recorded!')),
      );
      await _loadBoosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording support: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_boosts.isEmpty) {
      return const Center(child: Text('No live boosts at the moment.'));
    }
    return RefreshIndicator(
      onRefresh: _loadBoosts,
      child: ListView.builder(
        itemCount: _boosts.length,
        itemBuilder: (context, index) {
          final boost = _boosts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boost.platform.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Category: ${boost.category}'),
                  const SizedBox(height: 8),
                  Text(boost.contentUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _supportNow(boost.contentUrl),
                        child: const Text('Support Now'),
                      ),
                      ElevatedButton(
                        onPressed: () => _confirmSupport(boost.id),
                        child: const Text('I Supported'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Supported by ${boost.confirmedSupportsCount} members'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}