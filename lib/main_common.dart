import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_config.dart';
import 'controller/cache/shared_preferences_utils.dart';
import 'core/utils/app_routes.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/first_screen/on_boadrding/on_boarding_screen.dart';
import 'features/pages/splash_screen/splash_screen.dart';

Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferenceUtils.init();

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // مقاس التصميم من Figma مثلاً
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: config.appName,
        initialRoute: AppRoutes.splashRoute,
        routes: {
          AppRoutes.splashRoute: (context) => const SplashScreen(),
          AppRoutes.onBoardingRoute: (context) => const OnBoardingScreen(),
          AppRoutes.loginRoute: (context) => const LoginScreen(),
          // TODO: ضيفي باقي الروتس هنا زي AppRoutes.homeRoute
          // AppRoutes.homeRoute: (context) => const HomeScreen(),
        },
      ),
    );
  }
}