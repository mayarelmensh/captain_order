import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/controller/dio/dio_helper.dart';
import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
import '../model/dine_in_order_model.dart';

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit() : super(ProductListInitial()) {
    getProductLists();
  }

  List<Product> _allProducts = []; // Store all products for filtering
  List<Category> _allCategories = []; // Store all categories
  int _selectedCategoryIndex = 0; // Track selected category index

  // Load products and categories data
  Future<void> getProductLists() async {
    emit(ProductListLoading());
    try {
      await SharedPreferenceUtils.init();
      final token = SharedPreferenceUtils.getData(key: 'token') as String;
      final response = await DioHelper.getData(
        url: '/captain/lists',
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

        // Parse response data into ProductListResponseModel
        final productResponse = ProductListResponseModel.fromJson(jsonData);

        // Store all data for filtering
        _allCategories = productResponse.categories.where((cat) => cat.active == 1).toList();
        _allProducts = productResponse.products;

        // Save token if it exists in response
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

        emit(ProductListLoaded(
          productResponse: productResponse,
          selectedCategoryIndex: _selectedCategoryIndex,
          filteredProducts: _getProductsByCategory(_selectedCategoryIndex),
        ));
      } else {
        emit(ProductListError(
            'Failed to load data: Unexpected server response (Status: ${response.statusCode})'));
      }
    } catch (e, stackTrace) {
      print("⚠️ Load Product Data Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(ProductListError(
          'Error parsing data: $e\nCheck your connection or API response'));
    }
  }

  // Change selected category tab
  void selectCategory(int index) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      _selectedCategoryIndex = index;
      emit(currentState.copyWith(
        selectedCategoryIndex: index,
        filteredProducts: _getProductsByCategory(index),
      ));
    }
  }

  // Filter products by category ID
  void filterProductsByCategory(int categoryId) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final categoryIndex = _allCategories.indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        _selectedCategoryIndex = categoryIndex;
        emit(currentState.copyWith(
          selectedCategoryIndex: categoryIndex,
          filteredProducts: _allProducts.where((product) => product.categoryId == categoryId).toList(),
        ));
      }
    }
  }

  // Filter products by subcategory ID
  void filterProductsBySubCategory(int subCategoryId) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final filteredProducts = _allProducts
          .where((product) => product.subCategoryId == subCategoryId)
          .toList();

      emit(currentState.copyWith(
        filteredProducts: filteredProducts,
      ));
    }
  }

  // Search products by name or description
  void searchProducts(String query) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      if (query.isEmpty) {
        // If search is empty, return to category filtered products
        emit(currentState.copyWith(
          filteredProducts: _getProductsByCategory(_selectedCategoryIndex),
        ));
      } else {
        // Search in current filtered products or all products
        final searchBase = _selectedCategoryIndex == 0
            ? _allProducts
            : _getProductsByCategory(_selectedCategoryIndex);

        final filteredProducts = searchBase
            .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
            (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();

        emit(currentState.copyWith(
          filteredProducts: filteredProducts,
        ));
      }
    }
  }

  // Get products by category index (0 = all, 1+ = specific category)
  List<Product> _getProductsByCategory(int categoryIndex) {
    if (categoryIndex == 0 || _allCategories.isEmpty) {
      // All categories
      return _allProducts;
    } else {
      // Specific category
      try {
        final categoryId = _allCategories[categoryIndex - 1].id; // -1 because 0 is "All"
        return _allProducts.where((product) => product.categoryId == categoryId).toList();
      } catch (e) {
        print("⚠️ Filter Error: $e");
        return _allProducts;
      }
    }
  }

  // Get tabs based on categories (All + Category names)
  List<String> getCategoryTabs() {
    final currentState = state;
    if (currentState is! ProductListLoaded) return ["All"];

    List<String> tabs = ["All"];
    tabs.addAll(_allCategories.map((category) => category.name));
    return tabs;
  }

  // Get active categories only
  List<Category> getActiveCategories() {
    return _allCategories;
  }

  // Get category by ID
  Category? getCategoryById(int categoryId) {
    try {
      return _allCategories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get available tables from cafe locations
  List<Table> getAvailableTables() {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final allTables = <Table>[];

      for (final location in currentState.productResponse.cafeLocation) {
        allTables.addAll(location.tables.where((table) =>
        table.currentStatus == 'available'));
      }

      return allTables;
    }
    return [];
  }

  // Get payment methods
  List<PaymentMethod> getPaymentMethods() {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      return currentState.productResponse.paymentMethods
          .where((method) => method.status == 1)
          .toList();
    }
    return [];
  }

  // Reset to show all products
  void resetProducts() {
    _selectedCategoryIndex = 0;
    final currentState = state;
    if (currentState is ProductListLoaded) {
      emit(currentState.copyWith(
        selectedCategoryIndex: 0,
        filteredProducts: _allProducts,
      ));
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await getProductLists();
  }
}

// States
abstract class ProductListState {}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {}

class ProductListLoaded extends ProductListState {
  final ProductListResponseModel productResponse;
  final int selectedCategoryIndex;
  final List<Product> filteredProducts;

  ProductListLoaded({
    required this.productResponse,
    required this.selectedCategoryIndex,
    required this.filteredProducts,
  });

  ProductListLoaded copyWith({
    ProductListResponseModel? productResponse,
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