import 'battery_model.dart';
import 'cabinet_model.dart';
import 'price_strategy_model.dart';
import 'shop_model.dart';

class DeviceInfo {
  final PriceStrategy? priceStrategy;
  final Shop? shop;
  final List<Battery>? batteries;
  final Cabinet? cabinet;

  DeviceInfo({
    this.priceStrategy,
    this.shop,
    this.batteries,
    this.cabinet,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      priceStrategy: json['priceStrategy'] != null
          ? PriceStrategy.fromJson(json['priceStrategy'] as Map<String, dynamic>)
          : null,
      shop: json['shop'] != null
          ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      batteries: (json['batteries'] as List<dynamic>?)
          ?.map((e) => Battery.fromJson(e as Map<String, dynamic>))
          .toList(),
      cabinet: json['cabinet'] != null
          ? Cabinet.fromJson(json['cabinet'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceStrategy': priceStrategy?.toJson(),
      'shop': shop?.toJson(),
      'batteries': batteries?.map((e) => e.toJson()).toList(),
      'cabinet': cabinet?.toJson(),
    };
  }
}
