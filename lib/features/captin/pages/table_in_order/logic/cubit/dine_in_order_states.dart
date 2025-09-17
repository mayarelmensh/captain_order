import '../model/dine_in_order_model.dart';

abstract class ProductListState {}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {}

class ProductListLoaded extends ProductListState {
  final Product productResponse;
  final int selectedCategoryIndex;
  final List<Product> filteredProducts;

  ProductListLoaded({
    required this.productResponse,
    required this.selectedCategoryIndex,
    required this.filteredProducts,
  });

  ProductListLoaded copyWith({
    Product? productResponse,
    int? selectedCategoryIndex,
    List<Product>? filteredProducts,
  }) {
    return ProductListLoaded(
      productResponse: productResponse ?? this.productResponse,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }
}

class ProductListError extends ProductListState {
  final String message;

  ProductListError(this.message);
}