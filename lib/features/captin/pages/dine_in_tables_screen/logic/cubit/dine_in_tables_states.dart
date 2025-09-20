import '../model/dine_in_tables_model.dart';
import '../model/get_table_order_model.dart';

abstract class DineInTablesState {}

class DineInTablesInitial extends DineInTablesState {}

class DineInTablesLoading extends DineInTablesState {}

class DineInTablesLoaded extends DineInTablesState {
  final CafeResponseModel cafeResponse;
  final int selectedLocationIndex;

  DineInTablesLoaded({
    required this.cafeResponse,
    this.selectedLocationIndex = 0,
  });

  DineInTablesLoaded copyWith({
    CafeResponseModel? cafeResponse,
    int? selectedLocationIndex,
  }) {
    return DineInTablesLoaded(
      cafeResponse: cafeResponse ?? this.cafeResponse,
      selectedLocationIndex: selectedLocationIndex ?? this.selectedLocationIndex,
    );
  }
}

class DineInTablesError extends DineInTablesState {
  final String message;
  DineInTablesError(this.message);
}

class DineInTablesCheckoutProcessing extends DineInTablesState {
  final int tableId;

  DineInTablesCheckoutProcessing(this.tableId);
}

class DineInTablesCheckoutSuccess extends DineInTablesState {
  final int tableId;
  final String message;

  DineInTablesCheckoutSuccess({
    required this.tableId,
    required this.message,
  });
}
class GetTableOrderLoading extends DineInTablesState{}
class GetTableOrderError extends DineInTablesState{
  String message;
  GetTableOrderError({required this.message});
}
class GetTableOrderSuccess extends DineInTablesState{
  GetTableOrderModel tableOrderModel;
  GetTableOrderSuccess({required this.tableOrderModel});
}
