class Category {
  int id;
  String name;
  String image;
  String bannerImage;
  int? categoryId;
  int status;
  int priority;
  int active;
  String imageLink;
  String bannerLink;
  List<SubCategory> subCategories;
  List<Addon> addons;
  DateTime createdAt;
  DateTime updatedAt;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'banner_image': bannerImage,
    'category_id': categoryId,
    'status': status,
    'priority': priority,
    'active': active,
    'image_link': imageLink,
    'banner_link': bannerLink,
    'sub_categories': List<dynamic>.from(subCategories.map((x) => x.toJson())),
    'addons': List<dynamic>.from(addons.map((x) => x.toJson())),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class SubCategory {
  int id;
  String name;
  String image;
  String bannerImage;
  int categoryId;
  int status;
  int priority;
  int active;
  String imageLink;
  String bannerLink;
  DateTime createdAt;
  DateTime updatedAt;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'banner_image': bannerImage,
    'category_id': categoryId,
    'status': status,
    'priority': priority,
    'active': active,
    'image_link': imageLink,
    'banner_link': bannerLink,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class Addon {
  int id;
  String name;
  double price;
  double priceAfterTax;
  int taxId;
  int quantityAdd;
  Tax? tax;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.priceAfterTax,
    required this.taxId,
    required this.quantityAdd,
    this.tax,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    priceAfterTax: (json['price_after_tax'] as num).toDouble(),
    taxId: json['tax_id'],
    quantityAdd: json['quantity_add'],
    tax: json['tax'] != null ? Tax.fromJson(json['tax']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'price_after_tax': priceAfterTax,
    'tax_id': taxId,
    'quantity_add': quantityAdd,
    'tax': tax?.toJson(),
  };
}

class Tax {
  int id;
  String name;
  String type;
  double amount;

  Tax({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
  });

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
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