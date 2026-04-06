import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../models/member_profile.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;

  MemberProfile? _profile;
  late BoostService _boostService;

  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();

    _boostService = BoostService(token!);

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _boostService.getMemberProfile();

      setState(() {
        _profile = profile;
        _nameController.text = profile.name ?? '';
        _phoneController.text = profile.phone ?? '';
        _regionController.text = profile.region ?? '';

        _youtubeController.text = profile.youtubeUrl ?? '';
        _facebookController.text = profile.facebookUrl ?? '';
        _tiktokController.text = profile.tiktokUrl ?? '';

        _photoUrl = profile.profilePhotoUrl;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  // ------------------------------------------------------------
  // PHOTO UPLOAD
  // ------------------------------------------------------------
  Future<void> _pickPhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    await _uploadPhoto(File(file.path));
  }

  Future<void> _takePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return;

    await _uploadPhoto(File(file.path));
  }

  Future<void> _uploadPhoto(File file) async {
    setState(() => _uploadingPhoto = true);

    try {
      final url = await _boostService.uploadProfilePhoto(file);

      setState(() {
        _photoUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo')),
      );
    }

    setState(() => _uploadingPhoto = false);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SAVE PROFILE
  // ------------------------------------------------------------
  Future<void> _saveProfile() async {
    if (_profile == null) return;

    setState(() => _saving = true);

    final updated = MemberProfile(
      email: _profile!.email,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      region: _regionController.text.trim(),
      profilePhotoUrl: _photoUrl,
      youtubeUrl: _youtubeController.text.trim(),
      facebookUrl: _facebookController.text.trim(),
      tiktokUrl: _tiktokController.text.trim(),
      membershipActive: _profile!.membershipActive,
      monthlyBoostsUsed: _profile!.monthlyBoostsUsed,
      maxMonthlyBoosts: _profile!.maxMonthlyBoosts,
      supportsGiven: _profile!.supportsGiven,
      supportsReceived: _profile!.supportsReceived,
    );

    final success = await _boostService.updateMemberProfile(updated);

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
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
            GestureDetector(
              onTap: _uploadingPhoto ? null : _showPhotoOptions,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  if (_uploadingPhoto)
                    const CircularProgressIndicator(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildField(_nameController, "Full Name"),
            const SizedBox(height: 16),

            _buildField(_phoneController, "Phone Number"),
            const SizedBox(height: 16),

            _buildField(_regionController, "Region / State"),
            const SizedBox(height: 16),

            _buildField(_youtubeController, "YouTube Profile Link"),
            const SizedBox(height: 16),

            _buildField(_facebookController, "Facebook Profile Link"),
            const SizedBox(height: 16),

            _buildField(_tiktokController, "TikTok Profile Link"),
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

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
