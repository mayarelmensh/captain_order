class GetTableOrderModel {
  final List<TableOrder> orders;

  GetTableOrderModel({required this.orders});

  factory GetTableOrderModel.fromJson(Map<String, dynamic> json) {
    return GetTableOrderModel(
      orders: (json['success'] as List<dynamic>?)
          ?.map((item) => TableOrder.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class TableOrder {
  final int id;
  final String name;
  final String prepration;
  final int count;
  final List<TableExtra> allExtras;
  final List<TableExtra> extras;
  final List<TableExclude> excludes;
  final List<TableVariation> variationSelected;
  final List<TableAddon> addonsSelected;
  final String? imageLink;
  final TableDiscount? discount;
  final TableTax? tax;
  final String? description;
  final String? taxes;
  final double? price; // تغيير من int? لـ double?
  final double? priceAfterDiscount; // تغيير من int? لـ double?
  final double? priceAfterTax; // تغيير من int? لـ double?
  final int? discountId;
  final int? taxId;
  final int? cartId;

  TableOrder({
    required this.id,
    required this.name,
    required this.prepration,
    required this.count,
    required this.allExtras,
    required this.extras,
    required this.excludes,
    required this.variationSelected,
    required this.addonsSelected,
    this.imageLink,
    this.discount,
    this.tax,
    this.description,
    this.taxes,
    this.price,
    this.priceAfterDiscount,
    this.priceAfterTax,
    this.discountId,
    this.taxId,
    this.cartId,
  });

  factory TableOrder.fromJson(Map<String, dynamic> json) {
    return TableOrder(
      id: json['id'] as int,
      name: json['name'] as String,
      prepration: json['prepration'] as String,
      count: json['count'] is String ? int.tryParse(json['count']) ?? 0 : (json['count'] as int? ?? 0),
      allExtras: (json['allExtras'] as List<dynamic>?)
          ?.map((e) => TableExtra.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      extras: (json['extras'] as List<dynamic>?)
          ?.map((e) => TableExtra.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      excludes: (json['excludes'] as List<dynamic>?)
          ?.map((e) => TableExclude.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      variationSelected: (json['variation_selected'] as List<dynamic>?)
          ?.map((e) => TableVariation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      addonsSelected: (json['addons_selected'] as List<dynamic>?)
          ?.map((e) => TableAddon.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      imageLink: json['image_link'] as String?,
      discount: json['discount'] != null ? TableDiscount.fromJson(json['discount'] as Map<String, dynamic>) : null,
      tax: json['tax'] != null ? TableTax.fromJson(json['tax'] as Map<String, dynamic>) : null,
      description: json['description'] as String?,
      taxes: json['taxes'] as String?,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double?),
      priceAfterDiscount: (json['price_after_discount'] is int)
          ? (json['price_after_discount'] as int).toDouble()
          : (json['price_after_discount'] as double?),
      priceAfterTax: (json['price_after_tax'] is int)
          ? (json['price_after_tax'] as int).toDouble()
          : (json['price_after_tax'] as double?),
      discountId: json['discount_id'] as int?,
      taxId: json['tax_id'] as int?,
      cartId: json['cart_id'] as int?,
    );
  }
}

class TableExtra {
  final int id;
  final String name;
  final double price; // تغيير من int لـ double

  TableExtra({required this.id, required this.name, required this.price});

  factory TableExtra.fromJson(Map<String, dynamic> json) {
    return TableExtra(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double),
    );
  }
}

class TableExclude {
  final int id;
  final String name;

  TableExclude({required this.id, required this.name});

  factory TableExclude.fromJson(Map<String, dynamic> json) {
    return TableExclude(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class TableVariation {
  final int id;
  final String name;
  final List<TableOption> options;

  TableVariation({required this.id, required this.name, required this.options});

  factory TableVariation.fromJson(Map<String, dynamic> json) {
    return TableVariation(
      id: json['id'] as int,
      name: json['name'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => TableOption.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class TableOption {
  final int id;
  final String name;
  final double price; // تغيير من int لـ double

  TableOption({required this.id, required this.name, required this.price});

  factory TableOption.fromJson(Map<String, dynamic> json) {
    return TableOption(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double),
    );
  }
}

class TableAddon {
  final int id;
  final String name;
  final double price; // تغيير من int لـ double
  final int quantityAdd;
  final TableTax? tax;

  TableAddon({
    required this.id,
    required this.name,
    required this.price,
    required this.quantityAdd,
    this.tax,
  });

  factory TableAddon.fromJson(Map<String, dynamic> json) {
    return TableAddon(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double),
      quantityAdd: json['quantity_add'] as int,
      tax: json['tax'] != null ? TableTax.fromJson(json['tax'] as Map<String, dynamic>) : null,
    );
  }
}

class TableDiscount {
  final int id;
  final String name;
  final String type;
  final int amount;

  TableDiscount({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
  });

  factory TableDiscount.fromJson(Map<String, dynamic> json) {
    return TableDiscount(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
    );
  }
}

class TableTax {
  final int id;
  final String name;
  final String type;
  final int amount;

  TableTax({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
  });

  factory TableTax.fromJson(Map<String, dynamic> json) {
    return TableTax(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
    );
  }
}