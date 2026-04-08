import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/primary_button.dart';
import '../utils/theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;

  File? _profileImage;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  // -------------------------
  // COUNTRY → STATE MAP
  // -------------------------
  final Map<String, List<String>> countryStates = {
    "United States": [
      "Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut",
      "Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa",
      "Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan",
      "Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
      "New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio",
      "Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota",
      "Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia",
      "Wisconsin","Wyoming"
    ],
    "United Kingdom": ["England", "Scotland", "Wales", "Northern Ireland"],
    "Canada": ["Ontario","Quebec","British Columbia","Alberta","Manitoba","Saskatchewan","Nova Scotia","New Brunswick","Newfoundland & Labrador","Prince Edward Island"],
    "Australia": ["New South Wales","Victoria","Queensland","Western Australia","South Australia","Tasmania","Northern Territory","Australian Capital Territory"],
    "Nigeria": [
      "Lagos","Abuja","Rivers","Enugu","Kano","Kaduna","Oyo","Ogun","Delta","Edo",
      "Anambra","Imo","Abia","Akwa Ibom","Cross River","Benue","Kogi","Kwara","Plateau",
      "Nasarawa","Borno","Yobe","Sokoto","Zamfara","Kebbi","Taraba","Gombe","Bauchi",
      "Jigawa","Ondo","Ekiti","Bayelsa"
    ],
    "Kenya": ["Nairobi","Mombasa","Kisumu","Nakuru","Eldoret"],
    "Ghana": ["Greater Accra","Ashanti","Northern","Eastern","Western","Volta","Central"],
    "South Africa": ["Gauteng","Western Cape","KwaZulu-Natal","Eastern Cape","Free State","Limpopo","Mpumalanga","North West","Northern Cape"],
    "Uganda": ["Central","Western","Eastern","Northern"],
    "Ireland": ["Leinster","Munster","Connacht","Ulster"],
    "New Zealand": ["Auckland","Wellington","Canterbury","Otago"],
    "Singapore": ["Singapore"],
    "UAE": ["Dubai","Abu Dhabi","Sharjah","Ajman","Fujairah","Ras Al Khaimah","Umm Al Quwain"],
    "India": ["Delhi","Maharashtra","Karnataka","Tamil Nadu","Kerala","Gujarat","Punjab","West Bengal"]
  };

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setState(() => _profileImage = File(file.path));
    }
  }

  Future<String?> _uploadPhoto(String token) async {
    if (_profileImage == null) return null;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/member/profile/upload-photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('photo', _profileImage!.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body)['url'];
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (_selectedCountry == null || _selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your country and state")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please log in again.")),
        );
        return;
      }

      // Upload photo
      final photoUrl = await _uploadPhoto(token);

      // Save profile
      final region = "${_selectedCountry!}, ${_selectedState!}";

      final res = await http.post(
        Uri.parse('$baseUrl/member/profile/update'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "region": region,
          "profile_photo_url": photoUrl,
          "phone": "",
          "youtube_url": "",
          "facebook_url": "",
          "tiktok_url": ""
        }),
      );

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save profile")),
        );
        return;
      }

      // Request payment URL
      final payRes = await http.post(
        Uri.parse('$baseUrl/member/payment-url'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final payData = jsonDecode(payRes.body);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.payment,
        arguments: {
          "paymentUrl": payData["paymentUrl"],
          "amount": payData["amountToPay"] ?? 50,
          "currency": payData["currency"] ?? "USD",
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countries = countryStates.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Complete your profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: AppColors.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCountry = v;
                  _selectedState = null;
                });
              },
              decoration: const InputDecoration(
                labelText: "Country",
                prefixIcon: Icon(Icons.public),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedState,
              items: _selectedCountry == null
                  ? []
                  : countryStates[_selectedCountry]!
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (v) => setState(() => _selectedState = v),
              decoration: const InputDecoration(
                labelText: "State / Region",
                prefixIcon: Icon(Icons.location_city),
              ),
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: "Continue to membership",
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
