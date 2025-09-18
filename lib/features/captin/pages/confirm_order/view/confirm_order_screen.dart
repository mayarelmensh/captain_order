import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/flutter_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_2_go/controller/dio/dio_helper.dart';
import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
import '../../table_in_order/logic/cubit/dine_in_order_cubit.dart';
import '../../table_in_order/logic/cubit/dine_in_order_states.dart';
import '../../table_in_order/logic/model/dine_in_order_model.dart';

class ConfirmOrderScreen extends StatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  List<Map<String, dynamic>> orderItems = [];
  double subtotal = 0.0;
  double serviceCharge = 0.0;
  double total = 0.0;
  double totalTax = 0.0;
  double totalDiscount = 0.0;
  int? tableId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('📦 ConfirmOrderScreen received arguments: $args');

      if (args != null) {
        setState(() {
          tableId = args['table_id']?.toInt() ?? 0;
          // Initialize from args, but will recalculate from items
          totalTax = args['total_tax']?.toDouble() ?? 0.0;
          totalDiscount = args['total_discount']?.toDouble() ?? 0.0;
          total = args['amount']?.toDouble() ?? 0.0;

          if (args['products'] != null) {
            final productsList = List<Map<String, dynamic>>.from(args['products']);
            print('📋 Processing ${productsList.length} products');

            for (var product in productsList) {
              print('📋 Processing product: $product');

              final newItem = {
                'product_id': product['product_id']?.toInt() ?? 0,
                'count': product['count']?.toInt() ?? 1,
                'amount': product['amount']?.toDouble() ?? 0.0,
                'item_tax': product['item_tax']?.toDouble() ?? 0.0,
                'item_discount': product['item_discount']?.toDouble() ?? 0.0,
                'note': product['note']?.toString() ?? '',
                'title': _getProductName(product['product_id']),
                'image': _getProductImage(product['product_id']),
                'extras': _buildExtrasFromProduct(product),
                'addons': product['addons'] ?? [],
                'exclude_id': product['exclude_id'] ?? [],
                'extra_id': product['extra_id'] ?? [],
                'variation': product['variation'] ?? [],
                'original_product': Map<String, dynamic>.from(product), // Deep copy
              };

              orderItems.add(newItem);
              print('📦 Added item: ${newItem['title']} - Amount: ${newItem['amount']}');
            }
          }

          calculateTotals();
          print('📦 Final orderItems: ${orderItems.length} items');
          print('💰 Total amount: \$${total.toStringAsFixed(2)}');
        });
      } else {
        print('⚠️ No valid arguments received in ConfirmOrderScreen');
      }
    });
  }

  String _getProductName(int? productId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        final product = products.firstWhere(
              (p) => p.id == productId,
          orElse: () => Product(
            id: productId ?? 0,
            name: 'Product $productId',
            categoryId: 0,
            price: 0.0,
            imageLink: '',
            addons: [],
            excludes: [],
            variations: [],
            allExtras: [],
          ),
        );
        return product.name ?? 'Unknown Product';
      }
    } catch (e) {
      print('⚠️ Error getting product name: $e');
    }
    return 'Product $productId';
  }

  String _getProductImage(int? productId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        final product = products.firstWhere(
              (p) => p.id == productId,
          orElse: () => Product(
            id: productId ?? 0,
            name: 'Product $productId',
            categoryId: 0,
            price: 0.0,
            imageLink: '',
            addons: [],
            excludes: [],
            variations: [],
            allExtras: [],
          ),
        );
        return product.imageLink.isNotEmpty && product.imageLink.startsWith('http')
            ? product.imageLink
            : 'assets/images/placeholder.png';
      }
    } catch (e) {
      print('⚠️ Error getting product image: $e');
    }
    return 'assets/images/placeholder.png';
  }

  String _buildExtrasFromProduct(Map<String, dynamic> product) {
    final List<String> extras = [];

    try {
      if (product['addons'] != null && product['addons'] is List) {
        final addonsList = List<Map<String, dynamic>>.from(product['addons']);
        for (var addon in addonsList) {
          final addonId = addon['addon_id']?.toInt() ?? 0;
          final addonCount = addon['count']?.toInt() ?? 0;
          if (addonCount > 0) {
            final addonName = _getAddonName(addonId);
            extras.add('Addon: $addonName x$addonCount');
          }
        }
      }

      if (product['variation'] != null && product['variation'] is List) {
        final variationsList = List<Map<String, dynamic>>.from(product['variation']);
        for (var variation in variationsList) {
          final variationId = variation['variation_id']?.toInt() ?? 0;
          final optionIds = variation['option_id'] != null ? List<dynamic>.from(variation['option_id']) : [];
          if (optionIds.isNotEmpty) {
            final variationName = _getVariationName(variationId);
            final optionNames = optionIds.map((id) => _getOptionName(variationId, id)).join(', ');
            extras.add('$variationName: $optionNames');
          }
        }
      }

      if (product['exclude_id'] != null && product['exclude_id'] is List) {
        final excludesList = List<dynamic>.from(product['exclude_id']);
        if (excludesList.isNotEmpty) {
          final excludeNames = excludesList.map((id) => _getExcludeName(id)).join(', ');
          extras.add('Without: $excludeNames');
        }
      }

      if (product['extra_id'] != null && product['extra_id'] is List) {
        final extrasList = List<dynamic>.from(product['extra_id']);
        if (extrasList.isNotEmpty) {
          final extraNames = extrasList.map((id) => _getExtraName(id)).join(', ');
          extras.add('Extra: $extraNames');
        }
      }

      if (product['note'] != null && product['note'].toString().isNotEmpty) {
        extras.add('Note: ${product['note']}');
      }
    } catch (e) {
      print('⚠️ Error building extras: $e');
    }

    return extras.isNotEmpty ? extras.join('\n') : 'No extras';
  }

  String _getAddonName(int addonId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        for (var product in products) {
          final addon = product.addons.firstWhere(
                (a) => a.id == addonId,
            orElse: () => Addon(id: addonId, name: 'Addon $addonId', price: 0.0, quantityAdd: 0),
          );
          if (addon.id == addonId) return addon.name ?? 'Addon $addonId';
        }
      }
    } catch (e) {
      print('⚠️ Error getting addon name: $e');
    }
    return 'Addon $addonId';
  }

  String _getVariationName(int variationId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        for (var product in products) {
          final variation = product.variations.firstWhere(
                (v) => v.id == variationId,
            orElse: () => Variation(id: variationId, name: 'Variation $variationId', type: 'single', required: 0, options: []),
          );
          if (variation.id == variationId) return variation.name ?? 'Variation $variationId';
        }
      }
    } catch (e) {
      print('⚠️ Error getting variation name: $e');
    }
    return 'Variation $variationId';
  }

  String _getOptionName(int variationId, dynamic optionId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        for (var product in products) {
          final variation = product.variations.firstWhere(
                (v) => v.id == variationId,
            orElse: () => Variation(id: variationId, name: 'Variation $variationId', type: 'single', required: 0, options: []),
          );
          if (variation.id == variationId) {
            final option = variation.options.firstWhere(
                  (o) => o.id == optionId,
              orElse: () => VariationOption(
                id: optionId,
                name: 'Option $optionId',
                price: 0.0,
                productId: 0,
                variationId: variationId,
                status: 0,
                points: 0,
              ),
            );
            if (option.id == optionId) return option.name ?? 'Option $optionId';
          }
        }
      }
    } catch (e) {
      print('⚠️ Error getting option name: $e');
    }
    return 'Option $optionId';
  }

  String _getExcludeName(dynamic excludeId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        for (var product in products) {
          final exclude = product.excludes.firstWhere(
                (e) => e.id == excludeId,
            orElse: () => Exclude(id: excludeId, name: 'Exclude $excludeId'),
          );
          if (exclude.id == excludeId) return exclude.name ?? 'Exclude $excludeId';
        }
      }
    } catch (e) {
      print('⚠️ Error getting exclude name: $e');
    }
    return 'Exclude $excludeId';
  }

  String _getExtraName(dynamic extraId) {
    try {
      if (context.read<ProductListCubit>().state is ProductListLoaded) {
        final products = (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products;
        for (var product in products) {
          if (product.allExtras != null) {
            final extra = product.allExtras!.firstWhere(
                  (e) => e.id == extraId,
              orElse: () => Extra(id: extraId, name: 'Extra $extraId', price: 0.0, productId: 0),
            );
            if (extra.id == extraId) return extra.name ?? 'Extra $extraId';
          }
        }
      }
    } catch (e) {
      print('⚠️ Error getting extra name: $e');
    }
    return 'Extra $extraId';
  }

  void updateQuantity(int index, bool increase) {
    setState(() {
      final currentCount = orderItems[index]['count'] ?? 1;
      final unitPrice = (orderItems[index]['amount']?.toDouble() ?? 0.0) / currentCount;
      final unitTax = (orderItems[index]['item_tax']?.toDouble() ?? 0.0) / currentCount;
      final unitDiscount = (orderItems[index]['item_discount']?.toDouble() ?? 0.0) / currentCount;

      if (increase) {
        final newCount = currentCount + 1;
        orderItems[index]['count'] = newCount;
        orderItems[index]['amount'] = unitPrice * newCount;
        orderItems[index]['item_tax'] = unitTax * newCount;
        orderItems[index]['item_discount'] = unitDiscount * newCount;

        // تحديث الـ original product
        orderItems[index]['original_product']['count'] = newCount;
        orderItems[index]['original_product']['amount'] = unitPrice * newCount;
      } else {
        if (currentCount > 1) {
          final newCount = currentCount - 1;
          orderItems[index]['count'] = newCount;
          orderItems[index]['amount'] = unitPrice * newCount;
          orderItems[index]['item_tax'] = unitTax * newCount;
          orderItems[index]['item_discount'] = unitDiscount * newCount;

          // تحديث الـ original product
          orderItems[index]['original_product']['count'] = newCount;
          orderItems[index]['original_product']['amount'] = unitPrice * newCount;
        }
      }
      calculateTotals();
    });
  }

  void removeItem(int index) {
    setState(() {
      totalTax -= orderItems[index]['item_tax']?.toDouble() ?? 0.0;
      totalDiscount -= orderItems[index]['item_discount']?.toDouble() ?? 0.0;
      orderItems.removeAt(index);
      calculateTotals();
    });
  }

  void calculateTotals() {
    setState(() {
      subtotal = orderItems.fold(0.0, (sum, item) => sum + (item['amount']?.toDouble() ?? 0.0));
      totalTax = orderItems.fold(0.0, (sum, item) => sum + (item['item_tax']?.toDouble() ?? 0.0));
      totalDiscount = orderItems.fold(0.0, (sum, item) => sum + (item['item_discount']?.toDouble() ?? 0.0));
      serviceCharge = subtotal * 0.15; // 15% service charge
      total = subtotal + serviceCharge + totalTax - totalDiscount;
      print('💰 Subtotal: $subtotal, Service Charge: $serviceCharge, Tax: $totalTax, Discount: $totalDiscount, Total: $total');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      appBar: AppBar(
        backgroundColor: AppColors.backGround,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.subColor),
          onPressed: () {
            // إرجاع البيانات المحدثة إلى TableInOrder فقط لو فيه أوردرات
            if (orderItems.isNotEmpty) {
              Navigator.pop(context, {
                'products': orderItems.map((item) => item['original_product']).toList(),
                'table_id': tableId,
                'amount': total,
                'total_tax': totalTax,
                'total_discount': totalDiscount,
              });
            } else {
              // إرجاع null أو empty data لو مفيش أوردرات
              Navigator.pop(context, {
                'products': [],
                'table_id': tableId,
                'amount': 0.0,
                'total_tax': 0.0,
                'total_discount': 0.0,
              });
            }
          },
        ),
        title: Text(
          "Table ${tableId ?? 'Unknown'} Order",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.delete, color: AppColors.subColor),
            onPressed: () {
              // إظهار dialog للتأكيد
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Clear All Orders',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to clear all orders? This action cannot be undone.',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: AppColors.subColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // إغلاق الـ dialog
                          setState(() {
                            orderItems.clear();
                            calculateTotals();
                            print('📦 Cleared all orderItems');
                          });
                          // إظهار رسالة تأكيد
                          ToastMessage.toastMessage(
                            'All orders cleared successfully',
                            Colors.green,
                            AppColors.white,
                          );
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Items List
          Expanded(
            child: orderItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80.sp,
                    color: AppColors.subColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No items in the order",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      color: AppColors.subColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Add items from the menu to get started",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.subColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                print('🖼️ Displaying item ${item['title']} with image: ${item['image']}');
                return Card(
                  color: AppColors.backGround,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0.2,
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: item['image'] != null && item['image'].toString().isNotEmpty
                              ? (item['image'].startsWith('http')
                              ? Image.network(
                            item['image'],
                            width: 60.w,
                            height: 60.h,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 60.w,
                                height: 60.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('🖼️ Image error for ${item['title']}: $error');
                              return SizedBox(
                                width: 60.w,
                                height: 60.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          )
                              : Image.asset(
                            item['image'],
                            width: 60.w,
                            height: 60.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('🖼️ Asset image error for ${item['title']}: $error');
                              return SizedBox(
                                width: 60.w,
                                height: 60.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ))
                              : SizedBox(
                            width: 60.w,
                            height: 60.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] ?? 'Unknown Product',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "x${item['count'] ?? 1}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Extras:',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item['extras'] ?? 'No extras',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.sp,
                                  color: AppColors.subColor,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${item['amount']?.toStringAsFixed(2) ?? '0.00'}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Decrease Button
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        radius: 16.r,
                                        child: IconButton(
                                          onPressed: () => updateQuantity(index, false),
                                          icon: Icon(
                                            Icons.remove,
                                            size: 16.sp,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "${item['count'] ?? 1}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      // Increase Button
                                      CircleAvatar(
                                        backgroundColor: AppColors.primary,
                                        radius: 16.r,
                                        child: IconButton(
                                          onPressed: () => updateQuantity(index, true),
                                          icon: Icon(
                                            Icons.add,
                                            size: 16.sp,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      // Delete Button
                                      CircleAvatar(
                                        backgroundColor: AppColors.red.withOpacity(0.2),
                                        radius: 16.r,
                                        child: IconButton(
                                          onPressed: () => removeItem(index),
                                          icon: Icon(
                                            CupertinoIcons.delete,
                                            size: 16.sp,
                                            color: AppColors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add More Items Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 35.h),
            child: GestureDetector(
              onTap: () {
                if (orderItems.isNotEmpty) {
                  Navigator.pop(context, {
                    'products': orderItems.map((item) => item['original_product']).toList(),
                    'table_id': tableId,
                    'amount': total,
                    'total_tax': totalTax,
                    'total_discount': totalDiscount,
                  });
                } else {
                  Navigator.pop(context, {
                    'products': [],
                    'table_id': tableId,
                    'amount': 0.0,
                    'total_tax': 0.0,
                    'total_discount': 0.0,
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Add more items",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Order Summary - فقط لو فيه أوردرات
          if (orderItems.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.subColor,
                        ),
                      ),
                      Text(
                        "\$${subtotal.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Service Charge ",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.subColor,
                        ),
                      ),
                      Text(
                        "\$${serviceCharge.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (totalTax > 0) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tax",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.subColor,
                          ),
                        ),
                        Text(
                          "${totalTax.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (totalDiscount > 0) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.subColor,
                          ),
                        ),
                        Text(
                          "-${totalDiscount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Divider(height: 24.h, color: Colors.grey.shade300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        "${total.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Confirm Order Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              child: ElevatedButton(
                onPressed: () => _confirmOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Confirm Order",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmOrder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(width: 16.w),
                Text(
                  "Confirming order...",
                  style: GoogleFonts.poppins(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null || token.isEmpty) {
        print("⚠️ No token found in SharedPreferences");
        Navigator.of(context).pop();
        ToastMessage.toastMessage('No authentication token found', AppColors.red, AppColors.white);
        return;
      }

      final orderData = {
        'table_id': tableId,
        'amount': total,
        'total_tax': totalTax,
        'total_discount': totalDiscount,
        'products': orderItems.map((item) => Map<String, dynamic>.from(item['original_product'])).toList(),
      };

      print('📦 Sending order to API: $orderData');

      final response = await DioHelper.postData(
        url: '/captain/orders',
        data: orderData,
        token: token,
      );

      print('📋 API Response: ${response.data}, Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
          ToastMessage.toastMessage(
            "Order confirmed successfully!",
            Colors.green,
            AppColors.white,
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        print("❌ Unexpected server response: Status ${response.statusCode}");
        Navigator.of(context).pop();
        ToastMessage.toastMessage(
          'Failed to confirm order: Unexpected server response',
          AppColors.red,
          AppColors.white,
        );
      }
    } catch (e, stackTrace) {
      print("⚠️ Confirm Order Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      Navigator.of(context).pop();
      ToastMessage.toastMessage(
        'Error confirming order: $e',
        AppColors.red,
        AppColors.white,
      );
    }
  }
}