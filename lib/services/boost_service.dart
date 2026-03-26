import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/boost.dart';

class BoostService {
  final String token;

  BoostService(this.token);

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

  Future<Map<String, dynamic>> getMemberStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/stats'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load member stats');
    }
  }

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
}

class BoostSubmissionResult {
  final bool success;
  final String? slot;
  final String? message;

  BoostSubmissionResult({required this.success, this.slot, this.message});
}