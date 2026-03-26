import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Content Amplifier Hub',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Creators helping creators grow together.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SectionCard(
                title: 'About CAH',
                child: Text(
                  'A cooperative community where creators support each other’s content. '
                  'Members engage with posts on social platforms, and everyone gets a fair boost.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'How it works',
                child: Column(
                  children: [
                    _howItWorksItem(1, 'Become a member'),
                    _howItWorksItem(2, 'Support others’ posts'),
                    _howItWorksItem(3, 'Submit your own links to be boosted'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Create an account',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: const Text('Log in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _howItWorksItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}