import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../models/boost.dart';
import '../models/member_stats.dart';
import '../models/member_profile.dart';

class BoostService {
  final String token;

  BoostService(this.token);

  // ------------------------------------------------------------
  // SUBMIT BOOST
  // ------------------------------------------------------------
  Future<BoostSubmissionResult> submitBoost({
    required int memberId,
    required String contentUrl,
    required String platform,
    required String category,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boosts/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'memberId': memberId,
        'contentUrl': contentUrl,
        'platform': platform,
        'category': category,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BoostSubmissionResult(success: true, slot: data['slot']);
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body)['error'];
      return BoostSubmissionResult(success: false, message: error);
    } else {
      return BoostSubmissionResult(success: false, message: 'Unknown error');
    }
  }

  // ------------------------------------------------------------
  // LIVE BOOSTS
  // ------------------------------------------------------------
  Future<List<Boost>> getLiveBoosts({int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/boosts/live?limit=$limit'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Boost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load live boosts');
    }
  }

  // ------------------------------------------------------------
  // SUPPORT ACTIONS
  // ------------------------------------------------------------
  Future<void> recordSupportClick(int boostId) async {
    await http.post(
      Uri.parse('$baseUrl/boosts/$boostId/support'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> recordConfirmedSupport(int boostId) async {
    await http.post(
      Uri.parse('$baseUrl/boosts/$boostId/confirm'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ------------------------------------------------------------
  // MEMBER STATS
  // ------------------------------------------------------------
  Future<MemberStats> getMemberStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/stats'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MemberStats.fromJson(data);
    } else {
      throw Exception('Failed to load member stats');
    }
  }

  // ------------------------------------------------------------
  // MY BOOSTS
  // ------------------------------------------------------------
  Future<List<Boost>> getMyBoosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/boosts'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Boost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my boosts');
    }
  }

  // ------------------------------------------------------------
  // GET MEMBER PROFILE
  // ------------------------------------------------------------
  Future<MemberProfile> getMemberProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/profile'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MemberProfile.fromJson(data);
    } else {
      throw Exception('Failed to load member profile');
    }
  }

  // ------------------------------------------------------------
  // UPDATE MEMBER PROFILE (MODIFIED FOR MULTIPART)
  // ------------------------------------------------------------
  Future<bool> updateMemberProfile(MemberProfile profile, {File? imageFile}) async {
    try {
      final uri = Uri.parse('$baseUrl/member/profile/update');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = profile.name ?? '';
      request.fields['phone'] = profile.phone ?? '';
      request.fields['region'] = profile.region ?? '';
      request.fields['youtube_url'] = profile.youtubeUrl ?? '';
      request.fields['facebook_url'] = profile.facebookUrl ?? '';
      request.fields['tiktok_url'] = profile.tiktokUrl ?? '';
      request.fields['profile_photo_url'] = profile.profilePhotoUrl ?? '';

      // Add image if available
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', imageFile.path),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print("Update Profile Error: $e");
      return false;
    }
  }

  // ------------------------------------------------------------
  // UPLOAD PROFILE PHOTO (KEEPING STANDALONE FOR BACKUP)
  // ------------------------------------------------------------
  Future<String> uploadProfilePhoto(File file) async {
    final uri = Uri.parse('$baseUrl/member/profile/upload-photo');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath('photo', file.path),
      );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to upload profile photo');
    }
  }
}

class BoostSubmissionResult {
  final bool success;
  final String? slot;
  final String? message;

  BoostSubmissionResult({required this.success, this.slot, this.message});
}