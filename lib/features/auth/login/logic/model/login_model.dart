class LoginResponse {
  final CaptainOrder? captainOrder;
  final String? token;

  LoginResponse({this.captainOrder, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      captainOrder: json['user'] != null ? CaptainOrder.fromJson(json['user']) : null,
      token: json['token'] ?? json['user']?['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': captainOrder?.toJson(),
      'token': token,
    };
  }
}

class CaptainOrder {
  final int? id;
  final int? branchId;
  final String? name;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;
  final String? image;
  final String? userName;
  final int? status;
  final String? role;
  final String? token;
  final String? imageLink;

  CaptainOrder({
    this.id,
    this.branchId,
    this.name,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.image,
    this.userName,
    this.status,
    this.role,
    this.token,
    this.imageLink,
  });

  factory CaptainOrder.fromJson(Map<String, dynamic> json) {
    return CaptainOrder(
      id: json['id'],
      branchId: json['branch_id'],
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      image: json['image'],
      userName: json['user_name'],
      status: json['status'],
      role: json['role'],
      token: json['token'],
      imageLink: json['image_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image': image,
      'user_name': userName,
      'status': status,
      'role': role,
      'token': token,
      'image_link': imageLink,
    };
  }
}
