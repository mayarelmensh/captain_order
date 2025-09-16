class OrderModels {
  OrderModels({
    this.orders,
  });

  OrderModels.fromJson(dynamic json) {
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders?.add(Orders.fromJson(v));
      });
    }
  }
  List<Orders>? orders;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (orders != null) {
      map['orders'] = orders?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Orders {
  Orders({
    this.id,
    this.tableId,
    this.cart,
    this.date,
    this.amount,
    this.totalTax,
    this.totalDiscount,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.preprationStatus,
    this.captainId,
  });

  Orders.fromJson(dynamic json) {
    id = json['id'];
    tableId = json['table_id'];
    if (json['cart'] != null) {
      cart = [];
      json['cart'].forEach((v) {
        cart?.add(Cart.fromJson(v));
      });
    }
    date = json['date'];
    amount = json['amount'];
    totalTax = json['total_tax'];
    totalDiscount = json['total_discount'];
    notes = json['notes'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    preprationStatus = json['prepration_status'];
    captainId = json['captain_id'];
  }
  num? id;
  num? tableId;
  List<Cart>? cart;
  dynamic date;
  num? amount;
  num? totalTax;
  num? totalDiscount;
  String? notes;
  String? createdAt;
  String? updatedAt;
  String? preprationStatus;
  dynamic captainId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['table_id'] = tableId;
    if (cart != null) {
      map['cart'] = cart?.map((v) => v.toJson()).toList();
    }
    map['date'] = date;
    map['amount'] = amount;
    map['total_tax'] = totalTax;
    map['total_discount'] = totalDiscount;
    map['notes'] = notes;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['prepration_status'] = preprationStatus;
    map['captain_id'] = captainId;
    return map;
  }
}

class Cart {
  Cart({
    this.extras,
    this.addons,
    this.excludes,
    this.product,
    this.variations,
  });

  Cart.fromJson(dynamic json) {
    if (json['extras'] != null) {
      extras = [];
      json['extras'].forEach((v) {
        extras?.add(DynamicItem.fromJson(v));
      });
    }
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(DynamicItem.fromJson(v));
      });
    }
    if (json['excludes'] != null) {
      excludes = [];
      json['excludes'].forEach((v) {
        excludes?.add(DynamicItem.fromJson(v));
      });
    }
    if (json['product'] != null) {
      product = [];
      json['product'].forEach((v) {
        product?.add(CartProduct.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = [];
      json['variations'].forEach((v) {
        variations?.add(DynamicItem.fromJson(v));
      });
    }
  }
  List<DynamicItem>? extras;
  List<DynamicItem>? addons;
  List<DynamicItem>? excludes;
  List<CartProduct>? product;
  List<DynamicItem>? variations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (extras != null) {
      map['extras'] = extras?.map((v) => v.toJson()).toList();
    }
    if (addons != null) {
      map['addons'] = addons?.map((v) => v.toJson()).toList();
    }
    if (excludes != null) {
      map['excludes'] = excludes?.map((v) => v.toJson()).toList();
    }
    if (product != null) {
      map['product'] = product?.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      map['variations'] = variations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DynamicItem {
  DynamicItem({
    this.id,
    this.name,
    this.price,
    this.quantity,
  });

  DynamicItem.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
  }

  num? id;
  String? name;
  num? price;
  num? quantity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['price'] = price;
    map['quantity'] = quantity;
    return map;
  }
}

class CartProduct {
  CartProduct({
    this.product,
    this.count,
    this.prepration,
    this.notes,
  });

  CartProduct.fromJson(dynamic json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    count = json['count'];
    prepration = json['prepration'];
    notes = json['notes'];
  }
  Product? product;
  String? count;
  String? prepration;
  String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (product != null) {
      map['product'] = product?.toJson();
    }
    map['count'] = count;
    map['prepration'] = prepration;
    map['notes'] = notes;
    return map;
  }
}

class Product {
  Product({
    this.id,
    this.allExtras,
    this.taxes,
    this.name,
    this.description,
    this.image,
    this.categoryId,
    this.subCategoryId,
    this.itemType,
    this.stockType,
    this.number,
    this.price,
    this.priceAfterDiscount,
    this.priceAfterTax,
    this.productTimeStatus,
    this.from,
    this.to,
    this.discountId,
    this.taxId,
    this.status,
    this.recommended,
    this.points,
    this.imageLink,
    this.ordersCount,
    this.discount,
    this.tax,
    this.addons,
    this.favourite,
    this.createdAt,
    this.updatedAt,
  });

