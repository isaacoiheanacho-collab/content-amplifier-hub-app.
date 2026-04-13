import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/boost_service.dart';
import '../models/member_profile.dart';
import '../utils/theme.dart';
import '../widgets/primary_button.dart'; // optional, but we reuse theme

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  bool _loading = true;
  bool _saving = false;

  MemberProfile? _profile;
  late BoostService _boostService;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // We'll replace the simple region field with dropdowns
  String? _selectedCountry;
  String? _selectedState;
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  String? _photoUrl;

  // Country/State map (same as in ProfileSetupScreen)
  final Map<String, List<String>> countryStates = {
    "United States": [
      "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
      "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
      "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
      "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
      "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
      "New Hampshire", "New Jersey", "New Mexico", "New York",
      "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
      "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
      "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
      "West Virginia", "Wisconsin", "Wyoming"
    ],
    "United Kingdom": ["England", "Scotland", "Wales", "Northern Ireland"],
    "Canada": [
      "Ontario", "Quebec", "British Columbia", "Alberta", "Manitoba",
      "Saskatchewan", "Nova Scotia", "New Brunswick", "Newfoundland & Labrador",
      "Prince Edward Island"
    ],
    "Australia": [
      "New South Wales", "Victoria", "Queensland", "Western Australia",
      "South Australia", "Tasmania", "Northern Territory", "Australian Capital Territory"
    ],
    "Nigeria": [
      "Lagos", "Abuja", "Rivers", "Enugu", "Kano", "Kaduna", "Oyo", "Ogun",
      "Delta", "Edo", "Anambra", "Imo", "Abia", "Akwa Ibom", "Cross River",
      "Benue", "Kogi", "Kwara", "Plateau", "Nasarawa", "Borno", "Yobe",
      "Sokoto", "Zamfara", "Kebbi", "Taraba", "Gombe", "Bauchi", "Jigawa",
      "Ondo", "Ekiti", "Bayelsa"
    ],
    "Kenya": ["Nairobi", "Mombasa", "Kisumu", "Nakuru", "Eldoret"],
    "Ghana": ["Greater Accra", "Ashanti", "Northern", "Eastern", "Western", "Volta", "Central"],
    "South Africa": [
      "Gauteng", "Western Cape", "KwaZulu-Natal", "Eastern Cape", "Free State",
      "Limpopo", "Mpumalanga", "North West", "Northern Cape"
    ],
    "UAE": ["Dubai", "Abu Dhabi", "Sharjah", "Ajman", "Fujairah", "Ras Al Khaimah", "Umm Al Quwain"],
    "India": [
      "Delhi", "Maharashtra", "Karnataka", "Tamil Nadu", "Kerala", "Gujarat",
      "Punjab", "West Bengal"
    ]
  };

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    if (token != null) {
      _boostService = BoostService(token);
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _boostService.getMemberProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.name ?? '';
        _phoneController.text = profile.phone ?? '';
        _youtubeController.text = profile.youtubeUrl ?? '';
        _facebookController.text = profile.facebookUrl ?? '';
        _tiktokController.text = profile.tiktokUrl ?? '';
        _photoUrl = profile.profilePhotoUrl;

        // Parse existing region (format: "Country, State")
        final region = profile.region ?? '';
        if (region.contains(',')) {
          final parts = region.split(',');
          if (parts.length >= 2) {
            _selectedCountry = parts[0].trim();
            _selectedState = parts[1].trim();
          }
        }

        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file != null) {
      setState(() => _selectedImageFile = File(file.path));
    }
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
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError("Please enter your full name");
      return;
    }
    if (_selectedCountry == null || _selectedState == null) {
      _showError("Please select your country and state");
      return;
    }

    setState(() => _saving = true);

    // Combine country and state into region string
    final region = "$_selectedCountry, $_selectedState";

    final updated = MemberProfile(
      email: _profile!.email,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      region: region,
      profilePhotoUrl: _photoUrl,
      youtubeUrl: _youtubeController.text.trim(),
      facebookUrl: _facebookController.text.trim(),
      tiktokUrl: _tiktokController.text.trim(),
      membershipActive: _profile!.membershipActive,
      profileComplete: _profile!.profileComplete, // will be set to true on backend
      monthlyBoostsUsed: _profile!.monthlyBoostsUsed,
      maxMonthlyBoosts: _profile!.maxMonthlyBoosts,
      supportsGiven: _profile!.supportsGiven,
      supportsReceived: _profile!.supportsReceived,
    );

    final success = await _boostService.updateMemberProfile(
      updated,
      imageFile: _selectedImageFile,
    );

    if (mounted) {
      setState(() {
        _saving = false;
        if (success) {
          _selectedImageFile = null;
          _loadProfile(); // Refresh to get updated data (including profile_complete)
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final countries = countryStates.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Account Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo picker (unchanged)
            GestureDetector(
              onTap: _saving ? null : _showPhotoOptions,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _selectedImageFile != null
                    ? FileImage(_selectedImageFile!) as ImageProvider
                    : (_photoUrl != null && _photoUrl!.isNotEmpty
                        ? NetworkImage(_photoUrl!)
                        : null),
                child: (_photoUrl == null && _selectedImageFile == null)
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Full Name
            _buildField(_nameController, "Full Name"),
            const SizedBox(height: 16),

            // Phone Number
            _buildField(_phoneController, "Phone Number"),
            const SizedBox(height: 16),

            // Country Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: "Country",
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
              items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: _saving
                  ? null
                  : (v) {
                      setState(() {
                        _selectedCountry = v;
                        _selectedState = null; // reset state when country changes
                      });
                    },
            ),
            const SizedBox(height: 16),

            // State/Region Dropdown (dependent on selected country)
            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: const InputDecoration(
                labelText: "State / Region",
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              items: _selectedCountry == null
                  ? []
                  : countryStates[_selectedCountry]!
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: _saving ? null : (v) => setState(() => _selectedState = v),
            ),
            const SizedBox(height: 16),

            // Social links (unchanged)
            _buildField(_youtubeController, "YouTube Link"),
            const SizedBox(height: 16),
            _buildField(_facebookController, "Facebook Link"),
            const SizedBox(height: 16),
            _buildField(_tiktokController, "TikTok Link"),
            const SizedBox(height: 30),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const CircularProgressIndicator()
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