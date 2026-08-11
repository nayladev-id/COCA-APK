// lib/screens/splash_screen.dart
// Menampilkan logo saat aplikasi baru dibuka.

import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';
import '../utils/auth_manager.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Tunggu splash screen tampil minimal 2 detik
    await Future.delayed(const Duration(milliseconds: 2000));
    
    final bool loggedIn = await AuthManager.isLoggedIn();
    
    if (!mounted) return;
    
    if (loggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigator()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee_maker, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Coffee Catalog',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
