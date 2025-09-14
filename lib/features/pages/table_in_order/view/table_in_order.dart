import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/custom_widgets/custom_text_form_field.dart';

class TableInOrder extends StatefulWidget {
  TableInOrder({super.key});
  @override
  State<TableInOrder> createState() => _TableInOrderState();
}

class _TableInOrderState extends State<TableInOrder> {
  final List<Map<String, String>> fakeData = List.generate(
    6,
    (index) => {
      "title": "Hotshot Burger",
      "desc": "A delicious spicy burger with cheese and lettuce.",
      "price": "2675",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
    },
  );

  List<String> tabs = ["Tob Rated", "Pizza", "Burger"];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.babyPink.withOpacity(0.7),
                    child: Image.asset(
                      "assets/images/table_icon.png",
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Order to\n",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        TextSpan(
                          text: "Area 1 Table 1",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=3",
                        ),
                      ),
                      SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Captain order 1\n",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: "Refaat Alaa",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Table order",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Image.asset(
                          "assets/images/fluent_food.png",
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // ------- Title -------
              Text(
                "What's the order\n for this table?",
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // ------- Search Bar -------
              CustomTextFormField(
                radius: 40.r,
                hintText: "Search for food or drink",
                prefixIcon: Icon(Icons.search),
                filledColor: AppColors.borderColor,
              ),

              const SizedBox(height: 15),
              Container(
                height: 32.h,
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
                            style: TextStyle(
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
              const SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(tabs[selectedIndex],style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22.sp),)),
              Expanded(
                child: GridView.builder(
                  itemCount: fakeData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final item = fakeData[index];
                    return  Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                      child: Padding(
                        padding:  EdgeInsets.all(8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child:Image.asset(
                                "assets/images/burger.png",
                                height: 100.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item["title"]!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["desc"]!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item["price"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 16,
                                  child:  Icon(Icons.add, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
