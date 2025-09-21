import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/controller/dio/dio_helper.dart';
import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
import 'package:food_2_go/features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_states.dart';
import 'package:food_2_go/features/captin/pages/dine_in_tables_screen/logic/model/get_table_order_model.dart';
import '../model/dine_in_tables_model.dart';
import '../model/get_table_model.dart';

class DineInTablesCubit extends Cubit<DineInTablesState> {
  DineInTablesCubit() : super(DineInTablesInitial()) {
    loadCafeData();
  }

  // Load cafe locations and tables
  Future<void> loadCafeData() async {
    emit(DineInTablesLoading());
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;
      final response = await DioHelper.getData(
        url: '/captain/my_selection_lists',
        token: token,
      );

      print("📦 Full Response Data: ${response.data}");
      print("🔍 Response Keys: ${response.data.keys.toList()}");

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> jsonData = response.data;

        // If response contains a 'data' key, use it instead
        if (response.data['data'] != null) {
          jsonData = response.data['data'] as Map<String, dynamic>;
          print("📦 Using nested data: ${jsonData.keys.toList()}");
        }

        // Parse response data into CafeResponseModel
        final cafeResponse = CafeResponseModel.fromJson(jsonData);

        // Save token if it exists in response (usually from login, not here)
        final token = response.data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await SharedPreferenceUtils.saveData(
            key: 'token',
            value: token,
          );
          print("✅ Token saved: ${token.substring(0, 20)}...");
        } else {
          print("⚠️ No token in this response, using existing one");
        }

