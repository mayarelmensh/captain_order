import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 100.h),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: (){},
                    icon: CircleAvatar(
                        backgroundColor: AppColors.darkYellow,
                        child: Icon(Icons.arrow_back))),
                Text("Choose The Service\n below",

                  style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                  color: AppColors.black
                ),),
              ],
            ),
            SizedBox(height: 70.h,),
            GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, AppRoutes.tableInOrder);
                },
                child: Image.asset('assets/images/take_order.png')),
            SizedBox(height: 24.h,),
            Text("Or",style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black
            ),),
            SizedBox(height: 24.h,),
            GestureDetector(
                onTap: (){

                },
                child: Image.asset('assets/images/request_payment.png')),
          ],
        ),
      ),
    );
  }
}
