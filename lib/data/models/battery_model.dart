class Battery {
  final int? slotNum;
  final int? vol;
  final String? batteryId;

  Battery({
    this.slotNum,
    this.vol,
    this.batteryId,
  });

  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      slotNum: json['slotNum'] as int?,
      vol: json['vol'] as int?,
      batteryId: json['batteryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slotNum': slotNum,
      'vol': vol,
      'batteryId': batteryId,
    };
  }
}
