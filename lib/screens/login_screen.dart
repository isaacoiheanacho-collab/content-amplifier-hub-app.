import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final result = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // --- HANDLE UNVERIFIED EMAIL ---
      if (result['needsVerification'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.otpVerification,
            arguments: result['email'] ?? _emailController.text.trim(),
          );
        }
        return;
      }

      if (result['success']) {
        final member = result['member'];

        // NEW FLOW: Payment first if membership not active, else Home
        if (!member.membershipActive) {
          await _navigateToPayment();
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToPayment() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    if (token == null) {
      _showError('Session expired. Please log in again.');
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    try {
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
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.payment,
            arguments: {
              'paymentUrl': data['paymentUrl'],
              'amount': (data['amountToPay'] ?? 50).toDouble(),
              'currency': data['currency'] ?? 'USD',
            },
          );
        }
      } else {
        throw Exception('Failed to get payment URL');
      }
    } catch (e) {
      if (mounted) {
        _showError('Payment error: $e');
        // Fallback: go to home anyway (user can try later)
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextInputField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextInputField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Login',
              onPressed: _login,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}