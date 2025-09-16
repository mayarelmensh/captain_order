class OrderItem {
  OrderItem({
    this.id,
    this.notes,
    this.table,
    this.location,
    this.cart,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notes = json['notes'];
    table = json['table'];
    location = json['location'];
    if (json['cart'] != null) {
      cart = <Cart>[];
      json['cart'].forEach((v) {
        cart!.add(Cart.fromJson(v));
      });
    }
  }

  num? id;
  String? notes;
  String? table;
  String? location;
  List<Cart>? cart;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['notes'] = notes;
    map['table'] = table;
    map['location'] = location;
    if (cart != null) {
      map['cart'] = cart!.map((v) => v.toJson()).toList();
    }
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

  Cart.fromJson(Map<String, dynamic> json) {
    if (json['extras'] != null) {
      extras = <Extras>[];
      json['extras'].forEach((v) {
        extras!.add(Extras.fromJson(v));
      });
    }
    if (json['addons'] != null) {
      addons = <CartAddon>[];
      json['addons'].forEach((v) {
        addons!.add(CartAddon.fromJson(v));
      });
    }
    if (json['excludes'] != null) {
      excludes = <Excludes>[];
      json['excludes'].forEach((v) {
        excludes!.add(Excludes.fromJson(v));
      });
    }
    if (json['product'] != null) {
      product = <CartProduct>[];
      json['product'].forEach((v) {
        product!.add(CartProduct.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(Variations.fromJson(v));
      });
    }
  }

  List<Extras>? extras;
  List<CartAddon>? addons;
  List<Excludes>? excludes;
  List<CartProduct>? product;
  List<Variations>? variations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (extras != null) {
      map['extras'] = extras!.map((v) => v.toJson()).toList();
    }
    if (addons != null) {
      map['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    if (excludes != null) {
      map['excludes'] = excludes!.map((v) => v.toJson()).toList();
    }
    if (product != null) {
      map['product'] = product!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      map['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Variations {
  Variations({
    this.variation,
    this.options,
  });

  Variations.fromJson(Map<String, dynamic> json) {
    variation = json['variation'] != null ? Variation.fromJson(json['variation']) : null;
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
  }

  Variation? variation;
  List<Options>? options;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (variation != null) {
      map['variation'] = variation!.toJson();
    }
    if (options != null) {
      map['options'] = options!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Options {
  Options({
    this.id,
    this.name,
    this.price,
    this.totalOptionPrice,
    this.afterDiscount,
    this.priceAfterTax,
    this.productId,
    this.variationId,
    this.status,
    this.points,
    this.createdAt,
    this.updatedAt,
  });

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    totalOptionPrice = json['total_option_price'];
    afterDiscount = json['after_discount'];
    priceAfterTax = json['price_after_tax'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    status = json['status'];
    points = json['points'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  num? price;
  num? totalOptionPrice;
  num? afterDiscount;
  num? priceAfterTax;
  num? productId;
  num? variationId;
  num? status;
  num? points;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['price'] = price;
    map['total_option_price'] = totalOptionPrice;
    map['after_discount'] = afterDiscount;
    map['price_after_tax'] = priceAfterTax;
    map['product_id'] = productId;
    map['variation_id'] = variationId;
    map['status'] = status;
    map['points'] = points;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Variation {
  Variation({
    this.id,
    this.name,
    this.type,
    this.min,
    this.max,
    this.required,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  Variation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    min = json['min'];
    max = json['max'];
    required = json['required'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  String? type;
  num? min;
  num? max;
  num? required;
  num? productId;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['min'] = min;
    map['max'] = max;
    map['required'] = required;
    map['product_id'] = productId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class CartProduct {
  CartProduct({
    this.product,
    this.count,
    this.preparation,
    this.notes,
  });

  CartProduct.fromJson(Map<String, dynamic> json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    count = json['count'];
    preparation = json['preparation'] ?? json['prepration'];
    notes = json['notes'];
  }

  Product? product;
  String? count;
  String? preparation;
  String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (product != null) {
      map['product'] = product!.toJson();
    }
    map['count'] = count;
    map['preparation'] = preparation;
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

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['allExtras'] != null) {
      allExtras = <AllExtras>[];
      json['allExtras'].forEach((v) {
        allExtras!.add(AllExtras.fromJson(v));
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
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    tax = json['tax'];
    if (json['addons'] != null) {
      addons = <Addon>[];
      json['addons'].forEach((v) {
        addons!.add(Addon.fromJson(v));
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
  String? number;
  num? price;
  num? priceAfterDiscount;
  num? priceAfterTax;
  num? productTimeStatus;
  String? from;
  String? to;
  num? discountId;
  num? taxId;
  num? status;
  num? recommended;
  num? points;
  String? imageLink;
  num? ordersCount;
  Discount? discount;
  String? tax;
  List<Addon>? addons;
  bool? favourite;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (allExtras != null) {
      map['allExtras'] = allExtras!.map((v) => v.toJson()).toList();
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
    if (discount != null) {
      map['discount'] = discount!.toJson();
    }
    map['tax'] = tax;
    if (addons != null) {
      map['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    map['favourite'] = favourite;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Addon {
  Addon({
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

  Addon.fromJson(Map<String, dynamic> json) {
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
      map['tax'] = tax!.toJson();
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

  Tax.fromJson(Map<String, dynamic> json) {
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
  String? createdAt;
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

class Discount {
  Discount({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.createdAt,
    this.updatedAt,
  });

  Discount.fromJson(Map<String, dynamic> json) {
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
  String? createdAt;
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

  AllExtras.fromJson(Map<String, dynamic> json) {
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
  num? variationId;
  num? optionId;
  num? min;
  num? max;
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

class Excludes {
  Excludes({
    this.id,
    this.name,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  Excludes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  num? productId;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['product_id'] = productId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class CartAddon {
  CartAddon({
    this.addon,
    this.count,
  });

  CartAddon.fromJson(Map<String, dynamic> json) {
    addon = json['addon'] != null ? Addon.fromJson(json['addon']) : null;
    count = json['count'];
  }

  Addon? addon;
  String? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (addon != null) {
      map['addon'] = addon!.toJson();
    }
    map['count'] = count;
    return map;
  }
}

class Extras {
  Extras({
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

  Extras.fromJson(Map<String, dynamic> json) {
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
  num? variationId;
  num? optionId;
  num? min;
  num? max;
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