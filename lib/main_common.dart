import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/features/pages/table_in_order/view/table_in_order.dart';
import 'app_config.dart';
import 'controller/cache/shared_preferences_utils.dart';
import 'controller/dio/dio_helper.dart';
import 'core/utils/app_routes.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/first_screen/on_boadrding/on_boarding_screen.dart';
import 'features/pages/dine_in_tables_screen/view/dine_in_tables_screen.dart';
import 'features/pages/splash_screen/splash_screen.dart';

Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferenceUtils.init();
  DioHelper.init();
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
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backGround
        ),
        // color: AppColors.backGround,
        debugShowCheckedModeBanner: false,
        title: config.appName,
        initialRoute: AppRoutes.splashRoute,
        routes: {
          AppRoutes.splashRoute: (context) => const SplashScreen(),
          AppRoutes.onBoardingRoute: (context) => const OnBoardingScreen(),
          AppRoutes.loginRoute: (context) => const LoginScreen(),
          AppRoutes.dineInTablesRoute: (context) =>  DineInTablesScreen(),
          AppRoutes.tableInOrder: (context) =>  TableInOrder(),
          // AppRoutes.homeRoute: (context) => const HomeScreen(),
        },
      ),
    );
  }
}