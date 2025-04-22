class Cabinet {
  final String? ip;
  final String? remark;
  final String? type;
  final int? slots;
  final String? qrCode;
  final bool? online;
  final int? emptySlots;
  final int? busySlots;
  final String? id;
  final String? shopId;
  final String? signal;
  final String? posDeviceId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? name;
  final int? availableBatteries;
  final int? totalBatteries;
  final bool? isActive;

  Cabinet({
    this.ip,
    this.remark,
    this.type,
    this.slots,
    this.qrCode,
    this.online,
    this.emptySlots,
    this.busySlots,
    this.id,
    this.shopId,
    this.signal,
    this.posDeviceId,
    this.latitude,
    this.longitude,
    this.address,
    this.name,
    this.availableBatteries,
    this.totalBatteries,
    this.isActive,
  });

  factory Cabinet.fromJson(Map<String, dynamic> json) {
    return Cabinet(
      ip: json['ip'] as String?,
      remark: json['remark'] as String?,
      type: json['type'] as String?,
      slots: json['slots'] as int?,
      qrCode: json['qrCode'] as String?,
      online: json['online'] as bool?,
      emptySlots: json['emptySlots'] as int?,
      busySlots: json['busySlots'] as int?,
      id: json['id'] as String?,
      shopId: json['shopId'] as String?,
      signal: json['signal'] as String?,
      posDeviceId: json['posDeviceId'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      address: json['address'] as String?,
      name: json['name'] as String?,
      availableBatteries: json['availableBatteries'] as int? ?? json['emptySlots'] as int?,
      totalBatteries: json['totalBatteries'] as int? ?? json['slots'] as int?,
      isActive: json['isActive'] as bool? ?? json['online'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'remark': remark,
      'type': type,
      'slots': slots,
      'qrCode': qrCode,
      'online': online,
      'emptySlots': emptySlots,
      'busySlots': busySlots,
      'id': id,
      'shopId': shopId,
      'signal': signal,
      'posDeviceId': posDeviceId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'name': name,
      'availableBatteries': availableBatteries,
      'totalBatteries': totalBatteries,
      'isActive': isActive,
    };
  }
}
