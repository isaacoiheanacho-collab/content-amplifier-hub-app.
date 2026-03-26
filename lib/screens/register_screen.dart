import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/routes.dart';
import '../utils/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/checkbox_tile.dart';
import '../models/plan.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();
  bool _agreeTerms = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms to continue.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final result = await auth.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (result['success']) {
        final amount = result['amountToPay'];
        final plan = Plan(name: 'Yearly Membership', price: amount, description: '');
        // Navigate to profile setup (or directly to payment if you prefer)
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.payment,
          arguments: {
            'paymentUrl': result['paymentUrl'],
            'plan': plan,
          },
        );
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
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextInputField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              TextInputField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextInputField(
                controller: _referralController,
                label: 'Referral code (optional)',
                icon: Icons.people,
              ),
              const SizedBox(height: 24),
              CheckboxTile(
                value: _agreeTerms,
                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                text:
                    'I have read and accept the Terms & Conditions and Privacy Policy.',
                textStyle: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Create account',
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}