import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/payment_screen.dart';
import 'services/auth_service.dart';

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
        // Use Provider (not ChangeNotifierProvider) because AuthService is not a ChangeNotifier
        Provider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Content Amplifier Hub',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/payment': (context) => PaymentScreen(
                paymentUrl: ModalRoute.of(context)!.settings.arguments as String,
              ),
        },
      ),
    );
  }
}