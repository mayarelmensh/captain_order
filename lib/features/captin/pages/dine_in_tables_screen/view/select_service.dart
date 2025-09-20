import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_cubit.dart';
import 'package:food_2_go/core/utils/flutter_toast.dart'; // افترض إن عندك مكتبة Toast
import 'package:google_fonts/google_fonts.dart';
import '../logic/cubit/dine_in_tables_states.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final tableNumber = args?['number'] ?? '';
    final area = args?['area'] ?? '';
    final tableId = args?['id'] ?? 0;

    return BlocProvider(
      create: (context) => DineInTablesCubit(),
      child: BlocListener<DineInTablesCubit, DineInTablesState>(
        listener: (context, state) {
          // if(state is DineInTablesCheckoutProcessing){
          //
          // }
          if (state is DineInTablesCheckoutSuccess) {
            ToastMessage.toastMessage(
              '${state.message} for Table $tableNumber',
              AppColors.green,
              AppColors.white,
            );
          } else if (state is DineInTablesError) {
            ToastMessage.toastMessage(
              "Check if the customer has paid the bill",
              AppColors.red,
              AppColors.white,
            );
          }
        },
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 100.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: CircleAvatar(
                          backgroundColor: AppColors.darkYellow,
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      Text(
                        "Choose The Service\n below",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 28.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Table: $tableNumber',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Area: $area',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subColor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.tableInOrder,
                        arguments: {
                          'number': tableNumber,
                          'area': area,
                          'id': tableId,
                        },
                      );
                    },
                    child: Image.asset('assets/images/take_order.png'),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "Or",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),
                 GestureDetector(
                   onTap: () {
                     Navigator.pushNamed(
                       context,
                       AppRoutes.getTableOrder,
                       arguments: {
                         'number': tableNumber,
                         'area': area,
                         'id': tableId,
                       },
                     );
                   },
                   child: Stack(
                     alignment: Alignment.center,
                     children: [
                       Image.asset("assets/images/card.png"),
                       Image.asset('assets/images/get_order.png')
                     ],
                   ),
                 ),
                  SizedBox(height: 24.h),
                  Text(
                    "Or",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  BlocBuilder<DineInTablesCubit, DineInTablesState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          final cubit = context.read<DineInTablesCubit>();
                          cubit.sendCheckoutRequest(tableId: tableId);
                        },
                        child: Image.asset('assets/images/request_payment.png'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}