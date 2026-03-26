import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/home_screen.dart';
import 'screens/submit_boost_screen.dart';
import 'screens/my_boosts_screen.dart';
import 'screens/support_queue_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
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
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
          AppRoutes.payment: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentScreen(
              paymentUrl: args['paymentUrl'],
              plan: args['plan'],
            );
          },
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.submitBoost: (context) => const SubmitBoostScreen(),
          AppRoutes.myBoosts: (context) => const MyBoostsScreen(),
          AppRoutes.supportQueue: (context) => const SupportQueueScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}