import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/custom_widgets/custom_elevated_button.dart';
import 'package:food_2_go/custom_widgets/custom_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../auth/login/logic/cubit/login_cubit.dart';
import '../../../../auth/login/logic/cubit/login_states.dart';
import '../logic/cubit/dine_in_order_cubit.dart';
import '../logic/model/dine_in_order_model.dart';

class TableInOrder extends StatefulWidget {
  TableInOrder({super.key});

  @override
  State<TableInOrder> createState() => _TableInOrderState();
}

class _TableInOrderState extends State<TableInOrder> {
  // Table data
  String? tableNumber;
  String? area;

  // Order management variables
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;

  TextEditingController searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final tableId = args['id'] as int;
      setState(() {
        tableNumber = args['number'] as String;
        area = args['area'] as String;
      });
      print("🟢 TableInOrder args => id: $tableId, number: $tableNumber, area: $area");
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Calculate total amount
  void calculateTotal() {
    totalAmount = 0.0;
    for (var item in cartItems) {
      totalAmount += item['totalPrice'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductListCubit(),
      child: Scaffold(
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
                                text: area ?? "Area 1",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                ),
                              ),
                              TextSpan(text: " "),
                              TextSpan(
                                text: tableNumber != null
                                    ? "Table $tableNumber"
                                    : "Table 1",
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
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        final loginCubit = context.read<LoginCubit>();
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: loginCubit.captainImageLink != null
                                  ? NetworkImage(loginCubit.captainImageLink!)
                                  : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                            ),
                            SizedBox(width: 10.w),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Captain order ${loginCubit.captainId ?? '1'}\n",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: AppColors.subColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: loginCubit.captainName ?? "Refaat Alaa",
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
                        );
                      },
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
                    context.read<ProductListCubit>().searchProducts(value);
                  },
                ),
                SizedBox(height: 15.h),

                // Categories Tabs - Dynamic from API
                BlocBuilder<ProductListCubit, ProductListState>(
                  builder: (context, state) {
                    if (state is ProductListLoaded) {
                      final tabs = context.read<ProductListCubit>().getCategoryTabs();
                      return Container(
                        height: 32.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tabs.length,
                          itemBuilder: (context, index) {
                            final isSelected = state.selectedCategoryIndex == index;

                            return GestureDetector(
                              onTap: () {
                                context.read<ProductListCubit>().selectCategory(index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(right: 10.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.borderColor,
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      // Show category image or default icon
                                      if (index > 0 && state.productResponse.categories.isNotEmpty) ...[
                                        ClipOval(
                                          child: Image.network(
                                            context.read<ProductListCubit>().getActiveCategories()[index - 1].imageLink,
                                            width: 20.w,
                                            height: 20.h,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/top_rated_icon_unselected.png',
                                                width: 20.w,
                                                height: 20.h,
                                              );
                                            },
                                          ),
                                        ),
                                      ] else ...[
                                        Image.asset(
                                          isSelected
                                              ? 'assets/images/top_rated_icon_selected.png'
                                              : 'assets/images/top_rated_icon_unselected.png',
                                        ),
                                      ],
                                      SizedBox(width: 7.w),
                                      Text(
                                        tabs[index],
                                        style: GoogleFonts.inter(
                                          color: isSelected ? AppColors.white : AppColors.subColor,
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
                      );
                    }
                    return Container(height: 32.h);
                  },
                ),

                const SizedBox(height: 20),

                // Category Title
                BlocBuilder<ProductListCubit, ProductListState>(
                  builder: (context, state) {
                    if (state is ProductListLoaded) {
                      final tabs = context.read<ProductListCubit>().getCategoryTabs();
                      if (tabs.isNotEmpty && state.selectedCategoryIndex < tabs.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            tabs[state.selectedCategoryIndex],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                            ),
                          ),
                        );
                      }
                    }
                    return SizedBox.shrink();
                  },
                ),

                // Products Grid - Dynamic from API
                Expanded(
                  child: BlocBuilder<ProductListCubit, ProductListState>(
                    builder: (context, state) {
                      if (state is ProductListLoading) {
                        return Center(child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ));
                      } else if (state is ProductListError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${state.message}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primary,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              ElevatedButton(
                                onPressed: () => context.read<ProductListCubit>().refresh(),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      } else if (state is ProductListLoaded) {
                        final products = state.filteredProducts;

                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'No products found',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: AppColors.subColor,
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          itemCount: products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
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
                                      child: Image.network(
                                        product.imageLink,
                                        height: 100.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/images/burger.png",
                                            height: 100.h,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      product.name,
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
                                      product.description ?? 'No description available',
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
                                          "${product.price.toStringAsFixed(0)} \$",
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
                                              _showProductDialog(product);
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
                        );
                      }
                      return Center(child: Text('No data available'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int? selectedVariationOptionIndex;
            int quantity = 1;
            Map<int, int> addonQuantities = {};

            // Initialize addon quantities
            for (var addon in product.addons) {
              addonQuantities[addon.id] = addon.quantityAdd;
            }

            double calculateItemPrice() {
              double basePrice = product.price;

              // Add variation price if selected
              double variationPrice = 0;
              if (selectedVariationOptionIndex != null && product.variations.isNotEmpty) {
                for (var variation in product.variations) {
                  if (variation.options.isNotEmpty &&
                      selectedVariationOptionIndex! < variation.options.length) {
                    variationPrice += variation.options[selectedVariationOptionIndex!].price;
                    break;
                  }
                }
              }

              // Add addons price
              double addonsPrice = 0;
              for (var addon in product.addons) {
                int addonQty = addonQuantities[addon.id] ?? 0;
                addonsPrice += (addon.price * addonQty);
              }

              return (basePrice + variationPrice + addonsPrice) * quantity;
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
                        child: Image.network(
                          product.imageLink,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/burger.png",
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
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
                                Text("${quantity}"),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      product.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                      child: Container(
                                        width: 32.w,
                                        height: 32.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderColor,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 16.sp,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
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

                            // Show variations if available
                            if (product.variations.isNotEmpty) ...[
                              for (var variation in product.variations) ...[
                                Text(
                                  variation.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if (variation.type == 'single') ...[
                                  Wrap(
                                    children: variation.options.map((option) {
                                      int optionIndex = variation.options.indexOf(option);
                                      final isSelected = selectedVariationOptionIndex == optionIndex;
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
                                        child: GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              selectedVariationOptionIndex = isSelected ? null : optionIndex;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primary : AppColors.borderColor,
                                              borderRadius: BorderRadius.circular(6.r),
                                              border: Border.all(
                                                color: isSelected ? AppColors.yellow : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              "${option.name} (+\$${option.price.toStringAsFixed(0)})",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: isSelected ? AppColors.white : AppColors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                              ],
                            ],

                            // Show addons
                            if (product.addons.isNotEmpty) ...[
                              Text(
                                'Add ons',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              ...product.addons.map(
                                    (addon) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40.w,
                                              height: 40.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.borderColor,
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Icon(Icons.fastfood, size: 20.sp),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    addon.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${addon.price.toStringAsFixed(0)}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.sp,
                                                      color: AppColors.subColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.borderColor),
                                          borderRadius: BorderRadius.circular(10.r),
                                          color: AppColors.white,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setDialogState(() {
                                                  if ((addonQuantities[addon.id] ?? 0) > 0) {
                                                    addonQuantities[addon.id] = (addonQuantities[addon.id] ?? 0) - 1;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 32.w,
                                                height: 32.h,
                                                decoration: BoxDecoration(
                                                  color: AppColors.borderColor,
                                                  borderRadius: BorderRadius.circular(4.r),
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
                                              "${addonQuantities[addon.id] ?? 0}",
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
                                                  addonQuantities[addon.id] = (addonQuantities[addon.id] ?? 0) + 1;
                                                });
                                              },
                                              child: Container(
                                                width: 32.w,
                                                height: 32.h,
                                                decoration: BoxDecoration(
                                                  color: AppColors.borderColor,
                                                  borderRadius: BorderRadius.circular(4.r),
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
                              ),
                            ],

                            SizedBox(height: 30.h),
                            CustomElevatedButton(
                              text: "Add To Order",
                              onPressed: () {
                                // Create order details with real product data
                                Map<String, dynamic> orderDetails = {
                                  'productId': product.id,
                                  'title': product.name,
                                  'basePrice': product.price,
                                  'quantity': quantity,
                                  'selectedVariation': selectedVariationOptionIndex != null && product.variations.isNotEmpty
                                      ? {
                                    'variationId': product.variations.first.id,
                                    'optionId': product.variations.first.options[selectedVariationOptionIndex!].id,
                                    'name': product.variations.first.options[selectedVariationOptionIndex!].name,
                                    'price': product.variations.first.options[selectedVariationOptionIndex!].price,
                                  }
                                      : null,
                                  'addons': product.addons.where((addon) => (addonQuantities[addon.id] ?? 0) > 0)
                                      .map((addon) => {
                                    'id': addon.id,
                                    'name': addon.name,
                                    'price': addon.price,
                                    'quantity': addonQuantities[addon.id],
                                  })
                                      .toList(),
                                  'totalPrice': calculateItemPrice(),
                                  'image': product.imageLink,
                                };

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.confirmOrder,
                                  arguments: orderDetails,
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