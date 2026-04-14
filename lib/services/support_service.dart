import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../models/boost.dart';

class SupportService {
  final String token;

  SupportService(this.token);

  Future<List<Boost>> getAvailableBoosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/available-boosts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['boosts'] as List).map((j) => Boost.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load boosts');
    }
  }

  Future<void> recordClick(int boostId) async {
    await http.post(
      Uri.parse('$baseUrl/support/record-click'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'boostId': boostId}),
    );
  }

  Future<Map<String, dynamic>> confirmEngagement(int boostId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/confirm-engagement'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'boostId': boostId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Confirmation failed');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Future<bool> updateBankInfo(String info) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/bank-info'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'bankAccountInfo': info}),
    );
    return response.statusCode == 200;
  }

  Future<bool> claimReward() async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/claim-reward'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<void> openBoostLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}