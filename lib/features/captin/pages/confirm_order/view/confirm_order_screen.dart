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
  int? tableId;

  @override
  void initState() {
    super.initState();
    // Get initial order data from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('📦 ConfirmOrderScreen received arguments: $args');
      if (args != null && args['products'] != null) {
        setState(() {
          tableId = args['table_id']?.toInt() ?? 0;
          final productsList = List<Map<String, dynamic>>.from(args['products']);
          final products = context.read<ProductListCubit>().state is ProductListLoaded
              ? (context.read<ProductListCubit>().state as ProductListLoaded).productResponse.products
              : [];
          print('📋 Products from ProductListCubit: ${products.length} products');
          for (var product in productsList) {
            final productId = product['product_id']?.toInt() ?? 0;
            final productDetails = products.firstWhere(
                  (p) => p.id == productId,
              orElse: () => Product(
                id: productId,
                name: 'Unknown Product',
                categoryId: 0,
                price: 0.0,
                imageLink: '',
                addons: [],
                excludes: [],
                variations: [],
                allExtras: [],
              ),
            );
            print('🖼️ Product $productId - Name: ${productDetails.name}, Image: ${productDetails.imageLink}');
            final newItem = {
              'product_id': productId,
              'count': product['count']?.toInt() ?? 1,
              'amount': product['amount']?.toDouble() ?? 0.0,
              'extras': _buildExtrasString(product, products),
              'note': product['note']?.toString() ?? '',
              'title': productDetails.name ?? 'Unknown Product',
              'image': productDetails.imageLink.isNotEmpty && productDetails.imageLink.startsWith('http')
                  ? productDetails.imageLink
                  : 'assets/images/placeholder.png',
            };
            // Check for duplicates and merge quantities
            final existingIndex = orderItems.indexWhere((item) => item['product_id'] == newItem['product_id']);
            if (existingIndex != -1) {
              orderItems[existingIndex]['count'] = (orderItems[existingIndex]['count'] ?? 1) + (newItem['count']?.toInt() ?? 1);
              orderItems[existingIndex]['amount'] = (orderItems[existingIndex]['amount']?.toDouble() ?? 0.0) + (newItem['amount']?.toDouble() ?? 0.0);
              orderItems[existingIndex]['extras'] = newItem['extras'];
              orderItems[existingIndex]['note'] = newItem['note'];
            } else {
              orderItems.add(newItem);
            }
          }
          calculateTotals();
          print('📦 Updated orderItems: $orderItems');
        });
      } else {
        print('⚠️ No valid arguments or products received in ConfirmOrderScreen');
      }
    });
  }

  String _buildExtrasString(Map<String, dynamic> product, List<dynamic> products) {
    final List<String> extras = [];
    // Add addons
    if (product['addons'] != null && product['addons'] is List) {
      final addonsList = List<Map<String, dynamic>>.from(product['addons']);
      for (var addon in addonsList) {
        final addonId = addon['addon_id']?.toInt() ?? 0;
        final addonCount = addon['count']?.toInt() ?? 0;
        final addonDetails = products
            .expand((p) => p.addons)
            .firstWhere(
              (a) => a.id == addonId,
          orElse: () => Addon(id: addonId, name: 'Unknown Addon', price: 0.0, quantityAdd: 0),
        );
        extras.add('Addon: ${addonDetails.name} x$addonCount');
      }
    }
    // Add excludes
    if (product['exclude_id'] != null && product['exclude_id'] is List) {
      final excludesList = List<dynamic>.from(product['exclude_id']);
      final excludeNames = excludesList
          .map((id) => products
          .expand((p) => p.excludes)
          .firstWhere(
            (e) => e.id == id,
        orElse: () => Exclude(id: id, name: 'Unknown Exclude'),
      )
          .name)
          .join(', ');
      if (excludeNames.isNotEmpty) {
        extras.add('Without: $excludeNames');
      }
    }
    // Add extras
    if (product['extra_id'] != null && product['extra_id'] is List) {
      final extrasList = List<dynamic>.from(product['extra_id']);
      final extraNames = extrasList
          .map((id) => products
          .expand((p) => p.allExtras ?? [])
          .firstWhere(
            (e) => e.id == id,
        orElse: () => Extra(id: id, name: 'Unknown Extra', price: 0.0, productId: 0),
      )
          .name)
          .join(', ');
      if (extraNames.isNotEmpty) {
        extras.add('Extra: $extraNames');
      }
    }
    // Add variations
    if (product['variation'] != null && product['variation'] is List) {
      final variationsList = List<Map<String, dynamic>>.from(product['variation']);
      for (var variation in variationsList) {
        final variationId = variation['variation_id']?.toInt() ?? 0;
        final optionIds = variation['option_id'] != null ? List<dynamic>.from(variation['option_id']) : [];
        final variationDetails = products
            .expand((p) => p.variations)
            .firstWhere(
              (v) => v.id == variationId,
          orElse: () => Variation(id: variationId, name: 'Unknown Variation', type: 'single', required: 0, options: []),
        );
        final optionNames = optionIds
            .map((id) => variationDetails.options
            .firstWhere(
              (o) => o.id == id,
          orElse: () => VariationOption(
            id: id,
            name: 'Unknown Option',
            price: 0.0,
            productId: 0,
            variationId: variationId,
            status: 0,
            points: 0,
          ),
        )
            .name)
            .join(', ');
        if (optionNames.isNotEmpty) {
          extras.add('Variation ${variationDetails.name}: $optionNames');
        }
      }
    }
    // Add note
    if (product['note'] != null && product['note'].toString().isNotEmpty) {
      extras.add('Note: ${product['note']}');
    }
    return extras.isNotEmpty ? extras.join('\n') : 'No extras';
  }

  void updateQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        orderItems[index]['count'] = (orderItems[index]['count'] ?? 1) + 1;
        orderItems[index]['amount'] = (orderItems[index]['amount']?.toDouble() ?? 0.0) / (orderItems[index]['count'] - 1) * orderItems[index]['count'];
      } else {
        if (orderItems[index]['count'] > 1) {
          orderItems[index]['count'] = (orderItems[index]['count'] ?? 1) - 1;
          orderItems[index]['amount'] = (orderItems[index]['amount']?.toDouble() ?? 0.0) / (orderItems[index]['count'] + 1) * orderItems[index]['count'];
        }
      }
      calculateTotals();
      print('📦 Updated orderItems after quantity change: $orderItems');
    });
  }

  void removeItem(int index) {
    setState(() {
      orderItems.removeAt(index);
      calculateTotals();
      print('📦 Updated orderItems after removal: $orderItems');
    });
  }

  void calculateTotals() {
    setState(() {
      subtotal = orderItems.fold(0.0, (sum, item) => sum + (item['amount']?.toDouble() ?? 0.0));
      serviceCharge = 0.0; // Adjust based on your logic
      total = subtotal + serviceCharge;
      print('💰 Subtotal: $subtotal, Service Charge: $serviceCharge, Total: $total');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.subColor),
          onPressed: () {
            // Return current orderItems to TableInOrder
            Navigator.pop(context, {
              'products': orderItems,
              'table_id': tableId,
              'amount': total,
            });
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
              setState(() {
                orderItems.clear();
                calculateTotals();
                print('📦 Cleared all orderItems');
              });
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
              child: Text(
                "No items in the order",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppColors.subColor,
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                print('🖼️ Displaying item ${item['title']} with image: ${item['image']}');
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0.7,
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: item['image'].startsWith('http')
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
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('🖼️ Image load error for ${item['title'] ?? 'Unknown Product'}: $error');
                              return Image.asset(
                                'assets/images/placeholder.png',
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            item['image'] ?? 'assets/images/placeholder.png',
                            width: 60.w,
                            height: 60.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('🖼️ Asset image load error for ${item['title'] ?? 'Unknown Product'}: $error');
                              return Image.asset(
                                'assets/images/placeholder.png',
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              );
                            },
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
                                          onPressed:  () => updateQuantity(index, true),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: GestureDetector(
              onTap: () {
                // Return current orderItems to TableInOrder
                Navigator.pop(context, {
                  'products': orderItems,
                  'table_id': tableId,
                  'amount': total,
                });
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

          // Order Summary
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
                      "Service Charge (15%)",
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
                      "\$${total.toStringAsFixed(2)}",
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
              onPressed: orderItems.isEmpty ? null : () => _confirmOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: orderItems.isEmpty ? AppColors.borderColor : AppColors.primary,
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
                  color: orderItems.isEmpty ? AppColors.subColor : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOrder() async {
    // Show loading dialog
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
      // Get token from SharedPreferences
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null || token.isEmpty) {
        print("⚠️ No token found in SharedPreferences");
        Navigator.of(context).pop(); // Close loading dialog
        ToastMessage.toastMessage('No authentication token found', AppColors.red, AppColors.white);
        return;
      }

      // Prepare order data for API
      final orderData = {
        'table_id': tableId,
        'amount': total,
        'products': orderItems.map((item) => {
          'product_id': item['product_id'],
          'count': item['count'],
          'note': item['note'],
          'addons': item['addons'] ?? [],
          'exclude_id': item['exclude_id'] ?? [],
          'extra_id': item['extra_id'] ?? [],
          'variation': item['variation'] ?? [],
        }).toList(),
      };

      print('📦 Sending order to API: $orderData');

      // Simulate API call (replace with actual API call)
      final response = await DioHelper.postData(
        url: '/captain/orders', // Replace with your actual endpoint
        data: orderData,
        token: token,
      );

      print('📋 API Response: ${response.data}, Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success message
        if (mounted) {
          ToastMessage.toastMessage(
            "Order confirmed successfully!",
            Colors.green,
            AppColors.white,
          );

          // Navigate back to main screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        print("❌ Unexpected server response: Status ${response.statusCode}");
        Navigator.of(context).pop(); // Close loading dialog
        ToastMessage.toastMessage(
          'Failed to confirm order: Unexpected server response',
          AppColors.red,
          AppColors.white,
        );
      }
    } catch (e, stackTrace) {
      print("⚠️ Confirm Order Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      Navigator.of(context).pop(); // Close loading dialog
      ToastMessage.toastMessage(
        'Error confirming order: $e',
        AppColors.red,
        AppColors.white,
      );
    }
  }
}
