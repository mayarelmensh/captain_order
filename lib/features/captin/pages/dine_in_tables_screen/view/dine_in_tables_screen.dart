import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/features/waiter/pages/home_screen/view/order_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../auth/login/logic/cubit/login_cubit.dart';
import '../../../../auth/login/logic/cubit/login_states.dart';
import '../logic/cubit/dine_in_tables_cubit.dart';
import '../logic/cubit/dine_in_tables_states.dart';
import '../logic/model/dine_in_tables_model.dart';
import '../../../../../controller/cache/shared_preferences_utils.dart';

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // ✅ استنى frame واحد عشان الـ context يكون جاهز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final loginCubit = context.read<LoginCubit>();
        final waiterValue = loginCubit.currentWaiterStatus;

        print('🔄 DineIn Init: waiter value = $waiterValue');
        print('🔄 DineIn Init: isWaiter = ${waiterValue == 1}');

        // لو محتاج تعمل حاجة بناءً على الـ waiter status
        // استخدمها هنا
      } catch (e) {
        print('❌ Error in DineInTablesScreen initState: $e');
      }
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(385, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => DineInTablesCubit(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _DineInTablesScreenContent(),
          ),
        );
      },
    );
  }
}

class _DineInTablesScreenContent extends StatefulWidget {
  const _DineInTablesScreenContent();

  @override
  _DineInTablesScreenContentState createState() =>
      _DineInTablesScreenContentState();
}

