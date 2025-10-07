// dine_in_order_model.dart

class ProductListResponseModel {
  final List<Category> categories;
  final List<Product> products;
  final List<CafeLocation> cafeLocation;
  final List<PaymentMethod> paymentMethods;

  ProductListResponseModel({
    required this.categories,
    required this.products,
    required this.cafeLocation,
    required this.paymentMethods,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductListResponseModel(
      categories: (json['categories'] as List? ?? [])
          .map((item) => Category.fromJson(item))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((item) => Product.fromJson(item))
          .toList(),
      cafeLocation: (json['cafe_location'] as List? ?? [])
          .map((item) => CafeLocation.fromJson(item))
          .toList(),
      paymentMethods: (json['payment_methods'] as List? ?? [])
          .map((item) => PaymentMethod.fromJson(item))
          .toList(),
    );
  }
}

class Category {
  final int? id;
  final String name;
  final String? image;
  final String? bannerImage;
  final int? categoryId;
  final String? createdAt;
  final String? updatedAt;
  final int? status;
  final int? priority;
  final int? active;
  final String? imageLink;
  final String? bannerLink;
  final List<SubCategory> subCategories;
  final List<Addon> addons;
  final List<Translation> translations;

  Category({
    this.id,
    required this.name,
    this.image,
    this.bannerImage,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.priority,
    this.active,
    this.imageLink,
    this.bannerLink,
    required this.subCategories,
    required this.addons,
    required this.translations,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Unnamed Category',
      image: json['image'] as String?,
      bannerImage: json['banner_image'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      status: json['status'] as int?,
      priority: json['priority'] as int?,
      active: json['active'] as int?,
      imageLink: json['image_link'] as String?,
      bannerLink: json['banner_link'] as String?,
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((item) => SubCategory.fromJson(item))
          .toList(),
      addons: (json['addons'] as List? ?? [])
          .map((item) => Addon.fromJson(item))
          .toList(),
      translations: (json['translations'] as List? ?? [])
          .map((item) => Translation.fromJson(item))
          .toList(),
    );
  }
}

class SubCategory {
  final int? id;
  final String name;
  final String? image;
  final String? bannerImage;
  final int? categoryId;
  final String? createdAt;
  final String? updatedAt;
  final int? status;
  final int? priority;
  final int? active;
  final String? imageLink;
  final String? bannerLink;
  final List<Translation> translations;

  SubCategory({
    this.id,
    required this.name,
    this.image,
    this.bannerImage,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.priority,
    this.active,
    this.imageLink,
    this.bannerLink,
    required this.translations,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Unnamed SubCategory',
      image: json['image'] as String?,
      bannerImage: json['banner_image'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      status: json['status'] as int?,
      priority: json['priority'] as int?,
      active: json['active'] as int?,
      imageLink: json['image_link'] as String?,
      bannerLink: json['banner_link'] as String?,
      translations: (json['translations'] as List? ?? [])
          .map((item) => Translation.fromJson(item))
          .toList(),
    );
  }
}

class Product {
  final int? id;
  final String name;
  final String? description;
  final int? categoryId;
  final int? subCategoryId;
  final double price;
  final double? priceAfterDiscount;
  final double? priceAfterTax;
  final double? taxVal;
  final double? discountVal;
  final String? imageLink;
  final List<Addon> addons;
  final List<Exclude> excludes;
  final List<Variation> variations;
  final List<Extra>? allExtras;
  final Discount? discount;

  Product({
    this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.subCategoryId,
    required this.price,
    this.priceAfterDiscount,
    this.priceAfterTax,
    this.taxVal,
    this.discountVal,
    this.imageLink,
    required this.addons,
    required this.excludes,
    required this.variations,
    this.allExtras,
    this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Product',
    description: json['description'] as String?,
    categoryId: json['category_id'] as int?,
    subCategoryId: json['sub_category_id'] as int?,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    priceAfterDiscount: (json['price_after_discount'] as num?)?.toDouble(),
    priceAfterTax: (json['price_after_tax'] as num?)?.toDouble(),
    taxVal: (json['tax_val'] as num?)?.toDouble(),
    discountVal: (json['discount_val'] as num?)?.toDouble(),
    imageLink: json['image_link'] as String?,
    addons: (json['addons'] as List? ?? [])
        .map((x) => Addon.fromJson(x))
        .toList(),
    excludes: (json['excludes'] as List? ?? [])
        .map((x) => Exclude.fromJson(x))
        .toList(),
    variations: (json['variations'] as List? ?? [])
        .map((x) => Variation.fromJson(x))
        .toList(),
    allExtras: (json['allExtras'] as List? ?? [])
        .map((x) => Extra.fromJson(x))
        .toList(),
    discount: json['discount'] != null ? Discount.fromJson(json['discount']) : null,
  );
}

class Addon {
  final int? id;
  final String name;
  final double price;
  final double? priceAfterTax;
  final double? taxVal;
  final double? discountVal;
  final int? quantityAdd;
  final Tax? tax;

  Addon({
    this.id,
    required this.name,
    required this.price,
    this.priceAfterTax,
    this.taxVal,
    this.discountVal,
    this.quantityAdd,
    this.tax,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Addon',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    priceAfterTax: (json['price_after_tax'] as num?)?.toDouble(),
    taxVal: (json['tax_val'] as num?)?.toDouble(),
    discountVal: (json['discount_val'] as num?)?.toDouble(),
    quantityAdd: json['quantity_add'] as int?,
    tax: json['tax'] != null ? Tax.fromJson(json['tax']) : null,
  );
}

class Exclude {
  final int? id;
  final String name;

  Exclude({
    this.id,
    required this.name,
  });

