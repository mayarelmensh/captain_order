import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_2_go/controller/dio/dio_helper.dart';
import 'package:food_2_go/controller/cache/shared_preferences_utils.dart';
import '../model/dine_in_order_model.dart';
import 'dine_in_order_states.dart';

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
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null || token.isEmpty) {
        print("⚠️ No token found in SharedPreferences");
        emit(ProductListError('No authentication token found'));
        return;
      }

      final response = await DioHelper.getData(
        url: '/captain/my_lists',
        token: token,
      );

      print("📦 Full Response Data: ${response.data}");
      print("🔍 Response Keys: ${response.data.keys.toList()}");
      print("📋 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> jsonData = response.data;

        // If response contains a 'data' key, use it
        if (response.data['data'] != null) {
          jsonData = response.data['data'] as Map<String, dynamic>;
          print("📦 Using nested data: ${jsonData.keys.toList()}");
        }

        // Parse response data into ProductListResponseModel
        final productResponse = ProductListResponseModel.fromJson(jsonData);

        // Store all data for filtering
        _allCategories = productResponse.categories.where((cat) => cat.active == 1).toList();
        _allProducts = productResponse.products;

        // Debug: Check products and categories
        print("📦 Loaded ${_allProducts.length} products");
        for (var product in _allProducts) {
          print("📋 Product: ${product.name}, Description: ${product.description}, Category ID: ${product.categoryId}");
        }
        print("📦 Loaded ${_allCategories.length} active categories");
        for (var category in _allCategories) {
          print("📋 Category: ${category.name}, ID: ${category.id}");
        }

        // Save token if it exists in response
        final newToken = response.data['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await SharedPreferenceUtils.saveData(
            key: 'token',
            value: newToken,
          );
          print("✅ Token saved: ${newToken.substring(0, 20)}...");
        } else {
          print("⚠️ No new token in response, using existing one");
        }

        // Check if products or categories are empty
        if (_allProducts.isEmpty) {
          print("⚠️ No products loaded from API");
          emit(ProductListError('No products found in response'));
          return;
        }
        if (_allCategories.isEmpty) {
          print("⚠️ No active categories loaded from API");
        }

        emit(ProductListLoaded(
          productResponse: productResponse,
          selectedCategoryIndex: _selectedCategoryIndex,
          filteredProducts: _getProductsByCategory(_selectedCategoryIndex),
        ));
      } else {
        print("❌ Unexpected server response: Status ${response.statusCode}");
        emit(ProductListError(
            'Failed to load data: Unexpected server response (Status: ${response.statusCode})'));
      }
    } catch (e, stackTrace) {
      print("⚠️ Load Product Data Exception: $e");
      print("📍 Stack Trace: $stackTrace");
      emit(ProductListError(
          'Error loading data: $e\nCheck your connection or API response'));
    }
  }

  // Change selected category tab
  void selectCategory(int index) {
    print("📍 Selecting category index: $index");
    final currentState = state;
    if (currentState is ProductListLoaded) {
      _selectedCategoryIndex = index;
      final filteredProducts = _getProductsByCategory(index);
      print("📦 Filtered ${filteredProducts.length} products for category index $index");
      emit(currentState.copyWith(
        selectedCategoryIndex: index,
        filteredProducts: filteredProducts,
      ));
    } else {
      print("⚠️ Cannot select category: State is ${currentState.runtimeType}");
    }
  }

  // Filter products by category ID
  void filterProductsByCategory(int categoryId) {
    print("📍 Filtering by category ID: $categoryId");
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final categoryIndex = _allCategories.indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        _selectedCategoryIndex = categoryIndex + 1; // +1 because 0 is "All"
        final filteredProducts = _allProducts.where((product) => product.categoryId == categoryId).toList();
        print("📦 Filtered ${filteredProducts.length} products for category ID $categoryId");
        emit(currentState.copyWith(
          selectedCategoryIndex: _selectedCategoryIndex,
          filteredProducts: filteredProducts,
        ));
      } else {
        print("⚠️ Category ID $categoryId not found");
        emit(currentState.copyWith(
          filteredProducts: _allProducts,
        ));
      }
    } else {
      print("⚠️ Cannot filter by category: State is ${currentState.runtimeType}");
    }
  }

  // Filter products by subcategory ID
  void filterProductsBySubCategory(int subCategoryId) {
    print("📍 Filtering by subcategory ID: $subCategoryId");
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final filteredProducts = _allProducts
          .where((product) => product.subCategoryId == subCategoryId)
          .toList();
      print("📦 Filtered ${filteredProducts.length} products for subcategory ID $subCategoryId");
      emit(currentState.copyWith(
        filteredProducts: filteredProducts,
      ));
    } else {
      print("⚠️ Cannot filter by subcategory: State is ${currentState.runtimeType}");
    }
  }

  // Search products by name or description
  void searchProducts(String query) {
    print("🔍 Search query received: '$query'");
    final currentState = state;
    if (currentState is ProductListLoaded) {
      List<Product> filteredProducts;
      if (query.isEmpty) {
        // If search is empty, return to category filtered products
        filteredProducts = _getProductsByCategory(_selectedCategoryIndex);
        print("🔍 Query is empty, showing ${filteredProducts.length} products for category index $_selectedCategoryIndex");
      } else {
        // Search in current filtered products or all products
        final searchBase = _selectedCategoryIndex == 0
            ? _allProducts
            : _getProductsByCategory(_selectedCategoryIndex);

        print("🔍 Searching in ${searchBase.length} products");
        filteredProducts = searchBase
            .where((product) {
          final nameLower = product.name?.toLowerCase() ?? '';
          final descriptionLower = product.description?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          final matchesName = nameLower.contains(queryLower);
          final matchesDescription = descriptionLower.contains(queryLower);
          print("📋 Checking product: ${product.name}, Matches name: $matchesName, Matches description: $matchesDescription");
          return matchesName || matchesDescription;
        })
            .toList();
        print("🔍 Filtered ${filteredProducts.length} products for query '$query'");
      }
      emit(currentState.copyWith(
        filteredProducts: filteredProducts,
      ));
    } else {
      print("⚠️ Cannot search: State is ${currentState.runtimeType}");
    }
  }

  // Get products by category index (0 = all, 1+ = specific category)
  List<Product> _getProductsByCategory(int categoryIndex) {
    if (categoryIndex == 0 || _allCategories.isEmpty) {
      print("📦 Showing all ${_allProducts.length} products");
      return _allProducts;
    } else {
      try {
        final categoryId = _allCategories[categoryIndex - 1].id; // -1 because 0 is "All"
        final filteredProducts = _allProducts.where((product) => product.categoryId == categoryId).toList();
        print("📦 Filtered ${filteredProducts.length} products for category ID $categoryId");
        return filteredProducts;
      } catch (e) {
        print("⚠️ Filter Error: $e");
        return _allProducts;
      }
    }
  }

  // Get tabs based on categories (All + Category names)
  List<String> getCategoryTabs() {
    final currentState = state;
    if (currentState is! ProductListLoaded) {
      print("📋 No tabs available: State is ${currentState.runtimeType}");
      return ["All"];
    }

    List<String> tabs = ["All"];
    tabs.addAll(_allCategories.map((category) => category.name));
    print("📋 Generated ${tabs.length} category tabs");
    return tabs;
  }

  // Get active categories only
  List<Category> getActiveCategories() {
    print("📋 Returning ${_allCategories.length} active categories");
    return _allCategories;
  }

  // Get category by ID
  Category? getCategoryById(int categoryId) {
    try {
      final category = _allCategories.firstWhere((cat) => cat.id == categoryId);
      print("📋 Found category: ${category.name} for ID $categoryId");
      return category;
    } catch (e) {
      print("⚠️ Category ID $categoryId not found");
      return null;
    }
  }

  // Get available tables from cafe locations
  List<Table> getAvailableTables() {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final allTables = <Table>[];
      for (final location in currentState.productResponse.cafeLocation) {
        allTables.addAll(location.tables.where((table) => table.currentStatus == 'available'));
      }
      print("📋 Found ${allTables.length} available tables");
      return allTables;
    }
    print("⚠️ No tables available: State is ${currentState.runtimeType}");
    return [];
  }

  // Get payment methods
  List<PaymentMethod> getPaymentMethods() {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      final methods = currentState.productResponse.paymentMethods
          .where((method) => method.status == 1)
          .toList();
      print("📋 Found ${methods.length} active payment methods");
      return methods;
    }
    print("⚠️ No payment methods available: State is ${currentState.runtimeType}");
    return [];
  }

  // Reset to show all products
  void resetProducts() {
    print("📍 Resetting to show all products");
    _selectedCategoryIndex = 0;
    final currentState = state;
    if (currentState is ProductListLoaded) {
      emit(currentState.copyWith(
        selectedCategoryIndex: 0,
        filteredProducts: _allProducts,
      ));
    } else {
      print("⚠️ Cannot reset products: State is ${currentState.runtimeType}");
    }
  }

  // Refresh data
  Future<void> refresh() async {
    print("🔄 Refreshing product list");
    await getProductLists();
  }
}

