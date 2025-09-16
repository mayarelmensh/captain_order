// // Root Response Model
// class CafeResponse {
//   final List<CafeLocation> cafeLocation;
//   final List<FinancialAccount> financialAccount;
//   final List<PaymentMethod> paymentMethod;
//
//   CafeResponse({
//     required this.cafeLocation,
//     required this.financialAccount,
//     required this.paymentMethod,
//   });
//
//   factory CafeResponse.fromJson(Map<String, dynamic> json) {
//     return CafeResponse(
//       cafeLocation: (json['cafe_location'] as List)
//           .map((e) => CafeLocation.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       financialAccount: (json['financial_account'] as List)
//           .map((e) => FinancialAccount.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       paymentMethod: (json['paymentMethod'] as List)
//           .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'cafe_location': cafeLocation.map((e) => e.toJson()).toList(),
//       'financial_account': financialAccount.map((e) => e.toJson()).toList(),
//       'paymentMethod': paymentMethod.map((e) => e.toJson()).toList(),
//     };
//   }
// }
//
// // CafeLocation Model
// class CafeLocation {
//   final int id;
//   final String name;
//   final String? createdAt;
//   final String? updatedAt;
//   final int branchId;
//   final List<LocationCoordinate>? location;
//   final List<Table> tables;
//
//   CafeLocation({
//     required this.id,
//     required this.name,
//     this.createdAt,
//     this.updatedAt,
//     required this.branchId,
//     this.location,
//     required this.tables,
//   });
//
//   factory CafeLocation.fromJson(Map<String, dynamic> json) {
//     return CafeLocation(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       createdAt: json['created_at'] as String?,
//       updatedAt: json['updated_at'] as String?,
//       branchId: json['branch_id'] as int,
//       location: json['location'] != null
//           ? (json['location'] as List)
//           .map((e) => LocationCoordinate.fromJson(e as Map<String, dynamic>))
//           .toList()
//           : null,
//       tables: (json['tables'] as List)
//           .map((e) => Table.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'branch_id': branchId,
//       'location': location?.map((e) => e.toJson()).toList(),
//       'tables': tables.map((e) => e.toJson()).toList(),
//     };
//   }
// }
//
// // LocationCoordinate Model
// class LocationCoordinate {
//   final double lat;
//   final double lng;
//
//   LocationCoordinate({
//     required this.lat,
//     required this.lng,
//   });
//
//   factory LocationCoordinate.fromJson(Map<String, dynamic> json) {
//     return LocationCoordinate(
//       lat: (json['lat'] as num).toDouble(),
//       lng: (json['lng'] as num).toDouble(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'lat': lat,
//       'lng': lng,
//     };
//   }
// }
//
// // Table Model
// class Table {
//   final int id;
//   final String tableNumber;
//   final int locationId;
//   final int? branchId;
//   final int capacity;
//   final String? qrCode;
//   final int status;
//   final String? createdAt;
//   final String? updatedAt;
//   final String currentStatus;
//   final int occupied;
//   final String? qrCodeLink;
//
//   Table({
//     required this.id,
//     required this.tableNumber,
//     required this.locationId,
//     this.branchId,
//     required this.capacity,
//     this.qrCode,
//     required this.status,
//     this.createdAt,
//     this.updatedAt,
//     required this.currentStatus,
//     required this.occupied,
//     this.qrCodeLink,
//   });
//
//   factory Table.fromJson(Map<String, dynamic> json) {
//     return Table(
//       id: json['id'] as int,
//       tableNumber: json['table_number'] as String,
//       locationId: json['location_id'] as int,
//       branchId: json['branch_id'] as int?,
//       capacity: json['capacity'] as int,
//       qrCode: json['qr_code'] as String?,
//       status: json['status'] as int,
//       createdAt: json['created_at'] as String?,
//       updatedAt: json['updated_at'] as String?,
//       currentStatus: json['current_status'] as String,
//       occupied: json['occupied'] as int,
//       qrCodeLink: json['qr_code_link'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'table_number': tableNumber,
//       'location_id': locationId,
//       'branch_id': branchId,
//       'capacity': capacity,
//       'qr_code': qrCode,
//       'status': status,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'current_status': currentStatus,
//       'occupied': occupied,
//       'qr_code_link': qrCodeLink,
//     };
//   }
// }
//
// // FinancialAccount Model
// class FinancialAccount {
//   final int id;
//   final String name;
//   final String details;
//   final String logo;
//   final String logoLink;
//
//   FinancialAccount({
//     required this.id,
//     required this.name,
//     required this.details,
//     required this.logo,
//     required this.logoLink,
//   });
//
//   factory FinancialAccount.fromJson(Map<String, dynamic> json) {
//     return FinancialAccount(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       details: json['details'] as String,
//       logo: json['logo'] as String,
//       logoLink: json['logo_link'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'details': details,
//       'logo': logo,
//       'logo_link': logoLink,
//     };
//   }
// }
//
// // PaymentMethod Model
// class PaymentMethod {
//   final int id;
//   final String name;
//   final String? description;
//   final String logo;
//   final int status;
//   final String? createdAt;
//   final String? updatedAt;
//   final String type;
//   final int order;
//   final String logoLink;
//
//   PaymentMethod({
//     required this.id,
//     required this.name,
//     this.description,
//     required this.logo,
//     required this.status,
//     this.createdAt,
//     this.updatedAt,
//     required this.type,
//     required this.order,
//     required this.logoLink,
//   });
//
//   factory PaymentMethod.fromJson(Map<String, dynamic> json) {
//     return PaymentMethod(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       description: json['description'] as String?,
//       logo: json['logo'] as String,
//       status: json['status'] as int,
//       createdAt: json['created_at'] as String?,
//       updatedAt: json['updated_at'] as String?,
//       type: json['type'] as String,
//       order: json['order'] as int,
//       logoLink: json['logo_link'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'logo': logo,
//       'status': status,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'type': type,
//       'order': order,
//       'logo_link': logoLink,
//     };
//   }
// }