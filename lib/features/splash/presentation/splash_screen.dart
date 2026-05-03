import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeFromAuthState();
  }

  Future<void> _routeFromAuthState() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.login : AppRoutes.dashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppImages.splash, height: 180, fit: BoxFit.contain),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
