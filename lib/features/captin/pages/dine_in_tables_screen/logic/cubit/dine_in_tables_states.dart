import '../model/dine_in_tables_model.dart';

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