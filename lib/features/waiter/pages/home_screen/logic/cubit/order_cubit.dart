
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/controller/api/end_points.dart';
import '../../../../../../controller/dio/dio_helper.dart';
import '../../../../../../controller/cache/shared_preferences_utils.dart';
import '../model/order_item.dart';
import '../model/order_list.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  List<Orders> orders = [];
  OrderItem? currentOrderDetails;

  Future<void> getOrders() async {
    emit(OrderLoading());

    try {
      String? token = await SharedPreferenceUtils.getData(key: 'token') as String?;

      if (token == null) {
        log("❌ No token found");
        emit(OrderError('Authentication required. Please login again.'));
        return;
      }

      log("🔑 Using Token: $token");

      final response = await DioHelper.getData(
          url: EndPoints.ordersList,
          token: token
      );

      log("📦 Orders Response: ${response.data}");

      if (response.statusCode == 200) {
        final orderList = OrderList.fromJson(response.data);
        orders = orderList.orders ?? [];

        log("✅ Orders Count: ${orders.length}");
        emit(OrderSuccess());
      } else {
        emit(OrderError('Failed to load orders'));
      }
    } catch (e) {
      log("⚠️ Orders Exception: $e");

      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        emit(OrderError('Session expired. Please login again.'));
      } else {
        emit(OrderError('Something went wrong while loading orders'));
      }
    }
  }

  // Method to get order details
  Future<void> getOrderDetails(int orderId) async {
    emit(OrderDetailsLoading());

    try {
      String? token = await SharedPreferenceUtils.getData(key: 'token') as String?;

      if (token == null) {
        log("❌ No token found");
        emit(OrderError('Authentication required. Please login again.'));
        return;
      }

      log("🔑 Getting order details for ID: $orderId");

      final response = await DioHelper.getData(
          url: EndPoints.orderItem(orderId),
          token: token
      );

      log("📋 Order Details Response: ${response.data}");

      if (response.statusCode == 200) {
        currentOrderDetails = OrderItem.fromJson(response.data);
        log("✅ Order details loaded successfully");
        emit(OrderDetailsSuccess());
      } else {
        emit(OrderError('Failed to load order details'));
      }
    } catch (e) {
      log("⚠️ Order Details Exception: $e");

      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        emit(OrderError('Session expired. Please login again.'));
      } else {
        emit(OrderError('Something went wrong while loading order details'));
      }
    }
  }

  // Method to pickup order (update status)
  Future<void> pickupOrder(int orderId) async {
    emit(OrderPickupLoading());

    try {
      String? token = await SharedPreferenceUtils.getData(key: 'token') as String?;

      if (token == null) {
        log("❌ No token found");
        emit(OrderError('Authentication required. Please login again.'));
        return;
      }

      log("📦 Picking up order ID: $orderId");

      final response = await DioHelper.putData(
          url: EndPoints.orderStatus(orderId),
          token: token,
          data: {
            'status': 'picked_up', // or whatever status value your API expects
          }
      );

      log("✅ Pickup Response: ${response.data}");

      if (response.statusCode == 200) {
        log("✅ Order picked up successfully");
        emit(OrderPickupSuccess());

        // Optionally refresh orders list to update status
        await refreshOrders();
      } else {
        emit(OrderError('Failed to pickup order'));
      }
    } catch (e) {
      log("⚠️ Pickup Order Exception: $e");

      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        emit(OrderError('Session expired. Please login again.'));
      } else {
        emit(OrderError('Something went wrong while picking up order'));
      }
    }
  }

  Future<void> refreshOrders() async {
    await getOrders();
  }

  Future<bool> isAuthenticated() async {
    String? token = await SharedPreferenceUtils.getData(key: 'token') as String?;
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await SharedPreferenceUtils.removeData(key: 'token');
    orders.clear();
    currentOrderDetails = null;
    emit(OrderInitial());
  }

  // Helper method to clear order details
  void clearOrderDetails() {
    currentOrderDetails = null;
  }
}