import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/features/auth/login/logic/cubit/login_cubit.dart';
import 'package:food_2_go/features/captin/pages/table_in_order/logic/cubit/dine_in_order_cubit.dart';
import 'app_config.dart';
import 'controller/cache/shared_preferences_utils.dart';
import 'controller/dio/dio_helper.dart';
import 'core/utils/app_routes.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/captin/pages/confirm_order/view/confirm_order_screen.dart';
import 'features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_cubit.dart';
import 'features/captin/pages/dine_in_tables_screen/view/dine_in_tables_screen.dart';
import 'features/captin/pages/dine_in_tables_screen/view/select_service.dart';
import 'features/captin/pages/splash_screen/splash_screen.dart';
import 'features/captin/pages/table_in_order/view/table_in_order.dart';
import 'features/waiter/pages/home_screen/logic/cubit/order_cubit.dart';

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
      child: MultiBlocProvider(
        providers: [
         BlocProvider(create:(context) => DineInTablesCubit()..loadCafeData(),),
         BlocProvider(create:(context) => LoginCubit()),
         BlocProvider(create:(context) => OrderCubit()),
         BlocProvider(create:(context) => LoginCubit()),
         BlocProvider(create:(context) => ProductListCubit()..getProductLists()),
         BlocProvider( create: (context) => OrderCubit(),)

        ],
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
            // AppRoutes.onBoardingRoute: (context) => const OnBoardingScreen(),
            AppRoutes.loginRoute: (context) => const LoginScreen(),
            AppRoutes.dineInTablesRoute: (context) =>  DineInTablesScreen(),
            AppRoutes.tableInOrder: (context) =>  TableInOrder(),
            AppRoutes.confirmOrder: (context) =>  ConfirmOrderScreen(),
            AppRoutes.selectService: (context) =>  SelectServiceScreen(),
          },
        ),
      )
    );
  }
}
