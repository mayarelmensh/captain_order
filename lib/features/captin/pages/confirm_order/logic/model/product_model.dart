// product_response.dart
class ProductResponse {
  final List<ProductModel> success;

  ProductResponse({required this.success});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: (json['success'] as List<dynamic>? ?? [])
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductModel {
  final int id;
  final List<dynamic> allExtras;
  final String taxes;
  final String name;
  final String description;
  final String image;
  final int categoryId;
  final int? subCategoryId; // Nullable
  final String itemType;
  final String stockType;
  final String? number; // Nullable
  final double price;
  final double priceAfterDiscount;
  final double priceAfterTax;
  final double discountVal;
  final double taxVal;
  final int productTimeStatus;
  final String? from; // Nullable
  final String? to; // Nullable
  final int? discountId; // Nullable
  final int? taxId; // Nullable
  final int status;
  final int recommended;
  final int points;
  final String imageLink;
  final int ordersCount;
  final dynamic discount; // Can be null
  final dynamic tax; // Can be null
  final bool favourite;
  final String createdAt;
  final String updatedAt;
  final int cartId;
  final int productIndex;
  final int count;
  final String prepration;
  final List<dynamic> excludes;
  final List<dynamic> extras;
  final List<dynamic> variationSelected;
  final List<AddonSelectedModel> addonsSelected;

  ProductModel({
    required this.id,
    required this.allExtras,
    required this.taxes,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryId,
    this.subCategoryId,
    required this.itemType,
    required this.stockType,
    this.number,
    required this.price,
    required this.priceAfterDiscount,
    required this.priceAfterTax,
    required this.discountVal,
    required this.taxVal,
    required this.productTimeStatus,
    this.from,
    this.to,
    this.discountId,
    this.taxId,
    required this.status,
    required this.recommended,
    required this.points,
    required this.imageLink,
    required this.ordersCount,
    this.discount,
    this.tax,
    required this.favourite,
    required this.createdAt,
    required this.updatedAt,
    required this.cartId,
    required this.productIndex,
    required this.count,
    required this.prepration,
    required this.excludes,
    required this.extras,
    required this.variationSelected,
    required this.addonsSelected,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      allExtras: json['allExtras'] as List<dynamic>? ?? [],
      taxes: json['taxes'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      subCategoryId: json['sub_category_id'] as int?, // Nullable
      itemType: json['item_type'] as String? ?? '',
      stockType: json['stock_type'] as String? ?? '',
      number: json['number'] as String?, // Nullable
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceAfterDiscount: (json['price_after_discount'] as num?)?.toDouble() ?? 0.0,
      priceAfterTax: (json['price_after_tax'] as num?)?.toDouble() ?? 0.0,
      discountVal: (json['discount_val'] as num?)?.toDouble() ?? 0.0,
      taxVal: (json['tax_val'] as num?)?.toDouble() ?? 0.0,
      productTimeStatus: json['product_time_status'] as int? ?? 0,
      from: json['from'] as String?, // Nullable
      to: json['to'] as String?, // Nullable
      discountId: json['discount_id'] as int?, // Nullable
      taxId: json['tax_id'] as int?, // Nullable
      status: json['status'] as int? ?? 0,
      recommended: json['recommended'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      imageLink: json['image_link'] as String? ?? '',
      ordersCount: json['orders_count'] as int? ?? 0,
      discount: json['discount'], // Can be null
      tax: json['tax'], // Can be null
      favourite: json['favourite'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      cartId: json['cart_id'] as int? ?? 0,
      productIndex: json['product_index'] as int? ?? 0,
      count: json['count'] is String ? int.parse(json['count'] as String) : (json['count'] as int? ?? 0),
      prepration: json['prepration'] as String? ?? '',
      excludes: json['excludes'] as List<dynamic>? ?? [],
      extras: json['extras'] as List<dynamic>? ?? [],
      variationSelected: json['variation_selected'] as List<dynamic>? ?? [],
      addonsSelected: (json['addons_selected'] as List<dynamic>? ?? [])
          .map((item) => AddonSelectedModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AddonSelectedModel {
  final int id;
  final String name;
  final double price;
  final double priceAfterTax;
  final double discountVal;
  final double taxVal;
  final int? taxId; // Nullable
  final int quantityAdd;
  final TaxModel? tax; // Nullable
  final String createdAt;
  final String updatedAt;
  final int count;

  AddonSelectedModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceAfterTax,
    required this.discountVal,
    required this.taxVal,
    this.taxId,
    this.tax,
    required this.quantityAdd,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
  });

  factory AddonSelectedModel.fromJson(Map<String, dynamic> json) {
    return AddonSelectedModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceAfterTax: (json['price_after_tax'] as num?)?.toDouble() ?? 0.0,
      discountVal: (json['discount_val'] as num?)?.toDouble() ?? 0.0,
      taxVal: (json['tax_val'] as num?)?.toDouble() ?? 0.0,
      taxId: json['tax_id'] as int?, // Nullable
      tax: json['tax'] != null ? TaxModel.fromJson(json['tax'] as Map<String, dynamic>) : null, // Nullable
      quantityAdd: json['quantity_add'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      count: json['count'] is String ? int.parse(json['count'] as String) : (json['count'] as int? ?? 0),
    );
  }
}

class TaxModel {
  final int id;
  final String name;
  final String type;
  final num amount;
  final String? createdAt; // Nullable
  final String updatedAt;

  TaxModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.createdAt,
    required this.updatedAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      createdAt: json['created_at'] as String?, // Nullable
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}