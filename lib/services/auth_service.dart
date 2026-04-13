import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/member.dart';

class AuthService with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final client = http.Client();
  
  Member? _user;

  Member? get currentUser => _user;

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body)['error'];
        return {'success': false, 'error': error};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'email': data['email'] ?? email,
          'memberId': data['memberId'],
          'needsVerification': true, // Standardized key for UI flow
        };
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final member = Member.fromJson(data['member']);
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'memberId', value: member.id.toString());

        _user = member;
        notifyListeners();

        return {
          'success': true,
          'member': member,
        };
      } else if (response.statusCode == 403) {
        // --- MATCHES BACKEND 403 RESPONSE ---
        return {
          'success': false,
          'error': data['error'] ?? 'Email not verified',
          'needsVerification': true,
          'email': data['email'] ?? email,
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<int?> getMemberId() async {
    final id = await storage.read(key: 'memberId');
    return id != null ? int.parse(id) : null;
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'memberId');
    _user = null;
    notifyListeners();
  }
}