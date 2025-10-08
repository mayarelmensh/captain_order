import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/features/auth/login/logic/cubit/login_cubit.dart';
import 'package:food_2_go/features/captin/pages/table_in_order/logic/cubit/dine_in_order_cubit.dart';
import 'package:food_2_go/features/waiter/pages/home_screen/view/order_screen.dart';
import 'app_config.dart';
import 'controller/cache/shared_preferences_utils.dart';
import 'controller/dio/dio_helper.dart';
import 'core/utils/app_routes.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/captin/pages/confirm_order/view/confirm_order_screen.dart';
import 'features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_cubit.dart';
import 'features/captin/pages/dine_in_tables_screen/view/dine_in_tables_screen.dart';
import 'features/captin/pages/dine_in_tables_screen/view/get_table_order_screen.dart';
import 'features/captin/pages/dine_in_tables_screen/view/select_service.dart';
import 'features/captin/pages/splash_screen/splash_screen.dart';
import 'features/captin/pages/table_in_order/view/table_in_order.dart';
import 'features/waiter/pages/home_screen/logic/cubit/order_cubit.dart';
import 'features/auth/login/view/role_screen.dart';
Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferenceUtils.init();
  DioHelper.init();

  // ✅ اعمل instance واحد فقط
  final loginCubit = LoginCubit();
  await loginCubit.loadSavedData();

  String initialRoute;
  final token = await SharedPreferenceUtils.getData(key: 'token') as String?;

  if (token == null) {
    initialRoute = AppRoutes.splashRoute;
  } else {
    final role = loginCubit.currentUserRole.toLowerCase();
    print("✅ Role in mainCommon: $role");
    if (role == "captain_order") {
      initialRoute = AppRoutes.dineInTablesRoute;
    } else if (role == "waiter") {
      initialRoute = AppRoutes.waiterOrderScreen;
    } else {
      initialRoute = AppRoutes.roleScreen;
    }
  }

  runApp(MyApp(
    config: config,
    initialRoute: initialRoute,
    loginCubit: loginCubit, // ✅ ابعت الـ instance
  ));
}

class MyApp extends StatelessWidget {
  final AppConfig config;
  final String initialRoute;
  final LoginCubit loginCubit; // ✅ ضيف الـ parameter

  const MyApp({
    super.key,
    required this.config,
    required this.initialRoute,
    required this.loginCubit, // ✅ ضيف هنا
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: [
          // ✅ استخدم الـ BlocProvider.value بدل create
          BlocProvider.value(value: loginCubit),
          BlocProvider(create: (context) => OrderCubit()),
          BlocProvider(create: (context) => DineInTablesCubit()),
          BlocProvider(create: (context) => ProductListCubit()..getProductLists()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.backGround,
          ),
          debugShowCheckedModeBanner: false,
          title: config.appName,
          initialRoute: initialRoute,
          routes: {
            AppRoutes.splashRoute: (context) => const SplashScreen(),
            AppRoutes.loginRoute: (context) => const LoginScreen(),
            AppRoutes.dineInTablesRoute: (context) => DineInTablesScreen(),
            AppRoutes.tableInOrder: (context) => TableInOrder(),
            AppRoutes.confirmOrder: (context) => const ConfirmOrderScreen(),
            AppRoutes.selectService: (context) => const SelectServiceScreen(),
            AppRoutes.getTableOrder: (context) => const GetTableOrderScreen(),
            AppRoutes.waiterOrderScreen: (context) => OrderScreen(),
            AppRoutes.roleScreen: (context) => RoleScreen(
              loginResponse: context.read<LoginCubit>().loginResponse,
            ),
          },
        ),
      ),
    );
  }
}