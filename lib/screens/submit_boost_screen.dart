import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';

class SubmitBoostScreen extends StatefulWidget {
  const SubmitBoostScreen({super.key});

  @override
  State<SubmitBoostScreen> createState() => _SubmitBoostScreenState();
}

class _SubmitBoostScreenState extends State<SubmitBoostScreen> {
  final _urlController = TextEditingController();
  String _platform = 'youtube';
  String _category = 'music';
  bool _isLoading = false;

  final List<String> _platforms = ['youtube', 'tiktok', 'facebook'];
  final List<String> _categories = ['music', 'comedy', 'gaming', 'education', 'business', 'faith', 'other'];

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      final memberId = await auth.getMemberId();

      if (token == null || memberId == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final boostService = BoostService(token);
      final result = await boostService.submitBoost(
        memberId: memberId,
        contentUrl: _urlController.text.trim(),
        platform: _platform,
        category: _category,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Boost queued for ${result.slot}')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Submission failed')),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Boost')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _platform,
              items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _platform = v!),
              decoration: const InputDecoration(labelText: 'Platform'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Content URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}