import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_routes.dart';
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

class _DineInTablesScreenState extends State<DineInTablesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DineInTablesCubit(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _DineInTablesScreenContent(),
      ),
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

  // UI statuses → API statuses (reverse mapping)
  final Map<String, String> uiToApiStatus = {
    'available': 'available',
    'waiting': 'not_available_pre_order',
    'dining': 'not_available_with_order',
    'paid': 'not_available_but_checkout',
    'reserved': 'reserved',
  };

  final Map<String, Color> statusColors = {
    'available': AppColors.white,
    'paid': AppColors.green,
    'dining': AppColors.babyPink,
    'waiting': AppColors.blue,
    'reserved': AppColors.pink,
    'default': AppColors.borderColor,
  };

  final Map<String, Color> statusCardColors = {
    'available': const Color(0xFFF1F8E9),
    'paid': const Color(0xFFF9FBE7),
    'dining': const Color(0xFFFFF3E0),
    'waiting': const Color(0xFFE3F2FD),
    'reserved': const Color(0xFFF3E5F5),
    'default': const Color(0xFFFAFAFA),
  };

  final Map<String, IconData> statusIcons = {
    'available': Icons.check_circle,
    'paid': Icons.payment,
    'dining': Icons.restaurant,
    'waiting': Icons.access_time,
    'reserved': Icons.bookmark,
    'default': Icons.help_outline,
  };

  final Map<String, String> statusLabelsEnglish = {
    'available': 'Available',
    'waiting': 'Waiting',
    'dining': 'Dining',
    'paid': 'Paid',
    'reserved': 'Reserved',
  };

  void _showStatusChangeDialog(BuildContext parentContext, int tableId, String currentStatus) {
    final cubit = parentContext.read<DineInTablesCubit>();
    String selectedStatus = apiToUiStatus[currentStatus] ?? 'available';

    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note,
                        size: 32.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Change Table Status',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Select new status for the table:',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.subColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ...statusLabelsEnglish.entries.map((entry) {
                      final statusKey = entry.key;
                      final statusLabel = entry.value;
                      final isSelected = selectedStatus == statusKey;

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () {
                              setState(() {
                                selectedStatus = statusKey;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? statusColors[statusKey]?.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? statusColors[statusKey] ?? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: statusColors[statusKey] ?? AppColors.borderColor,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      statusIcons[statusKey] ?? Icons.help_outline,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      statusLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? AppColors.black : AppColors.subColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: EdgeInsets.all(4.r),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              await _handleStatusUpdate(parentContext, cubit, tableId, selectedStatus);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleStatusUpdate(
      BuildContext context,
      DineInTablesCubit cubit,
      int tableId,
      String selectedStatus,
      ) async {


    try {
      final apiStatus = uiToApiStatus[selectedStatus] ?? 'available';
      print("🔄 Attempting to update table $tableId to status: $apiStatus");

      final success = await cubit.changeTableStatus(
        tableId: tableId,
        newStatus: apiStatus,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  success
                      ? 'Table status updated successfully'
                      : 'Failed to update table status',
                  style: GoogleFonts.poppins(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

      if (success) {
        print("✅ Table status updated successfully");
      } else {
        print("❌ Failed to update table status");
      }
    } catch (e) {
      print("⚠️ Exception during status update: $e");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Error updating table status',
                  style: GoogleFonts.poppins(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: BlocBuilder<DineInTablesCubit, DineInTablesState>(
            builder: (context, state) {
              if (state is DineInTablesLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              spreadRadius: 10,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Loading Tables...',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subColor,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is DineInTablesError) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error Loading Tables',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          style: GoogleFonts.poppins(
                            color: AppColors.subColor,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DineInTablesCubit>().refresh();
                          },
                          icon: Icon(Icons.refresh, size: 18.sp),
                          label: Text(
                            'Try Again',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is DineInTablesLoaded) {
                final tabs = context.read<DineInTablesCubit>().getTabs();
                final filteredTables = context.read<DineInTablesCubit>().getFilteredTables();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 24.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dine-in Tables',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.black,
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'Select an available table to start an order',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.subColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Location Tabs
                    Container(
                      height: 50.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          final isSelected = state.selectedLocationIndex == index;
                          return GestureDetector(
                            onTap: () {
                              context.read<DineInTablesCubit>().selectLocation(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(right: 12.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(25.r),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  tabs[index],
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : AppColors.subColor,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Tables Grid
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.only(bottom: 20.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18.w,
                          mainAxisSpacing: 18.h,
                          childAspectRatio: 0.95, // Increased to fix overflow
                        ),
                        itemCount: filteredTables.length,
                        itemBuilder: (context, index) {
                          final table = filteredTables[index];
                          final uiStatus = apiToUiStatus[table.currentStatus] ?? 'default';
                          final statusColor = statusColors[uiStatus] ?? statusColors['default']!;
                          final cardColor = statusCardColors[uiStatus] ?? statusCardColors['default']!;

                          return GestureDetector(
                            onTap: () {
                              final cubit = context.read<DineInTablesCubit>();
                              final area = cubit.getLocationById(table.locationId);

                              final tableData = {
                                "id": table.id,
                                "number": table.tableNumber,
                                "area": area?.name ?? "Unknown Area",
                              };

                              if (uiStatus == 'dining' || uiStatus == 'reserved' || uiStatus == 'paid') {
                                Navigator.pushNamed(context, AppRoutes.selectService, arguments: tableData);
                              } else {
                                Navigator.pushNamed(context, AppRoutes.tableInOrder, arguments: tableData);
                              }
                            },
                            onLongPress: () {
                              _showStatusChangeDialog(context, table.id, table.currentStatus);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              child: Card(
                                shadowColor: statusColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cardColor,
                                        cardColor.withOpacity(0.7),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12.r), // Reduced padding
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Ensure Column takes minimum space
                                    children: [
                                      // Header with table number and edit button
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              table.tableNumber,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _showStatusChangeDialog(context, table.id, table.currentStatus);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(8.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 18.sp,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Flexible(child: SizedBox(height: 8.h)), // Flexible spacing
                                      // Status Badge
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w), // Reduced padding
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(20.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: statusColor.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcons[uiStatus] ?? Icons.help_outline,
                                              size: 14.sp,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              statusLabelsEnglish[uiStatus] ?? uiStatus.capitalize(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(child: SizedBox(height: 8.h)), // Flexible spacing
                                      // Table Info
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.r),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              Icons.people,
                                              size: 16.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${table.capacity} seats',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              color: AppColors.darkGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h), // Reduced spacing
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.r),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              Icons.table_restaurant,
                                              size: 16.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'ID: ${table.id}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              color: AppColors.darkGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}