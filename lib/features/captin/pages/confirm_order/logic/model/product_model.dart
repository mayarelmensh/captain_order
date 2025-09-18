import 'dart:convert';

class ProductResponse {
  final List<ProductModel> success;

  ProductResponse({required this.success});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: (json['success'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success.map((e) => e.toJson()).toList(),
  };
}

class ProductModel {
  final int id;
  final List<ExtraModel> allExtras;
  final String taxes;
  final String name;
  final String description;
  final String? image;
  final int categoryId;
  final int subCategoryId;
  final String itemType;
  final String stockType;
  final String? number;
  final double price;
  final double priceAfterDiscount;
  final double priceAfterTax;
  final double discountVal;
  final double taxVal;
  final int productTimeStatus;
  final String? from;
  final String? to;
  final int? discountId;
  final int? taxId;
  final int status;
  final int recommended;
  final int points;
  final String imageLink;
  final int ordersCount;
  final dynamic discount;
  final dynamic tax;
  final bool favourite;
  final String createdAt;
  final String updatedAt;
  final int cartId;
  final int productIndex;
  final String count;
  final String prepration;
  final List<ExcludeModel> excludes;
  final List<ExtraModel> extras;
  final List<VariationSelectedModel> variationSelected;
  final List<AddonSelectedModel> addonsSelected;

