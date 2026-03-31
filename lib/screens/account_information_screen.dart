import 'package:flutter/material.dart';
import '../services/boost_service.dart';
import '../models/member_profile.dart';

class AccountInformationScreen extends StatefulWidget {
  final BoostService boostService;

  const AccountInformationScreen({super.key, required this.boostService});

  @override
  State<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  bool _loading = true;
  bool _saving = false;

  MemberProfile? _profile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.boostService.getMemberProfile();

      setState(() {
        _profile = profile;
        _nameController.text = profile.name ?? '';
        _phoneController.text = profile.phone ?? '';
        _regionController.text = profile.region ?? '';
        _photoController.text = profile.profilePhotoUrl ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    setState(() => _saving = true);

    final updated = MemberProfile(
      email: _profile!.email,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      region: _regionController.text.trim(),
      profilePhotoUrl: _photoController.text.trim(),
      membershipActive: _profile!.membershipActive,
      monthlyBoostsUsed: _profile!.monthlyBoostsUsed,
      maxMonthlyBoosts: _profile!.maxMonthlyBoosts,
      supportsGiven: _profile!.supportsGiven,
      supportsReceived: _profile!.supportsReceived,
    );

    final success = await widget.boostService.updateMemberProfile(updated);

    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo Preview
            if (_photoController.text.isNotEmpty)
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(_photoController.text),
              )
            else
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 40),
              ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _regionController,
              decoration: const InputDecoration(
                labelText: "Region / State",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: "Profile Photo URL",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
