import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';
import '../models/social_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedCountry;
  File? _profileImage;
  final List<SocialProfile> _socials = [];
  final List<String> _selectedInterests = [];

  final List<String> _countries = ['United States', 'United Kingdom', 'Canada', 'Nigeria', 'Kenya', 'South Africa', 'Ghana', 'Other'];
  final List<String> _interestOptions = ['Music', 'Comedy', 'Business', 'Faith', 'Education', 'Gaming', 'Fashion', 'Tech'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addSocial() {
    showDialog(
      context: context,
      builder: (context) {
        String platform = 'instagram';
        String handle = '';
        bool boostEnabled = true;
        return AlertDialog(
          title: const Text('Add social account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: platform,
                items: ['instagram', 'tiktok', 'youtube', 'facebook', 'x']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                    .toList(),
                onChanged: (v) => platform = v!,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Username / URL'),
                onChanged: (v) => handle = v,
              ),
              CheckboxListTile(
                title: const Text('Boost and support on this platform'),
                value: boostEnabled,
                onChanged: (v) => boostEnabled = v!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _socials.add(SocialProfile(
                    platform: platform,
                    handle: handle,
                    boostEnabled: boostEnabled,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 40, color: AppColors.primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextInputField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person,
              validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCountry = v),
              decoration: const InputDecoration(labelText: 'Country', prefixIcon: Icon(Icons.public)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Social accounts', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _addSocial,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_socials.isNotEmpty)
              ..._socials.map((s) => ListTile(
                    leading: Icon(_platformIcon(s.platform)),
                    title: Text(s.platform.toUpperCase()),
                    subtitle: Text(s.handle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _socials.remove(s)),
                    ),
                  )),
            const SizedBox(height: 24),
            Text('Interests (optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _interestOptions.map((interest) {
                final selected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: selected,
                  onSelected: (_) => _toggleInterest(interest),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Continue to membership',
              onPressed: () {
                // TODO: Save profile data locally or send to backend
                Navigator.pushReplacementNamed(context, AppRoutes.payment);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'instagram':
        return Icons.photo_camera;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_circle;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.link;
    }
  }
}