// confirm_order_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/flutter_toast.dart';
import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
import 'package:food_2_go/features/captin/pages/confirm_order/logic/model/product_model.dart';
import '../../../../../../controller/dio/dio_helper.dart';
import 'confirm_order_states.dart';

class ConfirmOrderCubit extends Cubit<ConfirmOrderState> {
  ConfirmOrderCubit() : super(ConfirmOrderInitial());

  Future<void> confirmOrder({
    required int tableId,
    required double amount,
    required double totalTax,
    required double totalDiscount,
    required List<Map<String, dynamic>> products,
  }) async {
    emit(ConfirmOrderLoading());

    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null || token.isEmpty) {
        print("⚠️ No token found in SharedPreferences");
        emit(ConfirmOrderError('No authentication token found'));
        ToastMessage.toastMessage(
          'No authentication token found',
          AppColors.red,
          AppColors.white,
        );
        return;
      }

      print("📦 Starting to send ${products.length} products individually");

      // قائمة لتخزين الـ responses الناجحة
      List<dynamic> allSuccessProducts = [];
      int successCount = 0;
      int failedCount = 0;

      // إرسال كل product لوحده
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        print("📤 Sending product ${i + 1}/${products.length}: ID ${product['product_id']}");

        try {
          // تنظيف بيانات الـ product
          final productMap = <String, dynamic>{
            'product_id': product['product_id']?.toInt() ?? 0,
            'count': product['count'] is String
                ? int.parse(product['count'])
                : (product['count'] as int? ?? 1),
          };

          // إضافة الـ note فقط لو موجود
          if (product['note'] != null && product['note'].toString().trim().isNotEmpty) {
            productMap['note'] = product['note'].toString().trim();
          }

          // إضافة الـ addons فقط لو موجود
          if (product['addons'] != null && product['addons'] is List) {
            final addonsList = (product['addons'] as List)
                .where((addon) => addon != null && addon['addon_id'] != null)
                .map((addon) => {
              'addon_id': addon['addon_id']?.toInt() ?? 0,
              'count': addon['count'] is String
                  ? int.parse(addon['count'])
                  : (addon['count'] as int? ?? 1),
            })
                .toList();

            if (addonsList.isNotEmpty) {
              productMap['addons'] = addonsList;
            }
          }

          // إضافة الـ exclude_id فقط لو موجود
          if (product['exclude_id'] != null && product['exclude_id'] is List) {
            final excludeList = (product['exclude_id'] as List)
                .where((id) => id != null)
                .map((id) => id?.toInt() ?? 0)
                .toList();

            if (excludeList.isNotEmpty) {
              productMap['exclude_id'] = excludeList;
            }
          }

          // إضافة الـ extra_id فقط لو موجود
          if (product['extra_id'] != null && product['extra_id'] is List) {
            final extraList = (product['extra_id'] as List)
                .where((id) => id != null)
                .map((id) => id?.toInt() ?? 0)
                .toList();

            if (extraList.isNotEmpty) {
              productMap['extra_id'] = extraList;
            }
          }

          // إضافة الـ variation فقط لو موجود
          if (product['variation'] != null && product['variation'] is List) {
            final variationList = (product['variation'] as List)
                .where((variation) =>
            variation != null &&
                variation['variation_id'] != null &&
                variation['option_id'] != null &&
                variation['option_id'] is List &&
                (variation['option_id'] as List).isNotEmpty)
                .map((variation) => {
              'variation_id': variation['variation_id']?.toInt() ?? 0,
              'option_id': (variation['option_id'] as List)
                  .where((id) => id != null)
                  .map((id) => id?.toInt() ?? 0)
                  .toList(),
            })
                .toList();

            if (variationList.isNotEmpty) {
              productMap['variation'] = variationList;
            }
          }

          // حساب الـ amount, tax, discount للـ product الحالي
          final productAmount = product['amount']?.toDouble() ?? 0.0;
          final productTax = product['item_tax']?.toDouble() ?? 0.0;
          final productDiscount = product['item_discount']?.toDouble() ?? 0.0;

          // إنشاء الـ order data للـ product الحالي
          final orderData = {
            'table_id': tableId,
            'amount': productAmount,
            'total_tax': productTax,
            'total_discount': productDiscount,
            'products': [productMap], // product واحد بس في الـ array
          };

          print("📤 Sending single product order:");
          print("   Product ID: ${productMap['product_id']}");
          print("   Count: ${productMap['count']}");
          print("   Amount: $productAmount");
          print("   Tax: $productTax");
          print("   Discount: $productDiscount");
          print("   Full data: $orderData");

          // إرسال الـ request
          final response = await DioHelper.postData(
            url: '/captain/dine_in_order',
            data: orderData,
            token: token,
          );

          print("📋 Response for product ${i + 1}: Status ${response.statusCode}");

          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;
            print("✅ Product ${i + 1} sent successfully");

            // تخزين الـ response
            if (response.data != null && response.data['success'] != null) {
              if (response.data['success'] is List) {
                allSuccessProducts.addAll(response.data['success']);
              } else {
                allSuccessProducts.add(response.data['success']);
              }
            }
          } else {
            failedCount++;
            print("❌ Product ${i + 1} failed: Status ${response.statusCode}");
          }

          // تأخير بسيط بين الـ requests (100ms)
          await Future.delayed(Duration(milliseconds: 100));

        } catch (productError) {
          failedCount++;
          print("❌ Error sending product ${i + 1}: $productError");
        }
      }

      print("📊 Summary: $successCount succeeded, $failedCount failed out of ${products.length} products");

      // التحقق من النتيجة النهائية
      if (successCount == products.length) {
        // كل المنتجات اتبعتت بنجاح
        final productResponse = ProductResponse(success: allSuccessProducts.map((p) {
          if (p is Map<String, dynamic>) {
            return ProductModel.fromJson(p);
          }
          return ProductModel.fromJson({});
        }).toList());

        emit(ConfirmOrderSuccess(
          'All ${products.length} products confirmed successfully!',
          productResponse,
        ));
        ToastMessage.toastMessage(
          'All ${products.length} products confirmed successfully!',
          AppColors.green,
          AppColors.white,
        );
      } else if (successCount > 0) {
        // بعض المنتجات اتبعتت والبعض فشل
        final productResponse = ProductResponse(success: allSuccessProducts.map((p) {
          if (p is Map<String, dynamic>) {
            return ProductModel.fromJson(p);
          }
          return ProductModel.fromJson({});
        }).toList());

        emit(ConfirmOrderSuccess(
          '$successCount out of ${products.length} products confirmed',
          productResponse,
        ));
        ToastMessage.toastMessage(
          '$successCount products confirmed, $failedCount failed',
          AppColors.yellow,
          AppColors.white,
        );
      } else {
        // كل المنتجات فشلت
        emit(ConfirmOrderError('Failed to confirm any products'));
        ToastMessage.toastMessage(
          'Failed to confirm any products',
          AppColors.red,
          AppColors.white,
        );
      }

    } catch (e, stackTrace) {
      print("⚠️ Confirm Order Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(ConfirmOrderError('Error confirming order: $e'));
      ToastMessage.toastMessage(
        'Error confirming order: $e',
        AppColors.red,
        AppColors.white,
      );
    }
  }
}