import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/features/waiter/pages/home_screen/view/order_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../captin/pages/dine_in_tables_screen/view/dine_in_tables_screen.dart';
import '../logic/cubit/login_cubit.dart';
import '../logic/model/login_model.dart';

class RoleScreen extends StatelessWidget {
  final LoginResponse? loginResponse;

  const RoleScreen({Key? key, this.loginResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        navigateBasedOnRole(context);
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void navigateBasedOnRole(BuildContext context) {
    try {
      print("📋 LoginResponse: $loginResponse");

      if (loginResponse == null) {
        print("❌ loginResponse is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No login data available")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
        return;
      }

      final role = loginResponse?.role?.toLowerCase() ??
          loginResponse?.captainOrder?.role?.toLowerCase();

      print("✅ Final Role: $role");

      if (role == "captain_order") {
        print("➡️ Navigating to DineInTablesScreen for Captain Order");

        // Try to get LoginCubit
        try {
          final loginCubit = context.read<LoginCubit>();
          print("✅ LoginCubit found successfully");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: loginCubit,
                child: const DineInTablesScreen(),
              ),
            ),
          );
        } catch (e) {
          print("❌ Error getting LoginCubit: $e");
          // If can't get LoginCubit, navigate without it
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DineInTablesScreen()),
          );
        }

      } else if (role == "waiter") {
        print("➡️ Navigating to OrderScreen for Waiter");

        try {
          final loginCubit = context.read<LoginCubit>();
          print("✅ LoginCubit found successfully");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: loginCubit,
                child: OrderScreen(),
              ),
            ),
          );
        } catch (e) {
          print("❌ Error getting LoginCubit: $e");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderScreen()),
          );
        }

      } else {
        print("❌ Unknown or null role: $role");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unknown role or invalid login data")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
      }
    } catch (e, stackTrace) {
      print("❌❌❌ CRITICAL ERROR in navigateBasedOnRole: $e");
      print("Stack trace: $stackTrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigation Error: $e")),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
    }
  }
}