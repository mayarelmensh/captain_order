import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/model/dine_in_tables_model.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class DineInTablesScreen extends StatefulWidget {
  const DineInTablesScreen({super.key});

  @override
  State<DineInTablesScreen> createState() => _DineInTablesScreenState();
}

class _DineInTablesScreenState extends State<DineInTablesScreen> {
  List<String> tabs = ["All Locations", "Area 1", "Area 2"];
  int selectedIndex = 0;

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


  // Sample data based on the provided JSON structure
  final CafeResponseModel cafeResponse = CafeResponseModel(
    cafeLocation: [
      CafeLocationModel(
        id: 1,
        name: "Loc 1",
        createdAt: null,
        updatedAt: "2025-09-08T08:31:07.000000Z",
        branchId: 4,
        location: [
          LocationModel(lat: 31.230967838191447, lng: 29.958171844482425),
          LocationModel(lat: 31.226967864410142, lng: 29.951519966125492),
        ],
        tables: [
          TableModel(
            id: 1,
            tableNumber: "A1",
            locationId: 1,
            branchId: 4,
            capacity: 16,
            qrCode: null,
            status: 1,
            createdAt: "2025-04-07T09:51:34.000000Z",
            updatedAt: "2025-09-10T07:24:56.000000Z",
            currentStatus: "available",
            occupied: 0,
            qrCodeLink: null,
          ),
          TableModel(
            id: 2,
            tableNumber: "A2",
            locationId: 1,
            branchId: 4,
            capacity: 12,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-09-09T09:27:36.000000Z",
            currentStatus: "dining",
            occupied: 1,
            qrCodeLink: null,
          ),
          TableModel(
            id: 3,
            tableNumber: "A3",
            locationId: 1,
            branchId: 4,
            capacity: 9,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-09-09T09:27:36.000000Z",
            currentStatus: "paid",
            occupied: 0,
            qrCodeLink: null,
          ),
        ],
      ),
      CafeLocationModel(
        id: 2,
        name: "Area 2",
        createdAt: null,
        updatedAt: "2025-08-11T08:44:18.000000Z",
        branchId: 4,
        location: null,
        tables: [
          TableModel(
            id: 4,
            tableNumber: "A4",
            locationId: 2,
            branchId: 4,
            capacity: 12,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-08-20T14:11:22.000000Z",
            currentStatus: "dining",
            occupied: 1,
            qrCodeLink: null,
          ),
          TableModel(
            id: 5,
            tableNumber: "A5",
            locationId: 2,
            branchId: 4,
            capacity: 10,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-09-09T08:58:38.000000Z",
            currentStatus: "waiting",
            occupied: 0,
            qrCodeLink: null,
          ),
          TableModel(
            id: 6,
            tableNumber: "A6",
            locationId: 2,
            branchId: 4,
            capacity: 7,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-09-09T08:58:38.000000Z",
            currentStatus: "reserved",
            occupied: 0,
            qrCodeLink: null,
          ),
          TableModel(
            id: 7,
            tableNumber: "A7",
            locationId: 2,
            branchId: 4,
            capacity: 10,
            qrCode: null,
            status: 1,
            createdAt: null,
            updatedAt: "2025-09-09T08:58:38.000000Z",
            currentStatus: "available",
            occupied: 0,
            qrCodeLink: null,
          ),
        ],
      ),
    ],
    financialAccount: [],
    paymentMethod: [],
  );

  // Filter tables based on selected tab
  List<TableModel> getFilteredTables() {
    if (selectedIndex == 0) {
      // All Locations: Combine tables from all locations
      return cafeResponse.cafeLocation
          .expand((location) => location.tables)
          .toList();
    } else {
      // Specific location: Filter by locationId
      try {
        return cafeResponse.cafeLocation
            .firstWhere((location) => location.id == selectedIndex)
            .tables;
      } catch (e) {
        return [];
      }
    }
  }

  Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? statusColors['default']!;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTables = getFilteredTables();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 45.h),
        child: Column(
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
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
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
                  mainAxisSpacing: 1.h,
                  childAspectRatio: 1.2, // Adjusted for taller cards
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  final statusColor = getStatusColor(table.currentStatus);
                  return GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, AppRoutes.selectService,arguments: [

                      ]);
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Text(
                                  table.currentStatus.capitalize(),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Column(
                             crossAxisAlignment: CrossAxisAlignment.start,                            children: [
                              Row(children: [
                                Image.asset('assets/images/seats.png'),
                                SizedBox(width: 8.w,),
                                Text(
                                  '${table.capacity} seats',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color:AppColors.darkGrey,
                                  ),
                                ),
                              ],),
                                SizedBox(height: 4.h),
                                Row(children: [
                                  Image.asset("assets/images/table_icon.png"),
                                  SizedBox(width: 8.w,),
                                  Text(
                                    'table ${table.id} ',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                ],)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}