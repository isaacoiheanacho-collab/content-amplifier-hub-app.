import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_verification_screen.dart';
// import 'screens/profile_setup_screen.dart';  // REMOVED - no longer used
import 'screens/payment_screen.dart';
import 'screens/home_screen.dart';
import 'screens/submit_boost_screen.dart';
import 'screens/my_boosts_screen.dart';
import 'screens/support_queue_screen.dart';
import 'screens/settings_screen.dart'; 
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/disclaimer_screen.dart';

// NEW SCREENS (existing)
import 'screens/account_information_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/settings_menu_screen.dart';
import 'screens/login_menu_screen.dart';

// NEW SUPPORT MEMBER SCREENS
import 'screens/support_home_screen.dart';
import 'screens/bank_info_screen.dart';

import 'services/auth_service.dart';
import 'services/boost_service.dart';

import 'utils/theme.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Content Amplifier Hub',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        // Using onGenerateRoute specifically for routes that need arguments
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.otpVerification) {
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(email: email),
            );
          }
          return null; // Let 'routes' handle everything else
        },
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          // AppRoutes.profileSetup: (context) => const ProfileSetupScreen(), // REMOVED
          AppRoutes.payment: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentScreen(
              paymentUrl: args['paymentUrl'] ?? '',
              amount: (args['amount'] ?? 0.0).toDouble(),
              currency: args['currency'] ?? 'USD',
            );
          },
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.submitBoost: (context) => const SubmitBoostScreen(),
          AppRoutes.myBoosts: (context) => const MyBoostsScreen(),
          AppRoutes.supportQueue: (context) => const SupportQueueScreen(),

          // Profile Menu
          AppRoutes.settings: (context) => const SettingsScreen(),

          // Legal
          AppRoutes.terms: (context) => const TermsScreen(),
          AppRoutes.privacy: (context) => const PrivacyScreen(),
          AppRoutes.disclaimer: (context) => const DisclaimerScreen(),

          // Existing new screens
          AppRoutes.accountInfo: (context) => const AccountInformationScreen(),
          AppRoutes.billing: (context) => const BillingScreen(),
          AppRoutes.settingsMenu: (context) => const SettingsMenuScreen(),
          AppRoutes.loginMenu: (context) => const LoginMenuScreen(),

          // Support member screens
          AppRoutes.supportHome: (context) => const SupportHomeScreen(),
          AppRoutes.bankInfo: (context) => const BankInfoScreen(),
        },
      ),
    );
  }
}