import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:food_2_go/controller/api/end_points.dart';
import 'dart:developer';

import '../../../../../../controller/dio/dio_helper.dart';
import '../model/order_models.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  static OrderCubit get(context) => BlocProvider.of(context);

  OrderModels? orderModels;

  Future<void> getOrders({String? token}) async {
    emit(OrderLoading());

    try {
      final response = await DioHelper.getData(
        url: EndPoints.orders,
        token: token,
      );

      if (response.statusCode == 200) {
        orderModels = OrderModels.fromJson(response.data);
        emit(OrderSuccess(orderModels!));
        log('📦 Orders loaded successfully: ${orderModels?.orders?.length} orders');
      } else {
        emit(OrderError('Failed to load orders: ${response.statusMessage}'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      }

      log('❌ Error loading orders: $errorMessage');
      emit(OrderError(errorMessage));
    } catch (e) {
      log('❌ Unexpected error: $e');
      emit(OrderError('An unexpected error occurred'));
    }
  }

  Future<void> getOrderById(int orderId, {String? token}) async {
    emit(OrderLoading());

    try {
      final response = await DioHelper.getData(
        url: '${EndPoints.orders}/$orderId',
        token: token,
      );

      if (response.statusCode == 200) {
        final order = Orders.fromJson(response.data);
        orderModels = OrderModels(orders: [order]);
        emit(OrderSuccess(orderModels!));
        log('📦 Order loaded successfully: Order ID ${order.id}');
      } else {
        emit(OrderError('Failed to load order: ${response.statusMessage}'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.data}';
      }

      log('❌ Error loading order: $errorMessage');
      emit(OrderError(errorMessage));
    } catch (e) {
      log('❌ Unexpected error: $e');
      emit(OrderError('An unexpected error occurred'));
    }
  }

  Future<void> updateOrderStatus(int orderId, String status, {String? token}) async {
    try {
      final response = await DioHelper.patchData(
        url: '${EndPoints.orders}/$orderId',
        data: {'prepration_status': status},
        token: token,
      );

      if (response.statusCode == 200) {
        if (orderModels?.orders != null) {
          final orderIndex = orderModels!.orders!.indexWhere((order) => order.id == orderId);
          if (orderIndex != -1) {
            orderModels!.orders![orderIndex].preprationStatus = status;
            emit(OrderSuccess(orderModels!));
          }
        }
        log('✅ Order status updated successfully');
      } else {
        emit(OrderError('Failed to update order status'));
      }
    } catch (e) {
      log('❌ Error updating order status: $e');
      emit(OrderError('Failed to update order status'));
    }
  }

  Future<void> pickupOrder(int orderId, {String? token}) async {
    try {
      final response = await DioHelper.putData(
        url: '/waiter/orders/status/$orderId',
        token: token,
      );

      if (response.statusCode == 200) {
        if (orderModels?.orders != null) {
          final orderIndex = orderModels!.orders!.indexWhere((order) => order.id == orderId);
          if (orderIndex != -1) {
            orderModels!.orders![orderIndex].preprationStatus = 'picked_up';
            emit(OrderSuccess(orderModels!));
          }
        }
        log('✅ Order picked up successfully');
      } else {
        emit(OrderError('Failed to pickup order'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      }

      log('❌ Error picking up order: $errorMessage');
      emit(OrderError(errorMessage));
    } catch (e) {
      log('❌ Unexpected error during pickup: $e');
      emit(OrderError('Failed to pickup order'));
    }
  }

  List<Orders> getOrdersByStatus(String status) {
    if (orderModels?.orders == null) return [];

    return orderModels!.orders!
        .where((order) => order.preprationStatus == status)
        .toList();
  }

  List<Orders> getOrdersByTable(int tableId) {
    if (orderModels?.orders == null) return [];

    return orderModels!.orders!
        .where((order) => order.tableId == tableId)
        .toList();
  }

  double getTotalAmount() {
    if (orderModels?.orders == null) return 0.0;

    return orderModels!.orders!
        .fold(0.0, (total, order) => total + (order.amount?.toDouble() ?? 0.0));
  }

  int getOrdersCountByStatus(String status) {
    return getOrdersByStatus(status).length;
  }

  void clearOrders() {
    orderModels = null;
    emit(OrderInitial());
  }
}