class _DineInTablesScreenContentState
    extends State<_DineInTablesScreenContent> {
  Set<int> updatingTables = {};
  String _selectedRole = 'Captain Order';
  bool isTransferMode = false;
  TableModel? sourceTableForTransfer;
  Set<int> selectedMergeTables = {};
  bool _hasLoadedData = false;

  final Map<String, String> apiToUiStatus = {
    'available': 'available',
    'not_available_pre_order': 'waiting',
    'not_available_with_order': 'dining',
    'not_available_but_checkout': 'paid',
    'reserved': 'reserved',
  };

  final Map<String, String> uiToApiStatus = {
    'available': 'available',
    'waiting': 'not_available_pre_order',
    'dining': 'not_available_with_order',
    'paid': 'not_available_but_checkout',
    'reserved': 'reserved',
  };

  final Map<String, Color> statusColors = {
    'available': AppColors.white,
    'paid': AppColors.lightGreen,
    'dining': AppColors.babyPink,
    'waiting': AppColors.blue,
    'reserved': AppColors.babyPink,
    'default': AppColors.borderColor,
  };

  final Map<String, Color> statusTextColors = {
    'available': AppColors.darkGrey,
    'paid': AppColors.darkGrey,
    'dining': AppColors.darkGrey,
    'waiting': AppColors.black,
    'reserved': AppColors.pink,
    'default': AppColors.black,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginCubit = context.read<LoginCubit>();
      final userRole = loginCubit.currentUserRole.toLowerCase(); // ✅ استخدم الـ role

      // ✅ لو دخل كـ captain_order، يفضل captain_order
      // لو دخل كـ waiter، يبقى waiter
      setState(() {
        if (userRole == 'captain_order') {
          _selectedRole = 'Captain Order';
        } else if (userRole == 'waiter') {
          _selectedRole = 'Waiter';
        } else {
          _selectedRole = 'Captain Order'; // default
        }
      });

      if (!_hasLoadedData) {
        context.read<DineInTablesCubit>().loadCafeData();
        _hasLoadedData = true;
      }

      print('🔄 Init: role from API = $userRole');
      print('🔄 Init: selected role = $_selectedRole');
      print('🔄 Init: waiter value = ${loginCubit.currentWaiterStatus}');
    });
  }

  void _showTableActionDialog(BuildContext parentContext, TableModel table) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final cubit = parentContext.read<DineInTablesCubit>();
        final area = cubit.getLocationById(table.locationId);
        final uiStatus = apiToUiStatus[table.currentStatus] ?? 'default';

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
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: statusColors[uiStatus]?.withOpacity(0.2) ??
                        AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: statusColors[uiStatus] ??
                              AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusIcons[uiStatus] ?? Icons.table_restaurant,
                          size: 24.sp,
                          color: statusTextColors[uiStatus] ?? AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table ${table.tableNumber}',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              '${area?.name ?? "Unknown Area"} • ${table.capacity} seats',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: AppColors.subColor,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColors[uiStatus] ??
                                    AppColors.borderColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                uiStatus.capitalize(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: statusTextColors[uiStatus] ??
                                      AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              onTap: table.subTable.isNotEmpty
                                  ? () {
                                Navigator.pop(dialogContext);
                                _showMergedTablesDialog(
                                  parentContext,
                                  table,
                                );
                              }
                                  : null,
                              child: Text(
                                table.subTable.isNotEmpty
                                    ? 'Merged with tables: ${table.subTable.map((sub) => sub.tableNumber).join(", ")}'
                                    : 'No sub-tables (Not merged)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: table.subTable.isNotEmpty
                                      ? AppColors.blue
                                      : AppColors.subColor,
                                  fontStyle: FontStyle.italic,
                                  decoration: table.subTable.isNotEmpty
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildActionButton(
                  icon: Icons.edit_note,
                  title: 'Change Status',
                  subtitle: 'Update table status',
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showStatusChangeDialog(
                      parentContext,
                      table.id,
                      table.currentStatus,
                    );
                  },
                ),
                if (uiStatus == 'dining' ||
                    uiStatus == 'reserved' ||
                    uiStatus == 'paid' ||
                    uiStatus == 'waiting') ...[
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.swap_horiz,
                    title: 'Transfer Table',
                    subtitle: 'Move orders to another table',
                    color: AppColors.pink,
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _startTransferMode(table);
                    },
                  ),
                ] else ...[
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.add_circle_outline,
                    title: 'Start Order',
                    subtitle: 'Begin new order for this table',
                    color: AppColors.lightGreen,
                    onTap: () {
                      Navigator.pop(dialogContext);
                      final tableData = {
                        "id": table.id,
                        "number": table.tableNumber,
                        "area": area?.name ?? "Unknown Area",
                      };
                      Navigator.pushNamed(
                        parentContext,
                        AppRoutes.tableInOrder,
                        arguments: tableData,
                      );
                    },
                  ),
                ],
                SizedBox(height: 12.h),
                _buildActionButton(
                  icon: Icons.link,
                  title: 'Merge Tables',
                  subtitle: 'Merge with other tables',
                  color: AppColors.purple,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showMergeTablesDialog(parentContext, table);
                  },
                ),
                if (table.subTable.isNotEmpty) ...[SizedBox(height: 12.h)],
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMergedTablesDialog(
      BuildContext parentContext,
      TableModel mainTable,
      ) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 10,
          child: Container(
            height: 0.85.sh,
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Merged Tables for Table ${mainTable.tableNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 6.w,
                        mainAxisSpacing: 6.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: mainTable.subTable.length,
                      itemBuilder: (context, index) {
                        final subTable = mainTable.subTable[index];
                        final uiStatus = apiToUiStatus[subTable] ?? 'default';
                        final statusColor =
                            statusColors[uiStatus] ?? statusColors['default']!;
                        final textColor = statusTextColors[uiStatus] ??
                            statusTextColors['default']!;
                        return GestureDetector(
                          onLongPress: () => _showSubTableActionDialog(
                            parentContext,
                            subTable,
                            mainTable,
                          ),
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
                                  Text(
                                    subTable.tableNumber,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 3.h,
                                              horizontal: 8.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              borderRadius:
                                              BorderRadius.circular(30.r),
                                            ),
                                            child: Text(
                                              uiStatus.capitalize(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                _showSubTableActionDialog(
                                                  parentContext,
                                                  subTable,
                                                  mainTable,
                                                ),
                                            child: Container(
                                              padding: EdgeInsets.all(6.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                BorderRadius.circular(6.r),
                                              ),
                                              child: Icon(
                                                Icons.more_horiz,
                                                size: 14.sp,
                                                color: AppColors.subColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/seats.png',
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${subTable.capacity} seats',
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
                                          Image.asset(
                                            "assets/images/table_icon.png",
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'table ${subTable.id}',
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
                  ],
                ),
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final cubit = parentContext.read<DineInTablesCubit>();
                    await cubit.refresh();
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubTableActionDialog(
      BuildContext parentContext,
      SubTableModel subTable,
      TableModel mainTable,
      ) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
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
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Table ${subTable.tableNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildActionButton(
                  icon: Icons.link_off,
                  title: 'Split Table',
                  subtitle: 'Unmerge this table from the main table',
                  color: AppColors.red,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showSplitConfirmationDialog(
                      parentContext,
                      subTable,
                      mainTable,
                    );
                  },
                ),
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSplitConfirmationDialog(
      BuildContext parentContext,
      SubTableModel subTable,
      TableModel mainTable,
      ) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Split',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to split Table ${subTable.tableNumber} from the main table ${mainTable.tableNumber}?',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.subColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
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
                          Navigator.pop(dialogContext);
                          Navigator.pop(parentContext);
                          final cubit = parentContext.read<DineInTablesCubit>();
                          final success = await cubit.unmergeTable(
                            tableId: subTable.id,
                          );
                          if (success) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Table ${subTable.tableNumber} split successfully',
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            await cubit.refresh();
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('Failed to split table'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Split',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
  }

  void _showMergeTablesDialog(
      BuildContext parentContext,
      TableModel mainTable,
      ) {
    final cubit = parentContext.read<DineInTablesCubit>();
    final allTables = cubit.getFilteredTables();
    final availableTables = allTables
        .where((table) => table.id != mainTable.id && table.subTable.isEmpty)
        .toList();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: 0.95.sw,
              height: 0.85.sh,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Merge with Table ${mainTable.tableNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.subColor,
                            size: 24.sp,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            setState(() => selectedMergeTables.clear());
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, color: AppColors.borderColor),
                  SizedBox(height: 12.h),
                  Text(
                    selectedMergeTables.isEmpty
                        ? 'Select tables to merge with Table ${mainTable.tableNumber}'
                        : '${selectedMergeTables.length} table${selectedMergeTables.length > 1 ? 's' : ''} selected',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.subColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: availableTables.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            size: 48.sp,
                            color: AppColors.subColor.withOpacity(0.5),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No tables available to merge',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: AppColors.subColor,
                            ),
                          ),
                        ],
                      ),
                    )
                        : GridView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h,
                        horizontal: 5.w,
                      ),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: availableTables.length,
                      itemBuilder: (context, index) {
                        final table = availableTables[index];
                        final isSelected =
                        selectedMergeTables.contains(table.id);
                        final uiStatus =
                            apiToUiStatus[table.currentStatus] ??
                                'default';
                        final statusColor = statusColors[uiStatus] ??
                            statusColors['default']!;
                        final textColor = statusTextColors[uiStatus] ??
                            statusTextColors['default']!;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedMergeTables.remove(table.id);
                              } else {
                                selectedMergeTables.add(table.id);
                              }
                            });
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
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.blue
                                      : Colors.transparent,
                                ),
                              ),
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    table.tableNumber,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 3.h,
                                              horizontal: 8.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              borderRadius:
                                              BorderRadius.circular(
                                                30.r,
                                              ),
                                            ),
                                            child: Text(
                                              uiStatus.capitalize(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight:
                                                FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              size: 18.sp,
                                              color: AppColors.lightGreen,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/seats.png',
                                          ),
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
                                          Image.asset(
                                            "assets/images/table_icon.png",
                                          ),
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
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            setState(() => selectedMergeTables.clear());
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: AppColors.borderColor),
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
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedMergeTables.isEmpty
                              ? null
                              : () async {
                            Navigator.pop(dialogContext);
                            final cubit =
                            parentContext.read<DineInTablesCubit>();
                            final success = await cubit.mergeTables(
                              tableId: mainTable.id,
                              mergeTableIds:
                              selectedMergeTables.toList(),
                            );
                            if (success) {
                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tables merged successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              await cubit.refresh();
                            } else {
                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to merge tables'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            setState(() => selectedMergeTables.clear());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedMergeTables.isEmpty
                                ? AppColors.borderColor
                                : AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Merge Tables',
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
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 20.sp, color: color),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.subColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.subColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTransferMode(TableModel sourceTable) {
    setState(() {
      isTransferMode = true;
      sourceTableForTransfer = sourceTable;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transfer mode activated. Select destination table for Table ${sourceTable.tableNumber}',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelTransferMode() {
    print("🔄 Cancelling Transfer Mode");
    setState(() {
      isTransferMode = false;
      sourceTableForTransfer = null;
    });
    final cubit = context.read<DineInTablesCubit>();
    if (cubit.state is! DineInTablesLoaded) {
      cubit.loadCafeData();
    }
  }

  Future<void> _showTransferConfirmationDialog(
      TableModel sourceTable,
      TableModel destinationTable,
      ) async {
    final cubit = context.read<DineInTablesCubit>();
    await cubit.getTableOrder(tableId: sourceTable.id);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return BlocBuilder<DineInTablesCubit, DineInTablesState>(
          builder: (context, state) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.pink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_horiz,
                        size: 32.sp,
                        color: AppColors.pink,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Transfer Orders',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.subColor,
                        ),
                        children: [
                          TextSpan(text: 'Transfer all orders from '),
                          TextSpan(
                            text: 'Table ${sourceTable.tableNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(text: ' to '),
                          TextSpan(
                            text: 'Table ${destinationTable.tableNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pink,
                            ),
                          ),
                          TextSpan(text: '?'),
                        ],
                      ),
                    ),
                    if (state is GetTableOrderSuccess &&
                        state.tableOrderModel.orders.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orders to transfer:',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ...state.tableOrderModel.orders
                                .take(3)
                                .map(
                                  (order) => Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text(
                                  '• ${order.name} (${order.count}x)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppColors.subColor,
                                  ),
                                ),
                              ),
                            ),
                            if (state.tableOrderModel.orders.length > 3)
                              Text(
                                '... and ${state.tableOrderModel.orders.length - 3} more items',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: AppColors.subColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _cancelTransferMode();
                              Navigator.pop(dialogContext);
                            },
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
                              Navigator.pop(dialogContext);
                              await _performTransfer(
                                sourceTable,
                                destinationTable,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pink,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Transfer',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

  Future<void> _performTransfer(
      TableModel sourceTable,
      TableModel destinationTable,
      ) async {
    final cubit = context.read<DineInTablesCubit>();
    await cubit.getTableOrder(tableId: sourceTable.id);
    final state = cubit.state;
    if (state is GetTableOrderSuccess) {
      final cartIds = state.tableOrderModel.orders
          .where((order) => order.cartId != null)
          .map((order) => order.cartId!)
          .toList();
      if (cartIds.isNotEmpty) {
        final success = await cubit.transferOrder(
          sourceTableId: sourceTable.id,
          destinationTableId: destinationTable.id,
          cartIds: cartIds,
          newStatus: "available",
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Orders transferred successfully from Table ${sourceTable.tableNumber} to Table ${destinationTable.tableNumber}',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No orders found to transfer'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No orders found to transfer'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    _cancelTransferMode();
  }

  void _showStatusChangeDialog(
      BuildContext parentContext,
      int tableId,
      String currentStatus,
      ) {
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
                    colors: [Colors.white, Colors.grey.shade50],
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
                                      ? statusColors[statusKey] ??
                                      AppColors.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: statusColors[statusKey] ??
                                          AppColors.borderColor,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      statusIcons[statusKey] ??
                                          Icons.help_outline,
                                      size: 16.sp,
                                      color: statusTextColors[statusKey] ??
                                          Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      statusLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.black
                                            : AppColors.subColor,
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
                              await _handleStatusUpdate(
                                parentContext,
                                cubit,
                                tableId,
                                selectedStatus,
                              );
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
    setState(() => updatingTables.add(tableId));
    try {
      final apiStatus = uiToApiStatus[selectedStatus] ?? 'available';
      print("🔄 Attempting to update table $tableId to status: $apiStatus");
      final success = await cubit.changeTableStatus(
        tableId: tableId,
        newStatus: apiStatus,
      );
      if (success) {
        await cubit.refresh();
        print("✅ Table status updated successfully");
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Table status updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
      } else {
        print("❌ Failed to update table status");
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update table status'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
      }
    } catch (e) {
      print("⚠️ Exception during status update: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating table status'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
    } finally {
      if (mounted) setState(() => updatingTables.remove(tableId));
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.subColor,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final loginCubit = LoginCubit();
                  loginCubit.logout();
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.loginRoute,
                          (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (_selectedRole == 'Waiter') return OrderScreen();
    return _buildDineInTablesContent(context);
  }

  Widget _buildDineInTablesContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: BlocBuilder<DineInTablesCubit, DineInTablesState>(
        builder: (context, state) {
          if (state is DineInTablesInitial && !_hasLoadedData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<DineInTablesCubit>().loadCafeData();
              _hasLoadedData = true;
            });
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is DineInTablesLoading)
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          if (state is DineInTablesError)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Something went error ,please check internet connection and try again",
                    style: GoogleFonts.poppins(
                      color: AppColors.black,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
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
          if (state is DineInTablesLoaded) {
            final tabs = context.read<DineInTablesCubit>().getTabs();
            final filteredTables =
            context.read<DineInTablesCubit>().getFilteredTables();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTransferMode
                                ? 'Select destination table for Table ${sourceTableForTransfer?.tableNumber ?? ""}'
                                : 'Select an available table to start an order',
                            style: GoogleFonts.poppins(
                              color: isTransferMode
                                  ? AppColors.pink
                                  : AppColors.subColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTransferMode)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.pink.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              size: 16.sp,
                              color: AppColors.pink,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Transfer Mode',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 40.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = state.selectedLocationIndex == index;
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                      (constraints.maxWidth / 180).floor();
                      return GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          2,
                          crossAxisSpacing: 2.5.w,
                          mainAxisSpacing: 9.h,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredTables.length,
                        itemBuilder: (context, index) {
                          final table = filteredTables[index];
                          final uiStatus =
                              apiToUiStatus[table.currentStatus] ?? 'default';
                          final statusColor = statusColors[uiStatus] ??
                              statusColors['default']!;
                          final textColor = statusTextColors[uiStatus] ??
                              statusTextColors['default']!;
                          final isAvailableForTransfer = isTransferMode &&
                              (uiStatus == 'available') &&
                              (sourceTableForTransfer?.id != table.id);
                          return GestureDetector(
                            onTap: () {
                              if (isTransferMode) {
                                if (isAvailableForTransfer)
                                  _showTransferConfirmationDialog(
                                    sourceTableForTransfer!,
                                    table,
                                  );
                                else if (sourceTableForTransfer?.id == table.id)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cannot transfer to the same table',
                                      ),
                                      backgroundColor: Colors.orange,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                else
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Can only transfer to available tables',
                                      ),
                                      backgroundColor: Colors.orange,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                              } else
                                _handleNormalTableTap(context, table, uiStatus);
                            },
                            onLongPress: isTransferMode
                                ? null
                                : () => _showTableActionDialog(context, table),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              color: statusColor,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  color: isTransferMode
                                      ? (isAvailableForTransfer
                                      ? AppColors.lightGreen
                                      .withOpacity(0.3)
                                      : AppColors.white.withOpacity(0.3))
                                      : AppColors.white.withOpacity(0.7),
                                  border: isTransferMode &&
                                      isAvailableForTransfer
                                      ? Border.all(
                                    color: AppColors.blue.withOpacity(0.7),
                                    width: 2,
                                  )
                                      : null,
                                ),
                                padding: EdgeInsets.all(12.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          table.tableNumber,
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        if (isTransferMode &&
                                            isAvailableForTransfer)
                                          Container(
                                            padding: EdgeInsets.all(4.r),
                                            decoration: BoxDecoration(
                                              color: AppColors.blue
                                                  .withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.swap_horiz,
                                              size: 16.sp,
                                              color: Colors.white,
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
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 3.h,
                                                horizontal: 8.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.white
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                BorderRadius.circular(30.r),
                                              ),
                                              child: Text(
                                                uiStatus.capitalize(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            if (!isTransferMode)
                                              GestureDetector(
                                                onTap: updatingTables
                                                    .contains(table.id)
                                                    ? null
                                                    : () =>
                                                    _showTableActionDialog(
                                                      context,
                                                      table,
                                                    ),
                                                child: Container(
                                                  padding: EdgeInsets.all(6.r),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6.r),
                                                  ),
                                                  child: updatingTables
                                                      .contains(table.id)
                                                      ? SizedBox(
                                                    width: 14.sp,
                                                    height: 14.sp,
                                                    child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppColors
                                                          .primary,
                                                    ),
                                                  )
                                                      : Icon(
                                                    Icons.more_horiz,
                                                    size: 14.sp,
                                                    color:
                                                    AppColors.subColor,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/seats.png',
                                            ),
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
                                            Image.asset(
                                              "assets/images/table_icon.png",
                                            ),
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
    );
  }

  void _handleNormalTableTap(
      BuildContext context,
      TableModel table,
      String uiStatus,
      ) {
    final cubit = context.read<DineInTablesCubit>();
    final area = cubit.getLocationById(table.locationId);
    final tableData = {
      "id": table.id,
      "number": table.tableNumber,
      "area": area?.name ?? "Unknown Area",
    };
    if (uiStatus == 'dining' ||
        uiStatus == 'reserved' ||
        uiStatus == 'paid' ||
        uiStatus == 'waiting')
      Navigator.pushNamed(
        context,
        AppRoutes.selectService,
        arguments: tableData,
      );
    else
      Navigator.pushNamed(
        context,
        AppRoutes.tableInOrder,
        arguments: tableData,
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, loginState) {
        print('🔄 LoginCubit state changed: $loginState');
        if (loginState is LoginSuccess) {
          final userRole = loginState.loginResponse.role?.toLowerCase();
          print('✅ Login success, role from response: $userRole');

          // ✅ اعتمد على الـ role مش على waiter field
          setState(() {
            if (userRole == 'captain_order') {
              _selectedRole = 'Captain Order';
            } else if (userRole == 'waiter') {
              _selectedRole = 'Waiter';
            }
          });
        } else if (loginState is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: ${loginState.failure.errorMsg}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (loginState is LoginInitial) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginRoute,
                  (Route<dynamic> route) => false,
            );
          }
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, loginState) {
          if (loginState is LoginInitial) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final loginResponse = context.read<LoginCubit>().loginResponse;
          final waiterValue = loginResponse?.captainOrder?.waiter;

          // ✅ الـ side menu يظهر بس لو waiter == 1
          final hasSideMenu = waiterValue == 1;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                _selectedRole == 'Waiter' ? 'Waiter Orders' : 'Dine-in Tables',
                style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              // ✅ السايد منيو يظهر بس لو عنده صلاحية waiter
              leading: hasSideMenu
                  ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppColors.black,
                    size: 28.sp,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.black, size: 28.sp),
                  onPressed: () => _handleLogout(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
            // ✅ السايد منيو يظهر بس لو عنده صلاحية waiter
            drawer: hasSideMenu
                ? Drawer(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 60.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Table Management',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: _selectedRole == 'Captain Order'
                            ? AppColors.primary
                            : AppColors.subColor,
                      ),
                      title: Text(
                        'Captain Order',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: _selectedRole == 'Captain Order'
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedRole == 'Captain Order'
                              ? AppColors.primary
                              : AppColors.subColor,
                        ),
                      ),
                      selected: _selectedRole == 'Captain Order',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'Captain Order';
                          _hasLoadedData = false;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.support_agent,
                        color: _selectedRole == 'Waiter'
                            ? AppColors.primary
                            : AppColors.subColor,
                      ),
                      title: Text(
                        'Waiter',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: _selectedRole == 'Waiter'
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedRole == 'Waiter'
                              ? AppColors.primary
                              : AppColors.subColor,
                        ),
                      ),
                      selected: _selectedRole == 'Waiter',
                      onTap: () {
                        setState(() => _selectedRole = 'Waiter');
                        Navigator.of(context).pop();
                      },
                    ),
                    Divider(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Role: $_selectedRole',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Has Waiter Access: ${hasSideMenu ? 'Yes' : 'No'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.subColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : null,
            body: _buildMainContent(context),
            floatingActionButton: isTransferMode
                ? FloatingActionButton.extended(
              onPressed: _cancelTransferMode,
              backgroundColor: AppColors.red,
              icon: Icon(Icons.cancel, color: AppColors.white),
              label: Text(
                'Cancel Transfer',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            )
                : null,
          );
        },
      ),
    );
  }
}