  Product.fromJson(dynamic json) {
    id = json['id'];
    if (json['allExtras'] != null) {
      allExtras = [];
      json['allExtras'].forEach((v) {
        allExtras?.add(AllExtras.fromJson(v));
      });
    }
    taxes = json['taxes'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    itemType = json['item_type'];
    stockType = json['stock_type'];
    number = json['number'];
    price = json['price'];
    priceAfterDiscount = json['price_after_discount'];
    priceAfterTax = json['price_after_tax'];
    productTimeStatus = json['product_time_status'];
    from = json['from'];
    to = json['to'];
    discountId = json['discount_id'];
    taxId = json['tax_id'];
    status = json['status'];
    recommended = json['recommended'];
    points = json['points'];
    imageLink = json['image_link'];
    ordersCount = json['orders_count'];
    discount = json['discount'];
    tax = json['tax'];
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(Addons.fromJson(v));
      });
    }
    favourite = json['favourite'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  List<AllExtras>? allExtras;
  String? taxes;
  String? name;
  String? description;
  String? image;
  num? categoryId;
  num? subCategoryId;
  String? itemType;
  String? stockType;
  dynamic number;
  num? price;
  num? priceAfterDiscount;
  num? priceAfterTax;
  num? productTimeStatus;
  dynamic from;
  dynamic to;
  num? discountId;
  dynamic taxId;
  num? status;
  num? recommended;
  num? points;
  String? imageLink;
  num? ordersCount;
  dynamic discount;
  dynamic tax;
  List<Addons>? addons;
  bool? favourite;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (allExtras != null) {
      map['allExtras'] = allExtras?.map((v) => v.toJson()).toList();
    }
    map['taxes'] = taxes;
    map['name'] = name;
    map['description'] = description;
    map['image'] = image;
    map['category_id'] = categoryId;
    map['sub_category_id'] = subCategoryId;
    map['item_type'] = itemType;
    map['stock_type'] = stockType;
    map['number'] = number;
    map['price'] = price;
    map['price_after_discount'] = priceAfterDiscount;
    map['price_after_tax'] = priceAfterTax;
    map['product_time_status'] = productTimeStatus;
    map['from'] = from;
    map['to'] = to;
    map['discount_id'] = discountId;
    map['tax_id'] = taxId;
    map['status'] = status;
    map['recommended'] = recommended;
    map['points'] = points;
    map['image_link'] = imageLink;
    map['orders_count'] = ordersCount;
    map['discount'] = discount;
    map['tax'] = tax;
    if (addons != null) {
      map['addons'] = addons?.map((v) => v.toJson()).toList();
    }
    map['favourite'] = favourite;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Addons {
  Addons({
    this.id,
    this.name,
    this.price,
    this.priceAfterTax,
    this.taxId,
    this.quantityAdd,
    this.tax,
    this.createdAt,
    this.updatedAt,
  });

  Addons.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    priceAfterTax = json['price_after_tax'];
    taxId = json['tax_id'];
    quantityAdd = json['quantity_add'];
    tax = json['tax'] != null ? Tax.fromJson(json['tax']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  num? price;
  num? priceAfterTax;
  num? taxId;
  num? quantityAdd;
  Tax? tax;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['price'] = price;
    map['price_after_tax'] = priceAfterTax;
    map['tax_id'] = taxId;
    map['quantity_add'] = quantityAdd;
    if (tax != null) {
      map['tax'] = tax?.toJson();
    }
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Tax {
  Tax({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.createdAt,
    this.updatedAt,
  });

  Tax.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    amount = json['amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  String? type;
  num? amount;
  dynamic createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['amount'] = amount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class AllExtras {
  AllExtras({
    this.id,
    this.priceAfterDiscount,
    this.priceAfterTax,
    this.name,
    this.productId,
    this.variationId,
    this.optionId,
    this.min,
    this.max,
    this.price,
  });

  AllExtras.fromJson(dynamic json) {
    id = json['id'];
    priceAfterDiscount = json['price_after_discount'];
    priceAfterTax = json['price_after_tax'];
    name = json['name'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    optionId = json['option_id'];
    min = json['min'];
    max = json['max'];
    price = json['price'];
  }
  num? id;
  num? priceAfterDiscount;
  num? priceAfterTax;
  String? name;
  num? productId;
  dynamic variationId;
  dynamic optionId;
  dynamic min;
  dynamic max;
  num? price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['price_after_discount'] = priceAfterDiscount;
    map['price_after_tax'] = priceAfterTax;
    map['name'] = name;
    map['product_id'] = productId;
    map['variation_id'] = variationId;
    map['option_id'] = optionId;
    map['min'] = min;
    map['max'] = max;
    map['price'] = price;
    return map;
  }
}