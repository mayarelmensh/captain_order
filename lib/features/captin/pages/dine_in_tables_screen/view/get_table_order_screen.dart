import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/cubit/dine_in_tables_states.dart';

class GetTableOrderScreen extends StatefulWidget {
  const GetTableOrderScreen({super.key});

  @override
  State<GetTableOrderScreen> createState() => _GetTableOrderScreenState();
}

class _GetTableOrderScreenState extends State<GetTableOrderScreen> {
  String? tableNumber;
  String? area;
  int? tableId;
  String? selectedStatus; // متغير لحفظ الخيار المؤقت
  bool _loaded = false; // لمنع إعادة التحميل

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    tableNumber = args?['number'] ?? '';
    area = args?['area'] ?? '';
    tableId = args?['id'] ?? 0;

    if (tableId != null && mounted && !_loaded) {
      final cubit = context.read<DineInTablesCubit>();
      cubit.getTableOrder(tableId: tableId!);
      _loaded = true;
    }
  }

  void _updateStatus(int cartId, String status) {
    if (tableId != null && cartId != null) {
      final cubit = context.read<DineInTablesCubit>();
      cubit.updateOrderStatus(
        tableId: tableId!,
        cartId: cartId,
        status: status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textAlign: TextAlign.center,
          'Table $tableNumber Orders',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[200]!, Colors.white],
          ),
        ),
        child: BlocBuilder<DineInTablesCubit, DineInTablesState>(
          builder: (context, state) {
            print("Current State: $state");
            if (state is GetTableOrderLoading) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is GetTableOrderError) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state is GetTableOrderSuccess) {
              final tableOrder = state.tableOrderModel;
              if (tableOrder.orders.isEmpty) {
                return Center(child: Text('No orders available'));
              }
              return ListView.builder(
                padding: EdgeInsets.all(12.w),
                itemCount: tableOrder.orders.length,
                itemBuilder: (context, index) {
                  final order = tableOrder.orders[index];
                  return Card(
                    color: AppColors.borderColor,
                    elevation: 0.2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                order.imageLink ?? '',
                                width: 70.w,
                                height: 70.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.fastfood, size: 40.w, color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Preparation: ${order.prepration}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'Count: ${order.count}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  if (order.price != null)
                                    Text(
                                      'Price: ${order.price}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  if (order.taxId != null)
                                    Text(
                                      'Tax ID: ${order.taxId}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120.w,
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primary, width: 0.5),
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus ?? order.prepration,
                                      hint: Text(
                                        'Select Status',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      items: ['preparing', 'done', 'pick_up', ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedStatus = newValue;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: selectedStatus != null && order.cartId != null
                                      ? () {
                                    _updateStatus(order.cartId!, selectedStatus!);
                                    setState(() {
                                      selectedStatus = null; // إعادة تعيين بعد التأكيد
                                    });
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text(
                'Loading initial data...',
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey[700]),
              ),
            );
          },
        ),
      ),
    );
  }
}