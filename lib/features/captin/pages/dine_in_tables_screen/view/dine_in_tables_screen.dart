import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/cubit/dine_in_tables_cubit.dart';
import '../logic/cubit/dine_in_tables_states.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class DineInTablesScreen extends StatefulWidget {
  const DineInTablesScreen({Key? key}) : super(key: key);

  @override
  _DineInTablesScreenState createState() => _DineInTablesScreenState();
}

class _DineInTablesScreenState extends State<DineInTablesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DineInTablesCubit(),
      child: _DineInTablesScreenContent(),
    );
  }
}

class _DineInTablesScreenContent extends StatelessWidget {
  _DineInTablesScreenContent();

  // API statuses → UI statuses
  final Map<String, String> apiToUiStatus = {
    'available': 'available',
    'not_available_pre_order': 'waiting',
    'not_available_with_order': 'dining',
    'not_available_but_checkout': 'paid',
    'reserved': 'reserved',
  };

  final Map<String, Color> statusColors = {
    'available': AppColors.white,
    'paid': AppColors.lightGreen,
    'dining': AppColors.babyPink,
    'waiting': AppColors.blue,
    'reserved': AppColors.pink,
    'default': AppColors.borderColor,
  };

  final Map<String, Color> statusTextColors = {
    'available': AppColors.darkGrey,
    'paid': AppColors.darkGrey,
    'dining': AppColors.darkGrey,
    'waiting': AppColors.white,
    'reserved': AppColors.white,
    'default': AppColors.black,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 45.h),
        child: BlocBuilder<DineInTablesCubit, DineInTablesState>(
          builder: (context, state) {
            if (state is DineInTablesLoading) {
              return  Center(child: CircularProgressIndicator(
                color: AppColors.primary,
              ));
            } else if (state is DineInTablesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DineInTablesCubit>().refresh();
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is DineInTablesLoaded) {
              final tabs = context.read<DineInTablesCubit>().getTabs();
              final filteredTables =
              context.read<DineInTablesCubit>().getFilteredTables();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dine-in Tables',
                    style: GoogleFonts.poppins(
                      color: AppColors.black,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Select an available table to start an order',
                    style: GoogleFonts.poppins(
                      color: AppColors.subColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final isSelected =
                            state.selectedLocationIndex == index;
                        return GestureDetector(
                          onTap: () {
                            context
                                .read<DineInTablesCubit>()
                                .selectLocation(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 10.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Center(
                              child: Text(
                                tabs[index],
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.subColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 12.h,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.w,
                        mainAxisSpacing: 1.2.h,
                        childAspectRatio: 1.h,
                      ),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) {
                        final table = filteredTables[index];
                        final uiStatus =
                            apiToUiStatus[table.currentStatus] ?? 'default';

                        final statusColor =
                            statusColors[uiStatus] ?? statusColors['default']!;
                        final textColor =
                            statusTextColors[uiStatus] ??
                                statusTextColors['default']!;

                        return GestureDetector(
                          onTap: () {
                            final cubit = context.read<DineInTablesCubit>();

                            final area = cubit.getLocationById(table.locationId);

                            final tableData = {
                              "id": table.id,
                              "number": table.tableNumber,
                              "area": area?.name ?? "Unknown Area",
                            };

                            if (uiStatus == 'dining' ||
                                uiStatus == 'reserved' ||
                                uiStatus == 'paid') {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.selectService,
                                arguments: tableData,
                              );
                            } else {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.tableInOrder,
                                arguments: tableData,
                              );
                            }
                          },

                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            color: statusColor,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                color: AppColors.white.withOpacity(0.7),
                              ),
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                        child: Text(
                                          table.tableNumber,
                                          style: GoogleFonts.poppins(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3.h, horizontal: 8.w),
                                            decoration: BoxDecoration(
                                              color:
                                              AppColors.white.withOpacity(0.5),
                                              borderRadius:
                                              BorderRadius.circular(30.r),
                                            ),
                                            child: Text(
                                              uiStatus.capitalize(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Image.asset('assets/images/seats.png'),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${table.capacity} seats',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: AppColors.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Image.asset("assets/images/table_icon.png"),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'table ${table.id}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: AppColors.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
