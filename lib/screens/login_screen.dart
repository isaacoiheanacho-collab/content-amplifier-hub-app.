import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
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
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final result = await auth.login(_emailController.text, _passwordController.text);
      if (result['success']) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
              validator: (value) => value == null || value.isEmpty ? 'Email required' : null,
            ),
            const SizedBox(height: 16),
            TextInputField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? 'Password required' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Login',
              onPressed: _login,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('Don\'t have an account? Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}