        emit(DineInTablesLoaded(cafeResponse: cafeResponse));
      } else {
        emit(DineInTablesError(
            'Failed to load data: Unexpected server response (Status: ${response.statusCode})'));
      }
    } catch (e, stackTrace) {
      print("⚠️ Load Cafe Data Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(DineInTablesError(
          'Error parsing data: $e\nCheck your connection or API response'));
    }
  }

  // Get table status from API
  Future<GetTableModel?> getTableStatus() async {
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      final response = await DioHelper.getData(
        url: '/captain/get_table_status',
        token: token,
      );

      print("📋 Table Status Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> jsonData = response.data;

        // If response contains a 'data' key, use it instead
        if (response.data['data'] != null) {
          jsonData = response.data['data'] as Map<String, dynamic>;
        }
        if (response.data['data'] != null) {
          jsonData = response.data['data'] as Map<String, dynamic>;
        }

        final tableStatusModel = GetTableModel.fromJson(jsonData);
        print("✅ Table Status loaded: ${tableStatusModel.tableStatus}");
        return tableStatusModel;
      } else {
        print("❌ Failed to get table status: Status ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      print("⚠️ Get Table Status Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      return null;
    }
  }

  // Update table status
  Future<bool> updateTableStatus({
    required int tableId,
    required String newStatus,
  }) async {
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      final response = await DioHelper.putData(
        url: '/captain/tables_status/$tableId',
        data: {
          'current_status': newStatus,
        },
        token: token,
      );

      print("🔄 Update Status Response: ${response.data}");

      if (response.statusCode == 200) {
        print("✅ Table status updated successfully");
        // 🔥 Don't call loadCafeData here to avoid double refresh
        return true;
      } else {
        print("❌ Failed to update table status: Status ${response.statusCode}");
        return false;
      }
    } catch (e, stackTrace) {
      print("⚠️ Update Table Status Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      return false;
    }
  }

  // Get available table statuses (helper method)
  Future<List<String>> getAvailableTableStatuses() async {
    final tableStatusModel = await getTableStatus();
    return tableStatusModel?.tableStatus ?? [];
  }

  // Change table status with validation
  Future<bool> changeTableStatus({
    required int tableId,
    required String newStatus,
  }) async {
    // First, get available statuses to validate
    final availableStatuses = await getAvailableTableStatuses();

    if (availableStatuses.isEmpty) {
      emit(DineInTablesError('Could not load available table statuses'));
      return false;
    }

    if (!availableStatuses.contains(newStatus)) {
      emit(DineInTablesError('Invalid status. Available statuses: ${availableStatuses.join(', ')}'));
      return false;
    }

    // Update the status
    return await updateTableStatus(tableId: tableId, newStatus: newStatus);
  }

  // Send checkout request
  Future<bool> sendCheckoutRequest({required int tableId}) async {
    emit(DineInTablesCheckoutProcessing(tableId));
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      final response = await DioHelper.postData(
        url: '/captain/checkout_request',
        query: {
          'table_id': tableId,
        },
        token: token,
      );

      print("🛒 Checkout Request Response: ${response.data}");

      if (response.statusCode == 200) {
        final successMessage = response.data['success'] as String?; // خذ الـ success كـ String
        if (successMessage != null && successMessage.toLowerCase().contains('success')) {
          print("✅ Checkout request sent successfully for table $tableId");
          emit(DineInTablesCheckoutSuccess(
            tableId: tableId,
            message: successMessage,
          ));
          return true;
        } else {
          print("❌ Checkout failed: ${response.data['message'] ?? 'Unknown error'}");
          emit(DineInTablesError('Checkout failed: ${response.data['message'] ?? 'Unknown error'}'));
          return false;
        }
      } else {
        print("❌ Failed to send checkout request: Status ${response.statusCode}, Message: ${response.data['message']}");
        emit(DineInTablesError('Failed to send checkout request (Status: ${response.statusCode}, Message: ${response.data['message'] ?? 'Unknown error'})'));
        return false;
      }
    } catch (e, stackTrace) {
      print("⚠️ Checkout Request Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(DineInTablesError('Error sending checkout request: $e'));
      return false;
    }
  }

  // Change selected location tab
  void selectLocation(int index) {
    final currentState = state;
    if (currentState is DineInTablesLoaded) {
      emit(currentState.copyWith(selectedLocationIndex: index));
    }
  }

  Future<void> getTableOrder({required int tableId}) async {
    emit(GetTableOrderLoading());
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      final response = await DioHelper.getData(
        url: '/captain/dine_in_table_order/$tableId',
        token: token,
      );

      print("📋 Table Order Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data;
        if (jsonData['success'] != null && jsonData['success'] is List) {
          final orders = (jsonData['success'] as List)
              .map((item) => TableOrder.fromJson(item as Map<String, dynamic>))
              .toList();
          final tableOrderModel = GetTableOrderModel(orders: orders);
          print("✅ Parsed Orders Count: ${tableOrderModel.orders.length}");
          print("✅ Parsed Orders: $orders");
          emit(GetTableOrderSuccess(tableOrderModel: tableOrderModel));
        } else {
          emit(GetTableOrderError(message: 'Invalid response format: No "success" array found'));
        }
      } else {
        emit(GetTableOrderError(message: 'Failed to load table orders (Status: ${response.statusCode})'));
      }
    } catch (e, stackTrace) {
      print("⚠️ Get Table Order Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(GetTableOrderError(message: 'Error loading table orders: $e'));
    }
  }

  Future<void> updateOrderStatus({
    required int tableId,
    required int cartId,
    required String status,
  }) async {
    emit(GetTableOrderLoading());
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      final response = await DioHelper.postData(
        url: '/captain/preparing',
        token: token,
        query: {
          'preparing[0][cart_id]': cartId,
          'table_id': tableId,
          'preparing[0][status]': status,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Order Status Updated: $status for cart $cartId");
        getTableOrder(tableId: tableId);
      } else {
        emit(GetTableOrderError(message: 'Failed to update order status (Status: ${response.statusCode})'));
      }
    } catch (e, stackTrace) {
      print("⚠️ Update Order Status Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(GetTableOrderError(message: 'Error updating order status: $e'));
    }
  }

  // Transfer order from one table to another and update status
  Future<bool> transferOrder({
    required int sourceTableId, // 🔥 Added source table ID
    required int destinationTableId, // 🔥 Renamed for clarity
    required List<int> cartIds,
    String newStatus = "available", // Default status after transfer
  }) async {
    emit(DineInTablesLoading());
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;

      // Prepare form data according to API requirements - using correct field name
      Map<String, dynamic> formData = {
        'table_id': destinationTableId,
        'cart_ids': cartIds, // 🔥 Fixed: Use cart_ids directly as array
      };

      print("📋 Transfer Data Being Sent: $formData");
      print("📋 Cart IDs: $cartIds");
      print("📋 Source Table ID: $sourceTableId");
      print("📋 Destination Table ID: $destinationTableId");

      final response = await DioHelper.postData(
        url: '/captain/transfer_order',
        data: formData,
        token: token,
      );

      print("🔄 Transfer Order Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final successMessage = response.data['success'] as String?;

        if (successMessage != null && successMessage.isNotEmpty) {
          print("✅ Order transferred successfully: $successMessage");

          // تحديث status الطاولة المصدر بعد نجاح التحويل
          bool statusUpdated = await updateTableStatus(
              tableId: sourceTableId, // 🔥 Update source table status
              newStatus: newStatus
          );

          if (statusUpdated) {
            print("✅ Source table status updated to: $newStatus");
          } else {
            print("⚠️ Transfer successful but source table status update failed");
          }

          // 🔥 IMPORTANT: Return to main loaded state instead of transfer success
          // This prevents the white screen issue
          await loadCafeData(); // This will emit DineInTablesLoaded state
          return true;
        } else {
          final errorMessage = response.data['message'] ?? 'Transfer failed for unknown reason';
          print("❌ Transfer failed: $errorMessage");
          emit(DineInTablesError('Transfer failed: $errorMessage'));
          return false;
        }
      } else {
        print("❌ Failed to transfer order: Status ${response.statusCode}");
        emit(DineInTablesError(
            'Failed to transfer order (Status: ${response.statusCode})'
        ));
        return false;
      }
    } catch (e, stackTrace) {
      print("⚠️ Transfer Order Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(DineInTablesError('Error transferring order: $e'));
      return false;
    }
  }

  // Helper method to transfer single cart item with custom status
  Future<bool> transferSingleOrder({
    required int sourceTableId, // 🔥 Added source table ID
    required int destinationTableId, // 🔥 Added destination table ID
    required int cartId,
    String newStatus = "available",
  }) async {
    return await transferOrder(
      sourceTableId: sourceTableId,
      destinationTableId: destinationTableId,
      cartIds: [cartId],
      newStatus: newStatus,
    );
  }

  // Helper method to transfer multiple cart items with custom status
  Future<bool> transferMultipleOrders({
    required int sourceTableId, // 🔥 Added source table ID
    required int destinationTableId, // 🔥 Added destination table ID
    required List<int> cartIds,
    String newStatus = "available",
  }) async {
    if (cartIds.isEmpty) {
      emit(DineInTablesError('No orders selected for transfer'));
      return false;
    }

    return await transferOrder(
      sourceTableId: sourceTableId,
      destinationTableId: destinationTableId,
      cartIds: cartIds,
      newStatus: newStatus,
    );
  }

  // Get filtered tables based on selected location
  List<TableModel> getFilteredTables() {
    final currentState = state;
    if (currentState is! DineInTablesLoaded) return [];

    if (currentState.selectedLocationIndex == 0) {
      // All Locations
      return currentState.cafeResponse.cafeLocation
          .expand((location) => location.tables)
          .toList();
    } else {
      // Specific location
      try {
        return currentState.cafeResponse.cafeLocation
            .firstWhere(
                (loc) => loc.id == currentState.selectedLocationIndex)
            .tables;
      } catch (e) {
        print("⚠️ Filter Error: $e");
        return [];
      }
    }
  }

  // Get tabs based on locations
  List<String> getTabs() {
    final currentState = state;
    if (currentState is! DineInTablesLoaded) return ["All Locations"];

    List<String> tabs = ["All Locations"];
    tabs.addAll(currentState.cafeResponse.cafeLocation.map((loc) => loc.name));
    return tabs;
  }

  // Get location by ID
  CafeLocationModel? getLocationById(int locationId) {
    final currentState = state;
    if (currentState is! DineInTablesLoaded) return null;
    try {
      return currentState.cafeResponse.cafeLocation
          .firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  // Get table by ID
  TableModel? getTableById(int tableId) {
    final currentState = state;
    if (currentState is! DineInTablesLoaded) return null;

    for (final location in currentState.cafeResponse.cafeLocation) {
      try {
        return location.tables.firstWhere((table) => table.id == tableId);
      } catch (e) {
        continue; // Table not in this location, continue searching
      }
    }
    return null; // Table not found
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCafeData();
  }
}