  ProductModel({
    required this.id,
    required this.allExtras,
    required this.taxes,
    required this.name,
    required this.description,
    this.image,
    required this.categoryId,
    required this.subCategoryId,
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
      id: json['id'],
      allExtras: (json['allExtras'] as List)
          .map((e) => ExtraModel.fromJson(e))
          .toList(),
      taxes: json['taxes'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      itemType: json['item_type'],
      stockType: json['stock_type'],
      number: json['number'],
      price: json['price'].toDouble(),
      priceAfterDiscount: json['price_after_discount'].toDouble(),
      priceAfterTax: json['price_after_tax'].toDouble(),
      discountVal: json['discount_val'].toDouble(),
      taxVal: json['tax_val'].toDouble(),
      productTimeStatus: json['product_time_status'],
      from: json['from'],
      to: json['to'],
      discountId: json['discount_id'],
      taxId: json['tax_id'],
      status: json['status'],
      recommended: json['recommended'],
      points: json['points'],
      imageLink: json['image_link'],
      ordersCount: json['orders_count'],
      discount: json['discount'],
      tax: json['tax'],
      favourite: json['favourite'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      cartId: json['cart_id'],
      productIndex: json['product_index'],
      count: json['count'],
      prepration: json['prepration'],
      excludes: (json['excludes'] as List)
          .map((e) => ExcludeModel.fromJson(e))
          .toList(),
      extras: (json['extras'] as List)
          .map((e) => ExtraModel.fromJson(e))
          .toList(),
      variationSelected: (json['variation_selected'] as List)
          .map((e) => VariationSelectedModel.fromJson(e))
          .toList(),
      addonsSelected: (json['addons_selected'] as List)
          .map((e) => AddonSelectedModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'allExtras': allExtras.map((e) => e.toJson()).toList(),
    'taxes': taxes,
    'name': name,
    'description': description,
    'image': image,
    'category_id': categoryId,
    'sub_category_id': subCategoryId,
    'item_type': itemType,
    'stock_type': stockType,
    'number': number,
    'price': price,
    'price_after_discount': priceAfterDiscount,
    'price_after_tax': priceAfterTax,
    'discount_val': discountVal,
    'tax_val': taxVal,
    'product_time_status': productTimeStatus,
    'from': from,
    'to': to,
    'discount_id': discountId,
    'tax_id': taxId,
    'status': status,
    'recommended': recommended,
    'points': points,
    'image_link': imageLink,
    'orders_count': ordersCount,
    'discount': discount,
    'tax': tax,
    'favourite': favourite,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'cart_id': cartId,
    'product_index': productIndex,
    'count': count,
    'prepration': prepration,
    'excludes': excludes.map((e) => e.toJson()).toList(),
    'extras': extras.map((e) => e.toJson()).toList(),
    'variation_selected': variationSelected.map((e) => e.toJson()).toList(),
    'addons_selected': addonsSelected.map((e) => e.toJson()).toList(),
  };
}

class ExtraModel {
  final int id;
  final double priceAfterDiscount;
  final double priceAfterTax;
  final String name;
  final int productId;
  final int? variationId;
  final int? optionId;
  final int? min;
  final int? max;
  final double price;

  ExtraModel({
    required this.id,
    required this.priceAfterDiscount,
    required this.priceAfterTax,
    required this.name,
    required this.productId,
    this.variationId,
    this.optionId,
    this.min,
    this.max,
    required this.price,
  });

  factory ExtraModel.fromJson(Map<String, dynamic> json) {
    return ExtraModel(
      id: json['id'],
      priceAfterDiscount: json['price_after_discount'].toDouble(),
      priceAfterTax: json['price_after_tax'].toDouble(),
      name: json['name'],
      productId: json['product_id'],
      variationId: json['variation_id'],
      optionId: json['option_id'],
      min: json['min'],
      max: json['max'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'price_after_discount': priceAfterDiscount,
    'price_after_tax': priceAfterTax,
    'name': name,
    'product_id': productId,
    'variation_id': variationId,
    'option_id': optionId,
    'min': min,
    'max': max,
    'price': price,
  };
}

class ExcludeModel {
  final int id;
  final String name;
  final int productId;
  final String createdAt;
  final String updatedAt;

  ExcludeModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExcludeModel.fromJson(Map<String, dynamic> json) {
    return ExcludeModel(
      id: json['id'],
      name: json['name'],
      productId: json['product_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'product_id': productId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class VariationSelectedModel {
  final int id;
  final String name;
  final String type;
  final int min;
  final int max;
  final int required;
  final int productId;
  final String createdAt;
  final String updatedAt;
  final List<OptionModel> options;

  VariationSelectedModel({
    required this.id,
    required this.name,
    required this.type,
    required this.min,
    required this.max,
    required this.required,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory VariationSelectedModel.fromJson(Map<String, dynamic> json) {
    return VariationSelectedModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      min: json['min'],
      max: json['max'],
      required: json['required'],
      productId: json['product_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      options:
      (json['options'] as List).map((e) => OptionModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'min': min,
    'max': max,
    'required': required,
    'product_id': productId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'options': options.map((e) => e.toJson()).toList(),
  };
}

class OptionModel {
  final int id;
  final String name;
  final double price;
  final double totalOptionPrice;
  final double afterDiscount;
  final double priceAfterTax;
  final double discountVal;
  final double taxVal;
  final int productId;
  final int variationId;
  final int status;
  final int points;
  final String createdAt;
  final String updatedAt;

  OptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.totalOptionPrice,
    required this.afterDiscount,
    required this.priceAfterTax,
    required this.discountVal,
    required this.taxVal,
    required this.productId,
    required this.variationId,
    required this.status,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      totalOptionPrice: json['total_option_price'].toDouble(),
      afterDiscount: json['after_disount'].toDouble(),
      priceAfterTax: json['price_after_tax'].toDouble(),
      discountVal: json['discount_val'].toDouble(),
      taxVal: json['tax_val'].toDouble(),
      productId: json['product_id'],
      variationId: json['variation_id'],
      status: json['status'],
      points: json['points'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'total_option_price': totalOptionPrice,
    'after_disount': afterDiscount,
    'price_after_tax': priceAfterTax,
    'discount_val': discountVal,
    'tax_val': taxVal,
    'product_id': productId,
    'variation_id': variationId,
    'status': status,
    'points': points,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class AddonSelectedModel {
  final int id;
  final String name;
  final double price;
  final double priceAfterTax;
  final double discountVal;
  final double taxVal;
  final int taxId;
  final int quantityAdd;
  final TaxModel tax;
  final String createdAt;
  final String updatedAt;
  final String count;

  AddonSelectedModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceAfterTax,
    required this.discountVal,
    required this.taxVal,
    required this.taxId,
    required this.quantityAdd,
    required this.tax,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
  });

  factory AddonSelectedModel.fromJson(Map<String, dynamic> json) {
    return AddonSelectedModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      priceAfterTax: json['price_after_tax'].toDouble(),
      discountVal: json['discount_val'].toDouble(),
      taxVal: json['tax_val'].toDouble(),
      taxId: json['tax_id'],
      quantityAdd: json['quantity_add'],
      tax: TaxModel.fromJson(json['tax']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'price_after_tax': priceAfterTax,
    'discount_val': discountVal,
    'tax_val': taxVal,
    'tax_id': taxId,
    'quantity_add': quantityAdd,
    'tax': tax.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
    'count': count,
  };
}

class TaxModel {
  final int id;
  final String name;
  final String type;
  final double amount;
  final String createdAt;
  final String updatedAt;

  TaxModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'amount': amount,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}