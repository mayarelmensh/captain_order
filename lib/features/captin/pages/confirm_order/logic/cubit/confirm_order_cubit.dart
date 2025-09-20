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

      // Prepare order data
      final orderData = {
        'table_id': tableId,
        'amount': amount,
        'total_tax': totalTax,
        'total_discount': totalDiscount,
        'products': products.map((product) => {
          'product_id': product['product_id']?.toInt() ?? 0,
          'count': product['count'] is String ? int.parse(product['count']) : (product['count'] as int? ?? 1),
          'note': product['note']?.toString() ?? '',
          'addons': (product['addons'] as List? ?? []).map((addon) => {
            'addon_id': addon['addon_id']?.toInt() ?? 0,
            'count': addon['count'] is String ? int.parse(addon['count']) : (addon['count'] as int? ?? 1),
          }).toList(),
          'exclude_id': (product['exclude_id'] as List? ?? []).map((id) => id?.toInt() ?? 0).toList(),
          'extra_id': (product['extra_id'] as List? ?? []).map((id) => id?.toInt() ?? 0).toList(),
          'variation': (product['variation'] as List? ?? []).map((variation) => {
            'variation_id': variation['variation_id']?.toInt() ?? 0,
            'option_id': (variation['option_id'] as List? ?? []).map((id) => id?.toInt() ?? 0).toList(),
          }).toList(),
        }).toList(),
      };

      print("📦 Sending order to API: $orderData");
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