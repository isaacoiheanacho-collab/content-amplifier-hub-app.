import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'member': data['member'],
        'paymentUrl': data['paymentUrl'],
      };
    } else {
      final error = jsonDecode(response.body)['error'];
      return {'success': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return {'success': true, 'member': data['member']};
    } else {
      final error = jsonDecode(response.body)['error'];
      return {'success': false, 'error': error};
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}