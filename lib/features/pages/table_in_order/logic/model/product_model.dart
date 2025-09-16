import 'category_model.dart';

class Product {
  int id;
  List<Extra> allExtras;
  String taxes;
  String name;
  String? description;
  String image;
  int categoryId;
  int? subCategoryId;
  String itemType;
  String stockType;
  int? number;
  double price;
  double priceAfterDiscount;
  double priceAfterTax;
  int productTimeStatus;
  String? from;
  String? to;
  int? discountId;
  int? taxId;
  int status;
  int recommended;
  int points;
  String imageLink;
  int ordersCount;
  Discount? discount;
  Tax? tax;
  List<Addon> addons;
  List<Exclude> excludes;
  List<Variation> variations;
  List<dynamic> salesCount;
  bool favourite;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.allExtras,
    required this.taxes,
    required this.name,
    this.description,
    required this.image,
    required this.categoryId,
    this.subCategoryId,
    required this.itemType,
    required this.stockType,
    this.number,
    required this.price,
    required this.priceAfterDiscount,
    required this.priceAfterTax,
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
    required this.addons,
    required this.excludes,
    required this.variations,
    required this.salesCount,
    required this.favourite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    allExtras: json['allExtras'] != null
        ? List<Extra>.from(json['allExtras'].map((x) => Extra.fromJson(x)))
        : [],
    taxes: json['taxes'],
    name: json['name'],
    description: json['description'] == "null" ? null : json['description'],
    image: json['image'],
    categoryId: json['category_id'],
    subCategoryId: json['sub_category_id'],
    itemType: json['item_type'],
    stockType: json['stock_type'],
    number: json['number'],
    price: (json['price'] as num).toDouble(),
    priceAfterDiscount: (json['price_after_discount'] as num).toDouble(),
    priceAfterTax: (json['price_after_tax'] as num).toDouble(),
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
    discount: json['discount'] != null ? Discount.fromJson(json['discount']) : null,
    tax: json['tax'] != null ? Tax.fromJson(json['tax']) : null,
    addons: json['addons'] != null
        ? List<Addon>.from(json['addons'].map((x) => Addon.fromJson(x)))
        : [],
    excludes: json['excludes'] != null
        ? List<Exclude>.from(json['excludes'].map((x) => Exclude.fromJson(x)))
        : [],
    variations: json['variations'] != null
        ? List<Variation>.from(json['variations'].map((x) => Variation.fromJson(x)))
        : [],
    salesCount: json['sales_count'] ?? [],
    favourite: json['favourite'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'allExtras': List<dynamic>.from(allExtras.map((x) => x.toJson())),
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
    'discount': discount?.toJson(),
    'tax': tax?.toJson(),
    'addons': List<dynamic>.from(addons.map((x) => x.toJson())),
    'excludes': List<dynamic>.from(excludes.map((x) => x.toJson())),
    'variations': List<dynamic>.from(variations.map((x) => x.toJson())),
    'sales_count': salesCount,
    'favourite': favourite,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class Extra {
  int id;
  double priceAfterDiscount;
  double priceAfterTax;
  String name;
  int productId;
  int? variationId;
  int? optionId;
  int? min;
  int? max;
  double price;

  Extra({
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

  factory Extra.fromJson(Map<String, dynamic> json) => Extra(
    id: json['id'],
    priceAfterDiscount: (json['price_after_discount'] as num).toDouble(),
    priceAfterTax: (json['price_after_tax'] as num).toDouble(),
    name: json['name'],
    productId: json['product_id'],
    variationId: json['variation_id'],
    optionId: json['option_id'],
    min: json['min'],
    max: json['max'],
    price: (json['price'] as num).toDouble(),
  );

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

class Discount {
  int id;
  String name;
  String type;
  double amount;

  Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    amount: (json['amount'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'amount': amount,
  };
}

class Exclude {
  int id;
  String name;
  int productId;
  DateTime createdAt;
  DateTime updatedAt;

  Exclude({
    required this.id,
    required this.name,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exclude.fromJson(Map<String, dynamic> json) => Exclude(
    id: json['id'],
    name: json['name'],
    productId: json['product_id'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'product_id': productId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class Variation {
  int id;
  String name;
  String type;
  int? min;
  int? max;
  int required;
  int productId;
  List<Option> options;
  DateTime? createdAt;
  DateTime? updatedAt;

  Variation({
    required this.id,
    required this.name,
    required this.type,
    this.min,
    this.max,
    required this.required,
    required this.productId,
    required this.options,
    this.createdAt,
    this.updatedAt,
  });

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    min: json['min'],
    max: json['max'],
    required: json['required'],
    productId: json['product_id'],
    options: json['options'] != null
        ? List<Option>.from(json['options'].map((x) => Option.fromJson(x)))
        : [],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'min': min,
    'max': max,
    'required': required,
    'product_id': productId,
    'options': List<dynamic>.from(options.map((x) => x.toJson())),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class Option {
  int id;
  String name;
  double price;
  double totalOptionPrice;
  double afterDiscount;
  double priceAfterTax;
  int productId;
  int variationId;
  int status;
  int points;
  DateTime createdAt;
  DateTime updatedAt;

  Option({
    required this.id,
    required this.name,
    required this.price,
    required this.totalOptionPrice,
    required this.afterDiscount,
    required this.priceAfterTax,
    required this.productId,
    required this.variationId,
    required this.status,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    totalOptionPrice: (json['total_option_price'] as num).toDouble(),
    afterDiscount: (json['after_disount'] as num).toDouble(),
    priceAfterTax: (json['price_after_tax'] as num).toDouble(),
    productId: json['product_id'],
    variationId: json['variation_id'],
    status: json['status'],
    points: json['points'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'total_option_price': totalOptionPrice,
    'after_disount': afterDiscount,
    'price_after_tax': priceAfterTax,
    'product_id': productId,
    'variation_id': variationId,
    'status': status,
    'points': points,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}