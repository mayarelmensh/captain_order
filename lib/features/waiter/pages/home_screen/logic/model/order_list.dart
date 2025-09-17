class OrderList {
  OrderList({
      this.orders,});

  OrderList.fromJson(dynamic json) {
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
      this.notes,
      this.table,
      this.location,});

  Orders.fromJson(dynamic json) {
    id = json['id'];
    notes = json['notes'];
    table = json['table'];
    location = json['location'];
  }
  num? id;
  String? notes;
  String? table;
  String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['notes'] = notes;
    map['table'] = table;
    map['location'] = location;
    return map;
  }

}