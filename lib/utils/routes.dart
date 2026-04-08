import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_menu_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/home_screen.dart';
import '../screens/submit_boost_screen.dart';
import '../screens/my_boosts_screen.dart';
import '../screens/support_queue_screen.dart';
import '../screens/settings_menu_screen.dart';
import '../screens/account_information_screen.dart';
import '../screens/billing_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/disclaimer_screen.dart';

import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginMenuScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.submitBoost:
        return MaterialPageRoute(builder: (_) => const SubmitBoostScreen());

      case AppRoutes.myBoosts:
        return MaterialPageRoute(builder: (_) => const MyBoostsScreen());

      case AppRoutes.supportQueue:
        return MaterialPageRoute(builder: (_) => const SupportQueueScreen());

      case AppRoutes.settingsMenu:
        return MaterialPageRoute(builder: (_) => const SettingsMenuScreen());

      case AppRoutes.accountInfo:
        return MaterialPageRoute(builder: (_) => const AccountInformationScreen());

      case AppRoutes.billing:
        return MaterialPageRoute(builder: (_) => const BillingScreen());

      case AppRoutes.terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      case AppRoutes.disclaimer:
        return MaterialPageRoute(builder: (_) => const DisclaimerScreen());

      // ⭐ FINAL UPDATED PAYMENT ROUTE (USD + correct arguments)
      case AppRoutes.payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            paymentUrl: args["paymentUrl"],
            amount: (args["amount"] as num).toDouble(),
            currency: args["currency"],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Unknown route")),
          ),
        );
    }
  }
}
