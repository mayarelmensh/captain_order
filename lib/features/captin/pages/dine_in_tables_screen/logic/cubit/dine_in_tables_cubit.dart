  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:food_2_go/controller/dio/dio_helper.dart';
  import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
  import 'package:food_2_go/features/captin/pages/dine_in_tables_screen/logic/cubit/dine_in_tables_states.dart';
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
          // Refresh the cafe data to get updated table statuses
          await loadCafeData();
          return true;
        } else {
          print("❌ Failed to update table status: Status ${response.statusCode}");
          emit(DineInTablesError('Failed to update table status'));
          return false;
        }
      } catch (e, stackTrace) {
        print("⚠️ Update Table Status Exception: $e");
        print("📍 Stack Trace: $stackTrace");
        emit(DineInTablesError('Error updating table status: $e'));
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

    // Change selected location tab
    void selectLocation(int index) {
      final currentState = state;
      if (currentState is DineInTablesLoaded) {
        emit(currentState.copyWith(selectedLocationIndex: index));
      }
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