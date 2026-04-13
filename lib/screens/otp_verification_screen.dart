import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/routes.dart';
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

  Future<void> _verify() async {
    // 1. Basic validation
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified! Please login to continue.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 2. Clear stack and go to Login. 
          // This ensures the next login attempt fetches the brand new token.
          Navigator.pushNamedAndRemoveUntil(
            context, 
            AppRoutes.login, 
            (route) => false
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        // Prevent accidental back navigation if you want to force verification
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Verify Account',
              onPressed: _verify,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // You could add a 'Resend Code' logic here later
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}