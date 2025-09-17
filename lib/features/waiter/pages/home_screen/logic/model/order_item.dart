class OrderItem {
  OrderItem({
    this.id,
    this.notes,
    this.table,
    this.location,
    this.cart,
    this.kitchen,
  });

  OrderItem.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    notes = json['notes'];
    table = json['table']?.toString();
    location = json['location']?.toString();
    if (json['cart'] != null) {
      cart = [];
      json['cart'].forEach((v) {
        cart?.add(Cart.fromJson(v));
      });
    }
    if (json['kitchen'] != null) {
      kitchen = [];
      json['kitchen'].forEach((v) {
        kitchen?.add(Kitchen.fromJson(v));
      });
    }
  }

  int? id;
  String? notes;
  String? table;
  String? location;
  List<Cart>? cart;
  List<Kitchen>? kitchen;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['notes'] = notes;
    map['table'] = table;
    map['location'] = location;
    if (cart != null) {
      map['cart'] = cart?.map((v) => v.toJson()).toList();
    }
    if (kitchen != null) {
      map['kitchen'] = kitchen?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Kitchen {
  Kitchen({
    this.name,
    this.type,
  });

  Kitchen.fromJson(dynamic json) {
    name = json['name']?.toString();
    type = json['type']?.toString();
  }

  String? name;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = type;
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
        extras?.add(Extras.fromJson(v));
      });
    }
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(Addons.fromJson(v));
      });
    }
    if (json['excludes'] != null) {
      excludes = [];
      json['excludes'].forEach((v) {
        excludes?.add(Excludes.fromJson(v));
      });
    }
    if (json['product'] != null) {
      product = [];
      json['product'].forEach((v) {
        product?.add(Product.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = [];
      json['variations'].forEach((v) {
        variations?.add(Variations.fromJson(v));
      });
    }
  }

  List<Extras>? extras;
  List<Addons>? addons;
  List<Excludes>? excludes;
  List<Product>? product;
  List<Variations>? variations;

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

class Variations {
  Variations({
    this.variation,
  });

  Variations.fromJson(dynamic json) {
    variation = json['variations'] != null ? VariationItem.fromJson(json['variations']) : null;
  }

  VariationItem? variation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (variation != null) {
      map['variations'] = variation?.toJson();
    }
    return map;
  }
}

class VariationItem {
  VariationItem({
    this.id,
    this.name,
  });

  VariationItem.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

class Product {
  Product({
    this.product,
    this.count,
  });

  Product.fromJson(dynamic json) {
    product = json['product'] != null ? ProductItem.fromJson(json['product']) : null;
    count = json['count'] != null ? int.tryParse(json['count'].toString()) : null;
  }

  ProductItem? product;
  int? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (product != null) {
      map['product'] = product?.toJson();
    }
    map['count'] = count;
    return map;
  }
}

class ProductItem {
  ProductItem({
    this.id,
    this.name,
  });

  ProductItem.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

class Excludes {
  Excludes({
    this.id,
    this.name,
  });

  Excludes.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

class Addons {
  Addons({
    this.addon,
    this.count,
  });

  Addons.fromJson(dynamic json) {
    addon = json['addon'] != null ? Addon.fromJson(json['addon']) : null;
    count = json['count'] != null ? int.tryParse(json['count'].toString()) : null;
  }

  Addon? addon;
  int? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (addon != null) {
      map['addon'] = addon?.toJson();
    }
    map['count'] = count;
    return map;
  }
}

class Addon {
  Addon({
    this.id,
    this.name,
  });

  Addon.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

class Extras {
  Extras({
    this.id,
    this.name,
  });

  Extras.fromJson(dynamic json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}