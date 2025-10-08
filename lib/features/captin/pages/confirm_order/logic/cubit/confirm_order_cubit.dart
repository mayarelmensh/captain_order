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

      // Prepare order data - تنظيف البيانات الفارغة
      final orderData = {
        'table_id': tableId,
        'amount': amount,
        'total_tax': totalTax,
        'total_discount': totalDiscount,
        'products': products.map((product) {
          // إنشاء map للمنتج الأساسي
          final productMap = <String, dynamic>{
            'product_id': product['product_id']?.toInt() ?? 0,
            'count': product['count'] is String
                ? int.parse(product['count'])
                : (product['count'] as int? ?? 1),
          };

          // إضافة الـ note فقط لو موجود ومش فاضي
          if (product['note'] != null && product['note'].toString().trim().isNotEmpty) {
            productMap['note'] = product['note'].toString().trim();
          }

          // إضافة الـ addons فقط لو موجود ومش فاضي
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

            // فقط إضافة addons لو فيه عناصر
            if (addonsList.isNotEmpty) {
              productMap['addons'] = addonsList;
            }
          }

          // إضافة الـ exclude_id فقط لو موجود ومش فاضي
          if (product['exclude_id'] != null && product['exclude_id'] is List) {
            final excludeList = (product['exclude_id'] as List)
                .where((id) => id != null)
                .map((id) => id?.toInt() ?? 0)
                .toList();

            // فقط إضافة exclude_id لو فيه عناصر
            if (excludeList.isNotEmpty) {
              productMap['exclude_id'] = excludeList;
            }
          }

          // إضافة الـ extra_id فقط لو موجود ومش فاضي
          if (product['extra_id'] != null && product['extra_id'] is List) {
            final extraList = (product['extra_id'] as List)
                .where((id) => id != null)
                .map((id) => id?.toInt() ?? 0)
                .toList();

            // فقط إضافة extra_id لو فيه عناصر
            if (extraList.isNotEmpty) {
              productMap['extra_id'] = extraList;
            }
          }

          // إضافة الـ variation فقط لو موجود ومش فاضي
          if (product['variation'] != null && product['variation'] is List) {
            final variationList = (product['variation'] as List)
                .where((variation) =>
            variation != null &&
                variation['variation_id'] != null &&
                variation['option_id'] != null &&
                variation['option_id'] is List &&
                (variation['option_id'] as List).isNotEmpty
            )
                .map((variation) => {
              'variation_id': variation['variation_id']?.toInt() ?? 0,
              'option_id': (variation['option_id'] as List)
                  .where((id) => id != null)
                  .map((id) => id?.toInt() ?? 0)
                  .toList(),
            })
                .toList();

            // فقط إضافة variation لو فيه عناصر
            if (variationList.isNotEmpty) {
              productMap['variation'] = variationList;
            }
          }

          return productMap;
        }).toList(),
      };

      print("📦 Sending order to API (cleaned data): $orderData");
      print("🔍 Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...");

      final response = await DioHelper.postData(
        url: '/captain/dine_in_order',
        data: orderData,
        token: token,
      );

      print("📋 API Response: ${response.data}");
      print("📋 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final productResponse = ProductResponse.fromJson(response.data);
        print("📦 Parsed ${productResponse.success.length} products from response");

        // Debug: Log the parsed products
        for (var product in productResponse.success) {
          print("📋 Product: ${product.name}, ID: ${product.id}, Count: ${product.count}");
          print("📋 Addons: ${product.addonsSelected.length}, Extras: ${product.extras.length}");
          print("📋 Variations: ${product.variationSelected.length}, Excludes: ${product.excludes.length}");
        }

        emit(ConfirmOrderSuccess('Order confirmed successfully!', productResponse));
        ToastMessage.toastMessage(
          'Order confirmed successfully!',
          AppColors.green,
          AppColors.white,
        );
      } else {
        print("❌ Unexpected server response: Status ${response.statusCode}");
        emit(ConfirmOrderError(
            'Failed to confirm order: Unexpected server response'));
        ToastMessage.toastMessage(
          'Failed to confirm order: Unexpected server response',
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