  factory Exclude.fromJson(Map<String, dynamic> json) => Exclude(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Exclude',
  );
}

class Extra {
  final int? id;
  final String name;
  final double price;
  final int? productId;

  Extra({
    this.id,
    required this.name,
    required this.price,
    this.productId,
  });

  factory Extra.fromJson(Map<String, dynamic> json) => Extra(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Extra',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    productId: json['product_id'] as int?,
  );
}

class Discount {
  final int? id;
  final String? name;
  final String? type;
  final double amount;

  Discount({
    this.id,
    this.name,
    this.type,
    required this.amount,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
    id: json['id'] as int?,
    name: json['name'] as String?,
    type: json['type'] as String?,
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
  );
}

class Tax {
  final int? id;
  final String? name;
  final String? type;
  final double amount;

  Tax({
    this.id,
    this.name,
    this.type,
    required this.amount,
  });

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
    id: json['id'] as int?,
    name: json['name'] as String?,
    type: json['type'] as String?,
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
  );
}

class Variation {
  final int? id;
  final String name;
  final String type;
  final int? min;
  final int? max;
  final int? required;
  final List<VariationOption> options;

  Variation({
    this.id,
    required this.name,
    required this.type,
    this.min,
    this.max,
    this.required,
    required this.options,
  });

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Variation',
    type: json['type'] as String? ?? 'single',
    min: json['min'] as int?,
    max: json['max'] as int?,
    required: json['required'] as int?,
    options: (json['options'] as List? ?? [])
        .map((x) => VariationOption.fromJson(x))
        .toList(),
  );
}

class VariationOption {
  final int? id;
  final String name;
  final double price;
  final int? productId;
  final int? variationId;
  final int? status;
  final int? points;
  final Tax? taxes;
  final List<dynamic>? optionPricing;
  final List<Translation> translations;

  VariationOption({
    this.id,
    required this.name,
    required this.price,
    this.productId,
    this.variationId,
    this.status,
    this.points,
    this.taxes,
    this.optionPricing,
    required this.translations,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) => VariationOption(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Option',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    productId: json['product_id'] as int?,
    variationId: json['variation_id'] as int?,
    status: json['status'] as int?,
    points: json['points'] as int?,
    taxes: json['taxes'] != null ? Tax.fromJson(json['taxes']) : null,
    optionPricing: json['option_pricing'] as List<dynamic>?,
    translations: (json['translations'] as List? ?? [])
        .map((x) => Translation.fromJson(x))
        .toList(),
  );
}

class CafeLocation {
  final int? id;
  final String name;
  final int branchId;
  final List<Map<String, double>>? location;
  final List<Table> tables;

  CafeLocation({
    this.id,
    required this.name,
    required this.branchId,
    this.location,
    required this.tables,
  });

  factory CafeLocation.fromJson(Map<String, dynamic> json) => CafeLocation(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Location',
    branchId: json['branch_id'] as int? ?? 0,
    location: json['location'] != null
        ? List<Map<String, double>>.from(json['location'].map((x) => {
      'lat': (x['lat'] as num?)?.toDouble() ?? 0.0,
      'lng': (x['lng'] as num?)?.toDouble() ?? 0.0,
    }))
        : null,
    tables: (json['tables'] as List? ?? [])
        .map((x) => Table.fromJson(x))
        .toList(),
  );
}

class Table {
  final int? id;
  final String tableNumber;
  final int locationId;
  final int? branchId;
  final int capacity;
  final String? qrCode;
  final int status;
  final String currentStatus;
  final int occupied;
  final String? qrCodeLink;

  Table({
    this.id,
    required this.tableNumber,
    required this.locationId,
    this.branchId,
    required this.capacity,
    this.qrCode,
    required this.status,
    required this.currentStatus,
    required this.occupied,
    this.qrCodeLink,
  });

  factory Table.fromJson(Map<String, dynamic> json) => Table(
    id: json['id'] as int?,
    tableNumber: json['table_number'] as String? ?? 'Unnamed Table',
    locationId: json['location_id'] as int? ?? 0,
    branchId: json['branch_id'] as int?,
    capacity: json['capacity'] as int? ?? 0,
    qrCode: json['qr_code'] as String?,
    status: json['status'] as int? ?? 0,
    currentStatus: json['current_status'] as String? ?? 'Unknown',
    occupied: json['occupied'] as int? ?? 0,
    qrCodeLink: json['qr_code_link'] as String?,
  );
}

class PaymentMethod {
  final int? id;
  final String name;
  final String? description;
  final String logo;
  final int? status;
  final String type;
  final int order;
  final String logoLink;

  PaymentMethod({
    this.id,
    required this.name,
    this.description,
    required this.logo,
    this.status,
    required this.type,
    required this.order,
    required this.logoLink,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'] as int?,
    name: json['name'] as String? ?? 'Unnamed Payment',
    description: json['description'] as String?,
    logo: json['logo'] as String? ?? '',
    status: json['status'] as int?,
    type: json['type'] as String? ?? '',
    order: json['order'] as int? ?? 0,
    logoLink: json['logo_link'] as String? ?? '',
  );
}

class Translation {
  final int? id;
  final String locale;
  final String translatableType;
  final int? translatableId;
  final String key;
  final String value;
  final String? createdAt;
  final String? updatedAt;

  Translation({
    this.id,
    required this.locale,
    required this.translatableType,
    this.translatableId,
    required this.key,
    required this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    id: json['id'] as int?,
    locale: json['locale'] as String? ?? 'en',
    translatableType: json['translatable_type'] as String? ?? '',
    translatableId: json['translatable_id'] as int?,
    key: json['key'] as String? ?? '',
    value: json['value'] as String? ?? '',
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );
}