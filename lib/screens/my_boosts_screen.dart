import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../models/boost.dart';

class MyBoostsScreen extends StatefulWidget {
  const MyBoostsScreen({super.key});

  @override
  State<MyBoostsScreen> createState() => _MyBoostsScreenState();
}

class _MyBoostsScreenState extends State<MyBoostsScreen> {
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
      final boosts = await boostService.getMyBoosts();
      setState(() {
        _boosts = boosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load your boosts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_boosts.isEmpty) {
      return const Center(child: Text('You haven\'t submitted any boosts yet.'));
    }
    return RefreshIndicator(
      onRefresh: _loadBoosts,
      child: ListView.builder(
        itemCount: _boosts.length,
        itemBuilder: (context, index) {
          final boost = _boosts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(boost.platform.toUpperCase()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(boost.contentUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Category: ${boost.category}'),
                  Text('Status: ${boost.status}'),
                ],
              ),
              trailing: Text('${boost.confirmedSupportsCount} supports'),
            ),
          );
        },
      ),
    );
  }
}