import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';
import '../models/social_profile.dart';
import '../models/plan.dart';

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

  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Nigeria',
    'Kenya',
    'South Africa',
    'Ghana',
    'Other'
  ];

  final List<String> _interestOptions = [
    'Music',
    'Comedy',
    'Business',
    'Faith',
    'Education',
    'Gaming',
    'Fashion',
    'Tech'
  ];

  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfilePhoto(String token) async {
    if (_profileImage == null) return null;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/member/upload-photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('photo', _profileImage!.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return data['url'];
    }

    return null;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        return;
      }

      // 1. Upload profile photo
      final photoUrl = await _uploadProfilePhoto(token);

      // 2. Save profile data
      final profileRes = await http.post(
        Uri.parse('$baseUrl/member/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'country': _selectedCountry,
          'interests': _selectedInterests,
          'socials': _socials.map((s) => s.toJson()).toList(),
          'profile_photo_url': photoUrl,
        }),
      );

      if (profileRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
        return;
      }

      // 3. Request payment URL
      final payRes = await http.post(
        Uri.parse('$baseUrl/member/payment-url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (payRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate payment link')),
        );
        return;
      }

      final payData = jsonDecode(payRes.body);

      // 4. Navigate to PaymentScreen
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.payment,
        arguments: {
          'paymentUrl': payData['paymentUrl'],
          'plan': Plan(
            name: 'Yearly Membership',
            price: payData['amountToPay'],
            description: '',
          ),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
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
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCountry = v),
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Social accounts',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Interests (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _interestOptions.map((interest) {
                final selected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selected
                          ? _selectedInterests.remove(interest)
                          : _selectedInterests.add(interest);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Continue to membership',
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
