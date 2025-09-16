import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/custom_widgets/custom_elevated_button.dart';
import 'package:food_2_go/custom_widgets/custom_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';

class TableInOrder extends StatefulWidget {
  TableInOrder({super.key});

  @override
  State<TableInOrder> createState() => _TableInOrderState();
}

class _TableInOrderState extends State<TableInOrder> {

  final List<Map<String, String>> fakeData = List.generate(
    6,
    (index) => {
      "id": "${index + 1}",
      "title": "Hotshot Burger",
      "desc": "A delicious spicy burger with cheese and lettuce.",
      "price": "267",
      "image": "assets/images/burger.png",
      "category": "burger",
    },
  );

  final List<Map<String, dynamic>> sizes = [
    {'id': 1, 'name': 'S', 'color': AppColors.primary, 'price': 0},
    {'id': 2, 'name': 'M', 'color': AppColors.primary, 'price': 50},
    {'id': 3, 'name': 'L', 'color': AppColors.primary, 'price': 100},
  ];

  final List<Map<String, dynamic>> ingredients = [
    {
      'id': 1,
      'name': 'beef',
      'image': 'assets/images/beef.png',
      'price': 30,
      'quantity': 1,
    },
  ];

  final List<Map<String, dynamic>> addOns = [
    {
      'id': 1,
      'name': 'Red Hot Sauce',
      'image': 'assets/images/red_sauce.png',
      'price': 15,
      'quantity': 1,
    },
  ];

  // Order management variables
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;

