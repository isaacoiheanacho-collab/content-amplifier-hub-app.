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

  // NEW: Verify OTP Method
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
        // Registration successful - Backend sends 201 and message: 'OTP sent to email'
        return {
          'success': true,
          'email': data['email'],
          'memberId': data['memberId'],
          'isVerified': false, // Explicitly tell UI to go to OTP screen
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
        // Handle the "Email not verified" case
        return {
          'success': false,
          'error': data['error'],
          'needsVerification': true,
          'email': email, // Pass email back so UI can auto-fill OTP screen
        };
      } else {
        return {'success': false, 'error': data['error']};
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