import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_config.dart';
import 'controller/cache/shared_preferences_utils.dart';
import 'core/utils/app_routes.dart';
import 'features/auth/login/view/login_screen.dart';

Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferenceUtils.init();

  var token = SharedPreferenceUtils.getData(key: 'token');
  String routeName = token == null ? AppRoutes.loginRoute : AppRoutes.homeRoute;

  runApp(MyApp(config: config, routeName: routeName));
}

class MyApp extends StatelessWidget {
  final AppConfig config;
  final String routeName;

  const MyApp({
    super.key,
    required this.config,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // مقاس التصميم من Figma مثلاً
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: routeName,
        routes: {
          AppRoutes.loginRoute: (context) => const LoginScreen(),
          // TODO: ضيفي باقي الروتس هنا زي AppRoutes.homeRoute
        },
        title: config.appName,
        home: Scaffold(
          appBar: AppBar(title: Text(config.appName)),
          body: Center(
            child: Text("Flavor: ${config.flavor}\nAPI: ${config.baseUrl}"),
          ),
        ),
      ),
    );
  }
}
