
class LoginResponse {
  final CaptainOrder captainOrder;
  final String token;

  LoginResponse({
    required this.captainOrder,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      captainOrder: CaptainOrder.fromJson(json['captain_order']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'captain_order': captainOrder.toJson(),
      'token': token,
    };
  }
}

class CaptainOrder {
  final int id;
  final int branchId;
  final String name;
  final String phone;
  final String createdAt;
  final String updatedAt;
  final String image;
  final String userName;
  final int status;
  final String role;
  final String token;
  final String imageLink;

  CaptainOrder({
    required this.id,
    required this.branchId,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.userName,
    required this.status,
    required this.role,
    required this.token,
    required this.imageLink,
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