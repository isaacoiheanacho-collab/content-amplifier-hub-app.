import 'package:flutter/material.dart';
import 'submit_boost_screen.dart';
import 'support_queue_screen.dart';
import 'my_boosts_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SupportQueueScreen(),
    const SubmitBoostScreen(),
    const MyBoostsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Boost'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'My Boosts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}