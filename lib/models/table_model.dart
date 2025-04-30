class TableModel {
  final String? branchId;
  final String? cloudId;
  final String? sellerId;
  final String? tableGroupId;
  final bool? display;
  final bool? enabled;
  final String? id;
  final String? locationName;
  final String? name;
  final String? positionX;
  final String? positionY;
  final String? rotation;
  final String? seats;
  final List<String>? tags;
  final String? type;
  final DateTime? versionDate;

  TableModel({
    this.branchId,
    this.cloudId,
    this.sellerId,
    this.tableGroupId,
    this.display,
    this.enabled,
    this.id,
    this.locationName,
    this.name,
    this.positionX,
    this.positionY,
    this.rotation,
    this.seats,
    this.tags,
    this.type,
    this.versionDate,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      branchId: json['_branchId'] as String?,
      cloudId: json['_cloudId'] as String?,
      sellerId: json['_sellerId'] as String?,
      tableGroupId: json['_tableGroupId'] as String?,
      display: json['display'] as bool?,
      enabled: json['enabled'] as bool?,
      id: json['id'] as String?,
      locationName: json['locationName'] as String?,
      name: json['name'] as String?,
      positionX: json['positionX'] as String?,
      positionY: json['positionY'] as String?,
      rotation: json['rotation'] as String?,
      seats: json['seats'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      type: json['type'] as String?,
      versionDate: json['versionDate'] != null
          ? DateTime.parse(json['versionDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_branchId': branchId,
      '_cloudId': cloudId,
      '_sellerId': sellerId,
      '_tableGroupId': tableGroupId,
      'display': display,
      'enabled': enabled,
      'id': id,
      'locationName': locationName,
      'name': name,
      'positionX': positionX,
      'positionY': positionY,
      'rotation': rotation,
      'seats': seats,
      'tags': tags,
      'type': type,
      'versionDate': versionDate?.toIso8601String(),
    };
  }

  TableModel copyWith({
    String? branchId,
    String? cloudId,
    String? sellerId,
    String? tableGroupId,
    bool? display,
    bool? enabled,
    String? id,
    String? locationName,
    String? name,
    String? positionX,
    String? positionY,
    String? rotation,
    String? seats,
    List<String>? tags,
    String? type,
    DateTime? versionDate,
  }) {
    return TableModel(
      branchId: branchId ?? this.branchId,
      cloudId: cloudId ?? this.cloudId,
      sellerId: sellerId ?? this.sellerId,
      tableGroupId: tableGroupId ?? this.tableGroupId,
      display: display ?? this.display,
      enabled: enabled ?? this.enabled,
      id: id ?? this.id,
      locationName: locationName ?? this.locationName,
      name: name ?? this.name,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      rotation: rotation ?? this.rotation,
      seats: seats ?? this.seats,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      versionDate: versionDate ?? this.versionDate,
    );
  }
}