  List<String> tabs = ["Top Rated", "Pizza", "Burger"];
  int selectedIndex = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Add item to cart
  // void addToCart(Map<String, dynamic> orderDetails) {
  //   setState(() {
  //     cartItems.add(orderDetails);
  //     calculateTotal();
  //   });
  //
  //   // Show success message
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${orderDetails['title']} added to order'),
  //       backgroundColor: Colors.green,
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }

  // Calculate total amount
  void calculateTotal() {
    totalAmount = 0.0;
    for (var item in cartItems) {
      totalAmount += item['totalPrice'];
    }
  }

  // Filter products based on search and category
  List<Map<String, String>> getFilteredProducts() {
    List<Map<String, String>> filtered = fakeData;

    if (tabs[selectedIndex] != "Top Rated") {
      filtered = filtered
          .where(
            (item) =>
                item['category']?.toLowerCase() ==
                tabs[selectedIndex].toLowerCase(),
          )
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (item) => item['title']!.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
  }


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
                  SizedBox(width: 8.w),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Order to\n",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.subColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Area 1",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                            TextSpan(text: " "),
                            TextSpan(
                              text: "Table 1",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: AppColors.subColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: 20.h),
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
                      SizedBox(width: 10.w),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Captain order 1\n",
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.subColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "Refaat Alaa",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: AppColors.black,
                                fontWeight: FontWeight.w600,
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
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
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
              SizedBox(height: 10.h),
              Text(
                "What's the order\n for this table?",
                style: GoogleFonts.poppins(
                  fontSize: 25.sp,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              CustomTextFormField(
                controller: searchController,
                radius: 40.r,
                hintText: "Search for food or drink",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.subColor,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.subColor),
                filledColor: AppColors.borderColor,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 15.h),
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
                          child: Row(
                            children: [
                              Image.asset(
                                isSelected
                                    ? 'assets/images/top_rated_icon_selected.png'
                                    : 'assets/images/top_rated_icon_unselected.png',
                              ),
                              SizedBox(width: 7.w),
                              Text(
                                tabs[index],
                                style: GoogleFonts.inter(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.subColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
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
                child: Text(
                  tabs[selectedIndex],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: getFilteredProducts().length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final item = getFilteredProducts()[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0.7,
                      child: Padding(
                        padding: EdgeInsets.all(8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.asset(
                                "assets/images/burger.png",
                                height: 100.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              item["title"]!,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Ingredients:',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item["desc"]!,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: AppColors.subColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item["price"]!} \$",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 16.r,
                                  child: IconButton(
                                    onPressed: () {
                                      _showProductDialog(item);
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: AppColors.white,
                                      size: 18.sp,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDialog(Map<String, String> product) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int? selectedSizeIndex;
            int quantity = 1;
            List<Map<String, dynamic>> selectedIngredients = List.from(
              ingredients,
            );
            List<Map<String, dynamic>> selectedAddOns = List.from(addOns);

            double calculateItemPrice() {
              double basePrice = double.parse(product["price"]!);
              double sizePrice = selectedSizeIndex != null
                  ? sizes[selectedSizeIndex!]['price']
                  : 0;
              double ingredientsPrice = selectedIngredients.fold(
                0,
                (sum, item) => sum + (item['price'] * item['quantity']),
              );
              double addOnsPrice = selectedAddOns.fold(
                0,
                (sum, item) => sum + (item['price'] * item['quantity']),
              );
              return (basePrice + sizePrice + ingredientsPrice + addOnsPrice) *
                  quantity;
            }

            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.r),
                        ),
                        child: Image.asset(
                          product["image"]!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("1"),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      product["title"]!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Quantity Counter
                                GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      quantity++;
                                    });
                                  },
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 16.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "\$${calculateItemPrice().toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Ingredients',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                            ...selectedIngredients.map(
                              (ingredient) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7.h,
                                        ),
                                        child: Image.asset(ingredient['image']),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        ingredient['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.borderColor
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                      color:AppColors.white,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              if (ingredient['quantity'] > 0) {
                                                ingredient['quantity']--;
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 32.w,
                                            height: 32.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.borderColor,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              size: 16.sp,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "${ingredient['quantity']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              ingredient['quantity']++;
                                            });
                                          },
                                          child: Container(
                                            width: 32.w,
                                            height: 32.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.borderColor,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 16.sp,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Add ons',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                            ...selectedAddOns.map(
                              (addon) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7.h,
                                        ),
                                        child: Image.asset(addon['image']),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        addon['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.borderColor
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                      color:AppColors.white,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              if (addon['quantity'] > 0) {
                                                addon['quantity']--;
                                              }
                                            });
                                          },
                                          child:  Container(
                                            width: 32.w,
                                            height: 32.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.borderColor,
                                              borderRadius:
                                              BorderRadius.circular(4.r),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              size: 16.sp,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "${addon['quantity']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              addon['quantity']++;
                                            });
                                          },
                                          child:  Container(
                                            width: 32.w,
                                            height: 32.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.borderColor,
                                              borderRadius:
                                              BorderRadius.circular(4.r),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 16.sp,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Combo',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 7.h,
                                      ),
                                      child: Image.asset(
                                        'assets/images/combo.png',
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'Combo',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: sizes.map((size) {
                                    int sizeIndex = sizes.indexOf(size);
                                    final isSelected =
                                        selectedSizeIndex == sizeIndex;
                                    return Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: GestureDetector(
                                        onTap: () {
                                          setDialogState(() {
                                            selectedSizeIndex = isSelected
                                                ? null
                                                : sizeIndex;
                                          });
                                        },
                                        child: Container(
                                          width: 28.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            color: size['color'],
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.yellow
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Center(
                                            child: Text(
                                              size['name'],
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h,),
                            CustomElevatedButton(
                              text: "Add To Order ",
                              onPressed: () {
                                // Create order details
                                Map<String, dynamic> orderDetails = {
                                  'productId': product['id'],
                                  'title': product['title'],
                                  'basePrice': double.parse(
                                    product['price']!,
                                  ),
                                  'quantity': quantity,
                                  'selectedSize': selectedSizeIndex != null
                                      ? sizes[selectedSizeIndex!]
                                      : null,
                                  'ingredients': selectedIngredients
                                      .where((i) => i['quantity'] > 0)
                                      .toList(),
                                  'addOns': selectedAddOns
                                      .where((a) => a['quantity'] > 0)
                                      .toList(),
                                  'totalPrice': calculateItemPrice(),
                                  'image': product['image'],
                                };

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.confirmOrder,
                                );
                              },
                              backgroundColor: AppColors.primary,
                              textStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
