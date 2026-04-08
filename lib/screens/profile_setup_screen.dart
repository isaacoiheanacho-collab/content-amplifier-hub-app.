import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../utils/theme.dart';
import '../utils/routes.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';
import '../models/social_profile.dart';
import '../models/member_profile.dart';
import '../services/auth_service.dart';
import '../services/boost_service.dart';
import 'payment_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCountry;
  File? _profileImage;
  bool _isLoading = false;

  final List<SocialProfile> _socials = [];
  final List<String> _selectedInterests = [];

  final List<String> _countries = [
    'United States', 'United Kingdom', 'Canada', 'Nigeria', 'Kenya', 'South Africa', 'Ghana', 'Other'
  ];
  final List<String> _interestOptions = [
    'Music', 'Comedy', 'Business', 'Faith', 'Education', 'Gaming', 'Fashion', 'Tech'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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
        return AlertDialog(
          title: const Text('Add social account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: platform,
                items: ['instagram', 'tiktok', 'youtube', 'facebook']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                    .toList(),
                onChanged: (v) => platform = v!,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Username / URL'),
                onChanged: (v) => handle = v,
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
                if (handle.isNotEmpty) {
                  setState(() {
                    _socials.add(SocialProfile(
                      platform: platform,
                      handle: handle,
                      boostEnabled: true,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAndPay() async {
    if (_nameController.text.isEmpty || _selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and country')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();
      
      if (token == null) throw Exception("Session expired. Please login again.");

      // 1. SAVE PROFILE DATA TO BACKEND
      final boostService = BoostService(token);
      
      String? youtube, facebook, tiktok;
      for (var s in _socials) {
        if (s.platform == 'youtube') youtube = s.handle;
        if (s.platform == 'facebook') facebook = s.handle;
        if (s.platform == 'tiktok') tiktok = s.handle;
      }

      final profileUpdate = MemberProfile(
        email: auth.currentUser?.email ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        region: _selectedCountry,
        youtubeUrl: youtube,
        facebookUrl: facebook,
        tiktokUrl: tiktok,
        membershipActive: false,
        monthlyBoostsUsed: 0,
        maxMonthlyBoosts: 20,
        supportsGiven: 0,
        supportsReceived: 0,
      );

      // Upload profile details and image
      await boostService.updateMemberProfile(profileUpdate, imageFile: _profileImage);

      // 2. FETCH PAYSTACK URL FROM BACKEND
      final response = await http.post(
        Uri.parse('$baseUrl/member/payment-url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (mounted) {
          // 3. NAVIGATE TO PAYMENT SCREEN WITH REAL SERVER DATA
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                paymentUrl: data['paymentUrl'],
                amount: (data['amountToPay'] as num).toDouble(),
                currency: data['currency'] ?? "USD",
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to generate payment link. Please try again.");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
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
                ),
                const SizedBox(height: 16),
                TextInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCountry = v),
                  decoration: const InputDecoration(
                    labelText: 'Country', 
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
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
                      onSelected: (val) {
                        setState(() {
                          val ? _selectedInterests.add(interest) : _selectedInterests.remove(interest);
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Continue to membership',
                  onPressed: _submitAndPay,
                ),
              ],
            ),
          ),
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'instagram': return Icons.photo_camera;
      case 'tiktok': return Icons.music_note;
      case 'youtube': return Icons.play_circle;
      case 'facebook': return Icons.facebook;
      default: return Icons.link;
    }
  }
}