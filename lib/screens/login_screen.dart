import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
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
    // Basic validation to save a network request
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

      // --- CRITICAL FIX: CHECK VERIFICATION FIRST ---
      if (result['needsVerification'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.otpVerification,
            arguments: result['email'] ?? _emailController.text.trim(),
          );
        }
        return; // Stop execution here
      }

      if (result['success']) {
        final member = result['member'];

        // Now handle post-verification onboarding steps
        if (!member.profileComplete) {
          Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
        } else if (!member.paymentComplete) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.payment,
            arguments: {
              'paymentUrl': null,
              'plan': null,
            },
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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