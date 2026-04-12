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

  // UPDATED: Now supports Auto-Login after successful OTP verification
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Auto-login: Save the token and member data returned by the backend
        final member = Member.fromJson(data['member']);
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'memberId', value: member.id.toString());

        _user = member;
        notifyListeners();

        return {
          'success': true,
          'member': member,
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Verification failed'};
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
        // Registration successful - Backend sends OTP
        return {
          'success': true,
          'email': data['email'],
          'memberId': data['memberId'],
          'isVerified': false,
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
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
        // Handle unverified account
        return {
          'success': false,
          'error': data['error'] ?? 'Email not verified',
          'needsVerification': true,
          'email': email,
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