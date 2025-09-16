class LocationModel {
  final double lat;
  final double lng;

  LocationModel({
    required this.lat,
    required this.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class TableModel {
  final int id;
  final String tableNumber;
  final int locationId;
  final int? branchId;
  final int capacity;
  final String? qrCode;  // nullable
  final int status;
  final String? createdAt;  // nullable
  final String updatedAt;
  final String currentStatus;
  final int occupied;
  final String? qrCodeLink;  // nullable

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.locationId,
    this.branchId,
    required this.capacity,
    this.qrCode,
    required this.status,
    this.createdAt,
    required this.updatedAt,
    required this.currentStatus,
    required this.occupied,
    this.qrCodeLink,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as int,
      tableNumber: json['table_number'] as String,
      locationId: json['location_id'] as int,
      branchId: json['branch_id'] as int?,
      capacity: json['capacity'] as int,
      qrCode: json['qr_code'] as String?,  // safe for null
      status: json['status'] as int,
      createdAt: json['created_at'] as String?,  // safe for null
      updatedAt: json['updated_at'] as String,
      currentStatus: json['current_status'] as String,
      occupied: json['occupied'] as int,
      qrCodeLink: json['qr_code_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'location_id': locationId,
      'branch_id': branchId,
      'capacity': capacity,
      'qr_code': qrCode,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'current_status': currentStatus,
      'occupied': occupied,
      'qr_code_link': qrCodeLink,
    };
  }
}

class CafeLocationModel {
  final int id;
  final String name;
  final String? createdAt;  // nullable
  final String updatedAt;
  final int branchId;
  final List<LocationModel>? location;  // nullable list
  final List<TableModel> tables;

  CafeLocationModel({
    required this.id,
    required this.name,
    this.createdAt,
    required this.updatedAt,
    required this.branchId,
    this.location,
    required this.tables,
  });

  factory CafeLocationModel.fromJson(Map<String, dynamic> json) {
    return CafeLocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,  // safe for null
      updatedAt: json['updated_at'] as String,
      branchId: json['branch_id'] as int,
      location: json['location'] != null
          ? (json['location'] as List<dynamic>)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      tables: (json['tables'] as List<dynamic>)
          .map((e) => TableModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'branch_id': branchId,
      'location': location?.map((e) => e.toJson()).toList(),
      'tables': tables.map((e) => e.toJson()).toList(),
    };
  }
}

class FinancialAccountModel {
  final int id;
  final String name;
  final String details;
  final String logo;
  final String logoLink;

  FinancialAccountModel({
    required this.id,
    required this.name,
    required this.details,
    required this.logo,
    required this.logoLink,
  });

  factory FinancialAccountModel.fromJson(Map<String, dynamic> json) {
    return FinancialAccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      details: json['details'] as String,
      logo: json['logo'] as String,
      logoLink: json['logo_link'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'logo': logo,
      'logo_link': logoLink,
    };
  }
}

class PaymentMethodModel {
  final int id;
  final String name;
  final String? description;  // nullable
  final String logo;
  final int status;
  final String? createdAt;  // nullable
  final String updatedAt;
  final String type;
  final int order;
  final String logoLink;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.description,
    required this.logo,
    required this.status,
    this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.order,
    required this.logoLink,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,  // safe for null
      logo: json['logo'] as String,
      status: json['status'] as int,
      createdAt: json['created_at'] as String?,  // safe for null
      updatedAt: json['updated_at'] as String,
      type: json['type'] as String,
      order: json['order'] as int,
      logoLink: json['logo_link'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'order': order,
      'logo_link': logoLink,
    };
  }
}

class CafeResponseModel {
  final List<CafeLocationModel> cafeLocation;
  final List<FinancialAccountModel> financialAccount;
  final List<PaymentMethodModel> paymentMethod;

  CafeResponseModel({
    required this.cafeLocation,
    required this.financialAccount,
    required this.paymentMethod,
  });

  factory CafeResponseModel.fromJson(Map<String, dynamic> json) {
    return CafeResponseModel(
      cafeLocation: (json['cafe_location'] as List<dynamic>)
          .map((e) => CafeLocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      financialAccount: (json['financial_account'] as List<dynamic>)
          .map((e) => FinancialAccountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethod: (json['paymentMethod'] as List<dynamic>)
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cafe_location': cafeLocation.map((e) => e.toJson()).toList(),
      'financial_account': financialAccount.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod.map((e) => e.toJson()).toList(),
    };
  }
}