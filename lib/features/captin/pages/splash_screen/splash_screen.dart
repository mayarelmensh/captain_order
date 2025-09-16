import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../controller/cache/shared_preferences_utils.dart';
import '../../../../core/utils/app_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    bool? isFirstTime = SharedPreferenceUtils.getData(key: 'isFirstTime') as bool?;
    String? token = SharedPreferenceUtils.getData(key: 'token') as String?;

    if (isFirstTime == false && token != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
    } else if (isFirstTime == false) {
      Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onBoardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}