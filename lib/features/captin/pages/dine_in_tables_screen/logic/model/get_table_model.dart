class GetTableModel {
  GetTableModel({
      this.tableStatus,});

  GetTableModel.fromJson(dynamic json) {
    tableStatus = json['table_status'] != null ? json['table_status'].cast<String>() : [];
  }
  List<String>? tableStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['table_status'] = tableStatus;
    return map;
  }

}