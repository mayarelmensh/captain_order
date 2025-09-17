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
      categories: (json['categories'] as List)
          .map((x) => Category.fromJson(x))
          .toList(),
      products: (json['products'] as List)
          .map((x) => Product.fromJson(x))
          .toList(),
      cafeLocation: (json['cafe_location'] as List)
          .map((x) => CafeLocation.fromJson(x))
          .toList(),
      paymentMethods: (json['payment_methods'] as List)
          .map((x) => PaymentMethod.fromJson(x))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;
  final String bannerImage;
  final int? categoryId;
  final int status;
  final int priority;
  final int active;
  final String imageLink;
  final String bannerLink;
  final List<SubCategory> subCategories;
  final List<Addon> addons;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.bannerImage,
    this.categoryId,
    required this.status,
    required this.priority,
    required this.active,
    required this.imageLink,
    required this.bannerLink,
    required this.subCategories,
    required this.addons,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    bannerImage: json['banner_image'],
    categoryId: json['category_id'],
    status: json['status'],
    priority: json['priority'],
    active: json['active'],
    imageLink: json['image_link'],
    bannerLink: json['banner_link'],
    subCategories: json['sub_categories'] != null
        ? List<SubCategory>.from(
        json['sub_categories'].map((x) => SubCategory.fromJson(x)))
        : [],
    addons: json['addons'] != null
        ? List<Addon>.from(json['addons'].map((x) => Addon.fromJson(x)))
        : [],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}

class SubCategory {
  final int id;
  final String name;
  final String image;
  final String bannerImage;
  final int categoryId;
  final int status;
  final int priority;
  final int active;
  final String imageLink;
  final String bannerLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.bannerImage,
    required this.categoryId,
    required this.status,
    required this.priority,
    required this.active,
    required this.imageLink,
    required this.bannerLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    bannerImage: json['banner_image'],
    categoryId: json['category_id'],
    status: json['status'],
    priority: json['priority'],
    active: json['active'],
    imageLink: json['image_link'],
    bannerLink: json['banner_link'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}

class Product {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final int? subCategoryId;
  final double price;
  final double? priceAfterDiscount;
  final double? priceAfterTax;
  final String imageLink;
  final List<Addon> addons;
  final List<Exclude> excludes;
  final List<Variation> variations;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.subCategoryId,
    required this.price,
    this.priceAfterDiscount,
    this.priceAfterTax,
    required this.imageLink,
    required this.addons,
    required this.excludes,
    required this.variations,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'] == 'null' ? null : json['description'],
    categoryId: json['category_id'],
    subCategoryId: json['sub_category_id'],
    price: (json['price'] as num).toDouble(),
    priceAfterDiscount: json['price_after_discount'] != null
        ? (json['price_after_discount'] as num).toDouble()
        : null,
    priceAfterTax: json['price_after_tax'] != null
        ? (json['price_after_tax'] as num).toDouble()
        : null,
    imageLink: json['image_link'],
    addons: json['addons'] != null
        ? List<Addon>.from(json['addons'].map((x) => Addon.fromJson(x)))
        : [],
    excludes: json['excludes'] != null
        ? List<Exclude>.from(json['excludes'].map((x) => Exclude.fromJson(x)))
        : [],
    variations: json['variations'] != null
        ? List<Variation>.from(json['variations'].map((x) => Variation.fromJson(x)))
        : [],
  );
}

class Addon {
  final int id;
  final String name;
  final double price;
  final int quantityAdd;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.quantityAdd,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    quantityAdd: json['quantity_add'],
  );
}

class Exclude {
  final int id;
  final String name;

  Exclude({
    required this.id,
    required this.name,
  });

  factory Exclude.fromJson(Map<String, dynamic> json) => Exclude(
    id: json['id'],
    name: json['name'],
  );
}

class Variation {
  final int id;
  final String name;
  final String type;
  final int? min;
  final int? max;
  final int required;
  final List<VariationOption> options;

  Variation({
    required this.id,
    required this.name,
    required this.type,
    this.min,
    this.max,
    required this.required,
    required this.options,
  });

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    min: json['min'],
    max: json['max'],
    required: json['required'],
    options: json['options'] != null
        ? List<VariationOption>.from(json['options'].map((x) => VariationOption.fromJson(x)))
        : [],
  );
}

class VariationOption {
  final int id;
  final String name;
  final double price;
  final int productId;
  final int variationId;
  final int status;
  final int points;

  VariationOption({
    required this.id,
    required this.name,
    required this.price,
    required this.productId,
    required this.variationId,
    required this.status,
    required this.points,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) => VariationOption(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    productId: json['product_id'],
    variationId: json['variation_id'],
    status: json['status'],
    points: json['points'],
  );
}

class CafeLocation {
  final int id;
  final String name;
  final int branchId;
  final List<Map<String, double>>? location;
  final List<Table> tables;

  CafeLocation({
    required this.id,
    required this.name,
    required this.branchId,
    this.location,
    required this.tables,
  });

  factory CafeLocation.fromJson(Map<String, dynamic> json) => CafeLocation(
    id: json['id'],
    name: json['name'],
    branchId: json['branch_id'],
    location: json['location'] != null
        ? List<Map<String, double>>.from(json['location'].map((x) => {
      'lat': (x['lat'] as num).toDouble(),
      'lng': (x['lng'] as num).toDouble(),
    }))
        : null,
    tables: List<Table>.from(json['tables'].map((x) => Table.fromJson(x))),
  );
}

class Table {
  final int id;
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
    required this.id,
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
    id: json['id'],
    tableNumber: json['table_number'],
    locationId: json['location_id'],
    branchId: json['branch_id'],
    capacity: json['capacity'],
    qrCode: json['qr_code'],
    status: json['status'],
    currentStatus: json['current_status'],
    occupied: json['occupied'],
    qrCodeLink: json['qr_code_link'],
  );
}

class PaymentMethod {
  final int id;
  final String name;
  final String? description;
  final String logo;
  final int status;
  final String type;
  final int order;
  final String logoLink;

  PaymentMethod({
    required this.id,
    required this.name,
    this.description,
    required this.logo,
    required this.status,
    required this.type,
    required this.order,
    required this.logoLink,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    logo: json['logo'],
    status: json['status'],
    type: json['type'],
    order: json['order'],
    logoLink: json['logo_link'],
  );
}