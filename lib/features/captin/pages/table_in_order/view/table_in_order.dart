import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/core/utils/flutter_toast.dart';
import 'package:food_2_go/custom_widgets/custom_elevated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../auth/login/logic/cubit/login_cubit.dart';
import '../../../../auth/login/logic/cubit/login_states.dart';
import '../logic/cubit/dine_in_order_cubit.dart';
import '../logic/cubit/dine_in_order_states.dart';
import '../logic/model/dine_in_order_model.dart';

class TableInOrder extends StatefulWidget {
  TableInOrder({super.key});

  @override
  State<TableInOrder> createState() => _TableInOrderState();
}

class _TableInOrderState extends State<TableInOrder> {
  String? tableNumber;
  String? area;
  int? tableId;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  double totalTax = 0.0;
  double totalDiscount = 0.0;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Variables for category/subcategory selection
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  String selectedFilterType = 'category'; // 'category', 'subcategory'
  bool _initialCategorySelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTableData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTableData();
  }

  void _loadTableData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        tableId = args['id'] as int?;
        tableNumber = args['number'] as String?;
        area = args['area'] as String?;
        if (args['products'] != null && args['products'] is List) {
          final existingProducts = List<Map<String, dynamic>>.from(
            args['products'],
          );
          if (existingProducts.isNotEmpty) {
            cartItems.clear();
            cartItems.addAll(existingProducts);
            totalTax = (args['total_tax'] as num?)?.toDouble() ?? 0.0;
            totalDiscount = (args['total_discount'] as num?)?.toDouble() ?? 0.0;
            calculateTotal();
            print("🟢 Loaded existing products: ${cartItems.length}");
          } else {
            cartItems.clear();
            totalTax = 0.0;
            totalDiscount = 0.0;
            totalAmount = 0.0;
            print("🟡 Products list is empty, cleared all data");
          }
        }
      });
      print(
        "🟢 TableInOrder args => id: $tableId, number: $tableNumber, area: $area",
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void calculateTotal() {
    totalAmount = cartItems.fold(
      0.0,
      (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
    );
    setState(() {});
    print(
      "💰 Updated Total Amount: $totalAmount, Tax: $totalTax, Discount: $totalDiscount",
    );
  }

  void _onSearchChanged(String query, BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      print("🔍 UI Search query sent: '$query'");
      context.read<ProductListCubit>().searchProducts(query);
    });
  }

  void _selectCategory(int categoryId) {
    print(
      "🔄 _selectCategory called for ID: $categoryId (selectedCategoryId: $selectedCategoryId)",
    );
    setState(() {
      selectedCategoryId = categoryId;
      selectedSubCategoryId = null;
      selectedFilterType = 'category';
    });
    context.read<ProductListCubit>().filterProductsByCategory(categoryId);
    print("🟢 Selected category: $categoryId");
  }

  void _selectSubCategory(int subCategoryId) {
    setState(() {
      selectedSubCategoryId = subCategoryId;
      selectedFilterType = 'subcategory';
    });
    context.read<ProductListCubit>().filterProductsBySubCategory(subCategoryId);
  }

  List<Product> _getFilteredProducts(ProductListState state) {
    if (state is ProductListLoaded) {
      if (searchController.text.isNotEmpty) {
        return state.filteredProducts;
      }

      if (selectedFilterType == 'category' && selectedCategoryId != null) {
        return state.productResponse.products
            .where((product) => product.categoryId == selectedCategoryId)
            .toList();
      } else if (selectedFilterType == 'subcategory' &&
          selectedSubCategoryId != null) {
        return state.productResponse.products
            .where((product) => product.subCategoryId == selectedSubCategoryId)
            .toList();
      }
    }
    return [];
  }

  void _goToConfirmOrder() async {
    if (cartItems.isEmpty) {
      ToastMessage.toastMessage(
        'Please add items to your order first',
        AppColors.primary,
        AppColors.white,
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.confirmOrder,
      arguments: {
        'table_id': tableId,
        'amount': totalAmount,
        'total_tax': totalTax,
        'total_discount': totalDiscount,
        'products': cartItems,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final products = result['products'] as List<dynamic>? ?? [];
        if (products.isEmpty) {
          cartItems.clear();
          totalAmount = 0.0;
          totalTax = 0.0;
          totalDiscount = 0.0;
          print("🗑️ All orders cleared from ConfirmOrderScreen");
        } else {
          cartItems = List<Map<String, dynamic>>.from(products);
          totalAmount = (result['amount'] as num?)?.toDouble() ?? 0.0;
          totalTax = (result['total_tax'] as num?)?.toDouble() ?? 0.0;
          totalDiscount = (result['total_discount'] as num?)?.toDouble() ?? 0.0;
          print(
            "🔄 Orders updated from ConfirmOrderScreen: ${cartItems.length} items",
          );
        }
        calculateTotal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductListCubit()..getProductLists(),
      child: BlocListener<ProductListCubit, ProductListState>(
        listener: (context, state) {
          if (state is ProductListLoaded &&
              state.productResponse.categories.isNotEmpty &&
              !_initialCategorySelected) {
            final firstCategory = state.productResponse.categories
                .where((cat) => cat.active == 1)
                .first;
            _selectCategory(firstCategory.id!);
            _initialCategorySelected = true;
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with table info
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
                                  text: tableId != null
                                      ? "Table $tableId"
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

                  // Captain info and order type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final loginCubit = context.read<LoginCubit>();
                          return Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    loginCubit.captainImageLink != null
                                    ? NetworkImage(loginCubit.captainImageLink!)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                                child: loginCubit.captainImageLink != null
                                    ? ClipOval(
                                        child: Image.network(
                                          loginCubit.captainImageLink!,
                                          fit: BoxFit.cover,
                                          width: 40.w,
                                          height: 40.h,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            print(
                                              "🖼️ Captain image error: $error",
                                            );
                                            return Image.asset(
                                              'assets/images/default_avatar.png',
                                              fit: BoxFit.cover,
                                              width: 40.w,
                                              height: 40.h,
                                            );
                                          },
                                        ),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 10.w),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "Captain order ${loginCubit.captainId ?? '1'}\n",
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        color: AppColors.subColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          loginCubit.captainName ??
                                          "Refaat Alaa",
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

                  // Title
                  Text(
                    "What's the order\n for this table?",
                    style: GoogleFonts.poppins(
                      fontSize: 25.sp,
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Search bar
                  Builder(
                    builder: (context) {
                      return TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search for food or drink",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.subColor,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.subColor,
                          ),
                          filled: true,
                          fillColor: AppColors.borderColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (query) => _onSearchChanged(query, context),
                      );
                    },
                  ),
                  SizedBox(height: 15.h),

                  // Categories and Subcategories List
                  BlocBuilder<ProductListCubit, ProductListState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state is ProductListLoaded) {
                        final categories = state.productResponse.categories
                            .where((cat) => cat.active == 1)
                            .toList();

                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categories row
                              Container(
                                height: 40.h,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: categories.map((category) {
                                    final isSelected =
                                        selectedCategoryId == category.id;
                                    return GestureDetector(
                                      onTap: () =>
                                          _selectCategory(category.id!),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10.w),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.borderColor,
                                          borderRadius: BorderRadius.circular(
                                            25.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipOval(
                                              child: Image.network(
                                                category.imageLink ?? "",
                                                width: 20.w,
                                                height: 20.h,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.fastfood,
                                                        size: 20.sp,
                                                        color: isSelected
                                                            ? AppColors.white
                                                            : AppColors
                                                                  .subColor,
                                                      );
                                                    },
                                              ),
                                            ),
                                            SizedBox(width: 7.w),
                                            Text(
                                              category.name,
                                              style: GoogleFonts.inter(
                                                color: isSelected
                                                    ? AppColors.white
                                                    : AppColors.subColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              // Subcategories row (only show if category is selected and has subcategories)
                              if (selectedCategoryId != null)
                                Builder(
                                  builder: (context) {
                                    final selectedCategory = categories
                                        .firstWhere(
                                          (cat) => cat.id == selectedCategoryId,
                                          orElse: () => categories.first,
                                        );
                                    final subCategories =
                                        selectedCategory.subCategories.toList()
                                          ..sort(
                                            (a, b) => (a.priority ?? 0)
                                                .compareTo(b.priority ?? 0),
                                          );

                                    if (subCategories.isEmpty) {
                                      return SizedBox(
                                        height: 0,
                                      ); // No space if no subcategories
                                    }

                                    return Container(
                                      height: 40.h,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: subCategories.map((
                                          subCategory,
                                        ) {
                                          final isSelected =
                                              selectedSubCategoryId ==
                                              subCategory.id;
                                          return GestureDetector(
                                            onTap: () => _selectSubCategory(
                                              subCategory.id!,
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                right: 10.w,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.borderColor
                                                          .withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ClipOval(
                                                    child: Image.network(
                                                      subCategory.imageLink ??
                                                          "",
                                                      width: 16.w,
                                                      height: 16.h,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Icon(
                                                              Icons.category,
                                                              size: 16.sp,
                                                              color: isSelected
                                                                  ? AppColors
                                                                        .white
                                                                  : AppColors
                                                                        .subColor,
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  Text(
                                                    subCategory.name,
                                                    style: GoogleFonts.inter(
                                                      color: isSelected
                                                          ? AppColors.white
                                                          : AppColors.subColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 11.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      }
                      return Container(height: 0.h);
                    },
                  ),

                  // Selected category/subcategory title
                  BlocBuilder<ProductListCubit, ProductListState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state is ProductListLoaded) {
                        String title = 'Select a Category';
                        if (selectedSubCategoryId != null) {
                          final categories = state.productResponse.categories;
                          final category = categories.firstWhere(
                            (cat) => cat.subCategories.any(
                              (sub) => sub.id == selectedSubCategoryId,
                            ),
                            orElse: () => categories.first,
                          );
                          final subCategory = category.subCategories.firstWhere(
                            (sub) => sub.id == selectedSubCategoryId,
                            orElse: () => category.subCategories.first,
                          );
                          title = subCategory.name;
                        } else if (selectedCategoryId != null) {
                          final category = state.productResponse.categories
                              .firstWhere(
                                (cat) => cat.id == selectedCategoryId,
                                orElse: () =>
                                    state.productResponse.categories.first,
                              );
                          title = category.name;
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  // Products grid
                  Expanded(
                    child: BlocBuilder<ProductListCubit, ProductListState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        print(
                          "📋 Building products grid, state: ${state.runtimeType}",
                        );

                        if (state is ProductListLoading) {
                          print("📋 Showing loading indicator");
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is ProductListError) {
                          print("❌ ProductListError: ${state.message}");
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error:something went wrong,please try again',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  onPressed: () {
                                    print("🔄 Refreshing product list");
                                    context.read<ProductListCubit>().refresh();
                                  },
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        } else if (state is ProductListLoaded) {
                          final products = _getFilteredProducts(state);
                          print("📦 Rendering ${products.length} products");

                          if (products.isEmpty) {
                            print("⚠️ No products found for current filter");
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    searchController.text.isNotEmpty
                                        ? 'No matching products found for "${searchController.text}"'
                                        : 'No products available in this selection',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      color: AppColors.subColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            key: ValueKey(
                              '${selectedFilterType}_${selectedCategoryId}_${selectedSubCategoryId}_${products.length}_${searchController.text}',
                            ),
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 600
                                      ? 3
                                      : 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              print(
                                "📋 Building product card: ${product.name}",
                              );
                              return Card(
                                color: AppColors.backGround,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: AppColors.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 0.1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        child: Image.network(
                                          product.imageLink ?? "",
                                          height: 100.h,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                print(
                                                  "🖼️ Image error for ${product.name}: $error",
                                                );
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
                                        product.name ?? 'Unnamed Product',
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
                                        product.description ??
                                            'No description available',
                                        style: GoogleFonts.poppins(
                                          fontSize: 8.sp,
                                          color: AppColors.subColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${(product.priceAfterDiscount ?? product.price ?? 0.0).toStringAsFixed(0)} EGP ",
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
                                                print(
                                                  "➕ Opening dialog for ${product.name}",
                                                );
                                                _showProductDialog(
                                                  context,
                                                  product,
                                                );
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
                        print(
                          "⚠️ No data available, state: ${state.runtimeType}",
                        );
                        return Center(child: Text('No data available'));
                      },
                    ),
                  ),

                  // Cart summary and order button
                  if (cartItems.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 10.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${cartItems.length} item${cartItems.length > 1 ? 's' : ''} in order',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Total: ${totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _goToConfirmOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                            child: Text(
                              'View Order',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext parentContext, Product product) {
    int quantity = 1;
    Map<int, int> addonQuantities = {};
    Map<int, int> selectedSingleVariations = {};
    Map<int, List<int>> selectedMultipleVariations = {};
    Set<int> selectedExcludes = {};
    Set<int> selectedExtras = {};
    TextEditingController noteController = TextEditingController();

    for (var addon in product.addons) {
      addonQuantities[addon.id ?? 0] = addon.quantityAdd ?? 0;
    }

    for (var variation in product.variations) {
      if (variation.type == 'single') {
        selectedSingleVariations[variation.id ?? 0] = -1;
      } else if (variation.type == 'multiple') {
        selectedMultipleVariations[variation.id ?? 0] = [];
      }
    }

    if (product.allExtras != null) {
      for (var extra in product.allExtras!) {
        selectedExtras.add(extra.id ?? 0);
      }
    }

    Map<String, double> calculateItemPrice() {
      double basePrice = (product.priceAfterDiscount ?? product.price ?? 0.0)
          .toDouble();
      double baseTax = (0.0).toDouble();
      double baseDiscount = (0.0).toDouble();
      double variationPrice = 0.0;
      double variationTax = 0.0;
      double addonsPrice = 0.0;
      double addonsTax = 0.0;
      double addonsDiscount = 0.0;
      double extrasPrice = 0.0;
      double extrasTax = 0.0;
      double extrasDiscount = 0.0;

      for (var variation in product.variations) {
        if (variation.type == 'single' &&
            selectedSingleVariations[variation.id ?? 0] != null &&
            selectedSingleVariations[variation.id ?? 0]! >= 0) {
          if (selectedSingleVariations[variation.id ?? 0]! <
              variation.options.length) {
            variationPrice +=
                (variation
                    .options[selectedSingleVariations[variation.id ?? 0]!]
                    .price ??
                0.0);
          }
        } else if (variation.type == 'multiple') {
          final selectedOpts =
              selectedMultipleVariations[variation.id ?? 0] ?? [];
          for (var optIndex in selectedOpts) {
            if (optIndex < variation.options.length) {
              variationPrice += (variation.options[optIndex].price ?? 0.0);
            }
          }
        }
      }

      for (var addon in product.addons) {
        int addonQty = addonQuantities[addon.id ?? 0] ?? 0;
        addonsPrice += (addon.price ?? 0.0) * addonQty;
        addonsTax += (addon.taxVal ?? 0.0) * addonQty;
        addonsDiscount += (addon.discountVal ?? 0.0) * addonQty;
      }

      if (product.allExtras != null) {
        for (var extra in product.allExtras!) {
          if (selectedExtras.contains(extra.id ?? 0)) {
            extrasPrice += (extra.price ?? 0.0);
          }
        }
      }

      double unitPriceBeforeTax =
          basePrice + variationPrice + addonsPrice + extrasPrice;
      double unitTax = baseTax + variationTax + addonsTax + extrasTax;
      double unitDiscount = baseDiscount + addonsDiscount + extrasDiscount;

      double totalPrice = unitPriceBeforeTax * quantity;
      double totalTaxAmount = unitTax * quantity;
      double totalDiscountAmount = unitDiscount * quantity;

      print(
        "💰 Price Calculation: Base: $basePrice, Var: $variationPrice, Addons: $addonsPrice, Extras: $extrasPrice, Qty: $quantity, Total: $totalPrice, Tax: $totalTaxAmount, Disc: $totalDiscountAmount",
      );

      return {
        'totalPrice': totalPrice,
        'totalTax': totalTaxAmount,
        'totalDiscount': totalDiscountAmount,
      };
    }

    showDialog(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            print("📦 Product Dialog: ${product.name ?? 'Unnamed Product'}");
            print("📋 Variations: ${product.variations.length}");
            for (var variation in product.variations) {
              print(
                "  - ${variation.name} (Type: ${variation.type}, Max: ${variation.max}, Min: ${variation.min}, Required: ${variation.required})",
              );
              for (var option in variation.options) {
                print("    - Option: ${option.name}, Price: ${option.price}");
              }
            }
            print("📋 Addons: ${product.addons.length}");
            for (var addon in product.addons) {
              print(
                "  - Addon: ${addon.name}, Price: ${addon.price}, Quantity: ${addonQuantities[addon.id]}, TaxVal: ${addon.taxVal}, DiscountVal: ${addon.discountVal}",
              );
            }
            print("📋 Excludes: ${product.excludes.length}");
            for (var exclude in product.excludes) {
              print("  - Exclude: ${exclude.name}, ID: ${exclude.id}");
            }
            print("📋 Extras: ${product.allExtras?.length ?? 0}");
            if (product.allExtras != null) {
              for (var extra in product.allExtras!) {
                print(
                  "  - Extra: ${extra.name}, ID: ${extra.id}, Price: ${extra.price}",
                );
              }
            }

            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.r),
                        ),
                        child: Image.network(
                          product.imageLink ?? "",
                          height: 200.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              "🖼️ Dialog image error for ${product.name ?? 'Unnamed Product'}: $error",
                            );
                            return Image.asset(
                              "assets/images/placeholder.png",
                              height: 200.h,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$quantity",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      product.name ?? 'Unnamed Product',
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
                                        print(
                                          "➖ Decrement quantity: $quantity",
                                        );
                                        setDialogState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                      child: Container(
                                        width: 32.w,
                                        height: 32.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderColor,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
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
                                        print(
                                          "➕ Increment quantity: $quantity",
                                        );
                                        setDialogState(() {
                                          quantity++;
                                        });
                                      },
                                      child: Container(
                                        width: 32.w,
                                        height: 32.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
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
                              "${calculateItemPrice()['totalPrice']!.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Description:',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              product.description ?? 'No description available',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: AppColors.subColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
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
                                if (variation.required == 1 ||
                                    (variation.min != null &&
                                        variation.min! > 0)) ...[
                                  Text(
                                    'Required: Select at least ${variation.min ?? 1} option${(variation.min ?? 1) > 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                                if (variation.max != null &&
                                    variation.max! > 0) ...[
                                  Text(
                                    'Maximum: ${variation.max} option${variation.max! > 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: AppColors.subColor,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 8.h),
                                if (variation.type == 'single') ...[
                                  Wrap(
                                    key: ValueKey('variation_${variation.id}'),
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: variation.options.asMap().entries.map((
                                      entry,
                                    ) {
                                      int optionIndex = entry.key;
                                      var option = entry.value;
                                      final isSelected =
                                          selectedSingleVariations[variation
                                                  .id ??
                                              0] ==
                                          optionIndex;
                                      return GestureDetector(
                                        onTap: () {
                                          print(
                                            "📍 Single variation tapped: ${option.name}, Index: $optionIndex, IsSelected: $isSelected",
                                          );
                                          setDialogState(() {
                                            selectedSingleVariations[variation
                                                    .id ??
                                                0] = isSelected
                                                ? -1
                                                : optionIndex;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.borderColor,
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.yellow
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Text(
                                            "${option.name} (+${(option.price ?? 0.0).toStringAsFixed(0)})",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : AppColors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ] else if (variation.type == 'multiple') ...[
                                  Column(
                                    key: ValueKey('variation_${variation.id}'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: variation.options.asMap().entries.map((
                                      entry,
                                    ) {
                                      int optionIndex = entry.key;
                                      var option = entry.value;
                                      final isSelected =
                                          (selectedMultipleVariations[variation
                                                          .id ??
                                                      0] ??
                                                  [])
                                              .contains(optionIndex);
                                      return CheckboxListTile(
                                        key: ValueKey(
                                          'option_${variation.id}_$optionIndex',
                                        ),
                                        title: Text(
                                          "${option.name} (+${(option.price ?? 0.0).toStringAsFixed(0)})",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          print(
                                            "📍 Multiple variation ${option.name}: $value",
                                          );
                                          setDialogState(() {
                                            var selected =
                                                selectedMultipleVariations[variation
                                                        .id ??
                                                    0] ??
                                                [];
                                            if (value == true) {
                                              if (selected.length <
                                                  (variation.max ?? 999)) {
                                                selected.add(optionIndex);
                                              } else {
                                                print(
                                                  "⚠️ Max selections reached for ${variation.name}: ${variation.max}",
                                                );
                                                ToastMessage.toastMessage(
                                                  'Maximum quantity reached for ${variation.name} (${variation.max})',
                                                  AppColors.primary,
                                                  AppColors.white,
                                                );
                                              }
                                            } else {
                                              selected.remove(optionIndex);
                                            }
                                            selectedMultipleVariations[variation
                                                        .id ??
                                                    0] =
                                                selected;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                              ],
                            ],
                            if (product.addons.isNotEmpty) ...[
                              Text(
                                'Add ons',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ...product.addons.asMap().entries.map((entry) {
                                int index = entry.key;
                                var addon = entry.value;
                                return Padding(
                                  key: ValueKey('addon_${addon.id}_$index'),
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40.w,
                                              height: 40.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.borderColor,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Icon(
                                                Icons.fastfood,
                                                size: 20.sp,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    addon.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${(addon.price ?? 0.0).toStringAsFixed(0)}",
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
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          color: AppColors.white,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                  "➖ Decrement addon ${addon.name}: ${addonQuantities[addon.id]}",
                                                );
                                                setDialogState(() {
                                                  if ((addonQuantities[addon
                                                                  .id ??
                                                              0] ??
                                                          0) >
                                                      0) {
                                                    addonQuantities[addon.id ??
                                                            0] =
                                                        (addonQuantities[addon
                                                                    .id ??
                                                                0] ??
                                                            0) -
                                                        1;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 32.w,
                                                height: 32.h,
                                                decoration: BoxDecoration(
                                                  color: AppColors.borderColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
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
                                              "${addonQuantities[addon.id ?? 0] ?? 0}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                  "➕ Increment addon ${addon.name}: ${addonQuantities[addon.id]}",
                                                );
                                                setDialogState(() {
                                                  int currentQuantity =
                                                      addonQuantities[addon
                                                              .id ??
                                                          0] ??
                                                      0;
                                                  int maxAllowed =
                                                      (addon.quantityAdd ??
                                                              0) ==
                                                          0
                                                      ? 1
                                                      : 999;
                                                  if (currentQuantity <
                                                      maxAllowed) {
                                                    addonQuantities[addon.id ??
                                                            0] =
                                                        currentQuantity + 1;
                                                  } else {
                                                    print(
                                                      "⚠️ Max quantity reached for ${addon.name}: $maxAllowed",
                                                    );
                                                    ToastMessage.toastMessage(
                                                      'Maximum quantity reached for ${addon.name} ($maxAllowed)',
                                                      AppColors.primary,
                                                      AppColors.white,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 32.w,
                                                height: 32.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      addonQuantities[addon
                                                                      .id ??
                                                                  0] !=
                                                              null &&
                                                          addonQuantities[addon
                                                                      .id ??
                                                                  0]! >=
                                                              ((addon.quantityAdd ??
                                                                          0) ==
                                                                      0
                                                                  ? 1
                                                                  : 999)
                                                      ? AppColors.borderColor
                                                            .withOpacity(0.5)
                                                      : AppColors.borderColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 16.sp,
                                                  color:
                                                      addonQuantities[addon
                                                                      .id ??
                                                                  0] !=
                                                              null &&
                                                          addonQuantities[addon
                                                                      .id ??
                                                                  0]! >=
                                                              ((addon.quantityAdd ??
                                                                          0) ==
                                                                      0
                                                                  ? 1
                                                                  : 999)
                                                      ? AppColors.subColor
                                                      : AppColors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (product.excludes.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              Text(
                                'Excludes',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              Column(
                                children: product.excludes.map((exclude) {
                                  final isSelected = selectedExcludes.contains(
                                    exclude.id,
                                  );
                                  return CheckboxListTile(
                                    key: ValueKey('exclude_${exclude.id}'),
                                    title: Text(
                                      exclude.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      print(
                                        "📍 Exclude ${exclude.name}: $value",
                                      );
                                      setDialogState(() {
                                        if (value == true) {
                                          selectedExcludes.add(exclude.id ?? 0);
                                        } else {
                                          selectedExcludes.remove(
                                            exclude.id ?? 0,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                            if (product.allExtras != null &&
                                product.allExtras!.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              Text(
                                'Extras',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              Column(
                                children: product.allExtras!.map((extra) {
                                  final isSelected = selectedExtras.contains(
                                    extra.id,
                                  );
                                  return CheckboxListTile(
                                    key: ValueKey('extra_${extra.id}'),
                                    title: Text(
                                      "${extra.name} (+${(extra.price ?? 0.0).toStringAsFixed(0)})",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      print("📍 Extra ${extra.name}: $value");
                                      setDialogState(() {
                                        if (value == true) {
                                          selectedExtras.add(extra.id ?? 0);
                                        } else {
                                          selectedExtras.remove(extra.id ?? 0);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                            SizedBox(height: 12.h),
                            Text(
                              'Notes',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: noteController,
                              decoration: InputDecoration(
                                hintText: "Add any special requests...",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: AppColors.subColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: 30.h),
                            CustomElevatedButton(
                              text: "Add To Order",
                              onPressed: () {
                                bool isValid = true;
                                for (var variation in product.variations) {
                                  if (variation.required == 1 ||
                                      (variation.min != null &&
                                          variation.min! > 0)) {
                                    if (variation.type == 'single' &&
                                        selectedSingleVariations[variation.id ??
                                                0] ==
                                            -1) {
                                      isValid = false;
                                      print(
                                        "⚠️ Validation failed: ${variation.name} is required",
                                      );
                                      ToastMessage.toastMessage(
                                        "Please select an option for ${variation.name}",
                                        AppColors.red,
                                        AppColors.white,
                                      );
                                    } else if (variation.type == 'multiple') {
                                      final selectedCount =
                                          (selectedMultipleVariations[variation
                                                          .id ??
                                                      0] ??
                                                  [])
                                              .length;
                                      final minRequired = variation.min ?? 1;
                                      if (selectedCount < minRequired) {
                                        isValid = false;
                                        print(
                                          "⚠️ Validation failed: Select at least $minRequired option${minRequired > 1 ? 's' : ''} for ${variation.name}",
                                        );
                                        ToastMessage.toastMessage(
                                          "Please select at least $minRequired option${minRequired > 1 ? 's' : ''} for ${variation.name}",
                                          AppColors.red,
                                          AppColors.white,
                                        );
                                        // ScaffoldMessenger.of(
                                        //   parentContext,
                                        // ).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //       "Please select at least $minRequired option${minRequired > 1 ? 's' : ''} for ${variation.name}",
                                        //     ),
                                        //     behavior: SnackBarBehavior.floating,
                                        //   ),
                                        // );
                                      }
                                    }
                                  }
                                }

                                // في نهاية ملف table_in_order.dart
// استبدل الجزء ده في دالة _showProductDialog عند الضغط على "Add To Order"

                                if (isValid) {
                                  final prices = calculateItemPrice();

                                  // تجهيز البيانات الأساسية
                                  Map<String, dynamic> newProduct = {
                                    'product_id': product.id,
                                    'count': quantity,
                                    'amount': prices['totalPrice'] ?? 0.0,
                                    'item_tax': prices['totalTax'] ?? 0.0,
                                    'item_discount': prices['totalDiscount'] ?? 0.0,
                                    'image': product.imageLink?.isNotEmpty == true &&
                                        product.imageLink!.startsWith('http')
                                        ? product.imageLink
                                        : 'assets/images/placeholder.png',
                                  };

                                  // إضافة الـ note فقط لو موجود ومش فاضي
                                  if (noteController.text.trim().isNotEmpty) {
                                    newProduct['note'] = noteController.text.trim();
                                  }

                                  // إضافة الـ addons فقط لو فيه addons متختارة
                                  final selectedAddons = product.addons
                                      .where((addon) => (addonQuantities[addon.id ?? 0] ?? 0) > 0)
                                      .map((addon) => {
                                    'addon_id': addon.id,
                                    'count': addonQuantities[addon.id ?? 0],
                                    'amount': (addon.price ?? 0.0) *
                                        (addonQuantities[addon.id ?? 0] ?? 0),
                                    'item_tax': (addon.taxVal ?? 0.0) *
                                        (addonQuantities[addon.id ?? 0] ?? 0),
                                    'item_discount': (addon.discountVal ?? 0.0) *
                                        (addonQuantities[addon.id ?? 0] ?? 0),
                                  })
                                      .toList();

                                  if (selectedAddons.isNotEmpty) {
                                    newProduct['addons'] = selectedAddons;
                                  }

                                  // إضافة الـ exclude_id فقط لو فيه excludes متختارة
                                  if (selectedExcludes.isNotEmpty) {
                                    newProduct['exclude_id'] = selectedExcludes.toList();
                                  }

                                  // إضافة الـ extra_id فقط لو فيه extras متختارة
                                  if (selectedExtras.isNotEmpty) {
                                    newProduct['extra_id'] = selectedExtras.toList();
                                  }

                                  // إضافة الـ variation فقط لو فيه variations متختارة
                                  final selectedVariations = product.variations
                                      .map((variation) {
                                    List<dynamic> optionIds = [];

                                    if (variation.type == 'single') {
                                      // Single variation - check if selected
                                      if (selectedSingleVariations[variation.id ?? 0] != null &&
                                          selectedSingleVariations[variation.id ?? 0]! >= 0) {
                                        optionIds = [
                                          variation.options[selectedSingleVariations[variation.id ?? 0]!].id
                                        ];
                                      }
                                    } else if (variation.type == 'multiple') {
                                      // Multiple variation - get all selected options
                                      final selectedIndices = selectedMultipleVariations[variation.id ?? 0] ?? [];
                                      optionIds = selectedIndices
                                          .map((index) => variation.options[index].id)
                                          .toList();
                                    }

                                    // بس نرجع الـ variation لو فيه options متختارة
                                    if (optionIds.isNotEmpty) {
                                      return {
                                        'variation_id': variation.id,
                                        'option_id': optionIds,
                                      };
                                    }
                                    return null;
                                  })
                                      .where((v) => v != null) // إزالة الـ null values
                                      .toList();

                                  if (selectedVariations.isNotEmpty) {
                                    newProduct['variation'] = selectedVariations;
                                  }

                                  setState(() {
                                    cartItems.add(newProduct);
                                    totalTax += prices['totalTax'] ?? 0.0;
                                    totalDiscount += prices['totalDiscount'] ?? 0.0;
                                    calculateTotal();
                                  });

                                  Navigator.of(context).pop();

                                  ToastMessage.toastMessage(
                                    "${product.name} added to order!",
                                    Colors.green,
                                    AppColors.white,
                                  );

                                  print("📦 Product added to cart (cleaned data):");
                                  print("   Product ID: ${newProduct['product_id']}");
                                  print("   Count: ${newProduct['count']}");
                                  print("   Amount: ${newProduct['amount']}");
                                  print("   Has addons: ${newProduct.containsKey('addons')}");
                                  print("   Has excludes: ${newProduct.containsKey('exclude_id')}");
                                  print("   Has extras: ${newProduct.containsKey('extra_id')}");
                                  print("   Has variations: ${newProduct.containsKey('variation')}");
                                  print("   Has note: ${newProduct.containsKey('note')}");
                                  print("   Full data: $newProduct");
                                }
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
