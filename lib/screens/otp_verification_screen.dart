import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/routes.dart';
import '../utils/constants.dart'; // contains baseUrl
import '../models/member.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _selectedMemberType; // 'creator' or 'support'

  Future<void> _verify() async {
    if (_otpController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final result = await auth.verifyOtp(widget.email, _otpController.text.trim());

      if (result['success']) {
        final Member member = result['member'];
        final selectedType = _selectedMemberType ?? 'creator';
        await auth.setMemberType(selectedType);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          if (selectedType == 'support') {
            // Support member: go directly to Support Home (no payment)
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.supportHome,
              (route) => false,
            );
          } else {
            // Creator flow: payment if not active, else home
            if (!member.membershipActive) {
              await _navigateToPayment();
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Invalid or expired code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
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
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
        // Optionally go back to login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
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
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Verify your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextInputField(
              controller: _otpController,
              label: '6-Digit Code',
              icon: Icons.lock_clock,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            const Text('Select account type:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Creator'),
                    value: 'creator',
                    groupValue: _selectedMemberType,
                    onChanged: (val) => setState(() => _selectedMemberType = val),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Support (Free)'),
                    value: 'support',
                    groupValue: _selectedMemberType,
                    onChanged: (val) => setState(() => _selectedMemberType = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Verify Account',
              onPressed: _verify,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}