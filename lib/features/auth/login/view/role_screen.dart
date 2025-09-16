import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../captin/pages/confirm_order/view/confirm_order_screen.dart';
import '../../../captin/pages/dine_in_tables_screen/view/dine_in_tables_screen.dart';
import '../logic/model/login_model.dart';

class RoleScreen extends StatelessWidget {
  final LoginResponse? loginResponse;

  const RoleScreen({Key? key, this.loginResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnRole(context);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  void _navigateBasedOnRole(BuildContext context) {
    final role = loginResponse?.role?.toLowerCase()
        ?? loginResponse?.captainOrder?.role?.toLowerCase();

    print("✅ Final Role: $role");

    if (role == "captain_order") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DineInTablesScreen()),
      );
    } else if (role == "waiter") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConfirmOrderScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown role")),
      );
    }
  }
}
