import 'dart:math';

/// Modèle représentant une borne de recharge YapluCa
class ChargingStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int totalBatteries;
  final int availableBatteries;
  final int availableSlots;
  final bool isActive;
  final String? shopId;
  final double? price;
  final double? depositAmount;
  final String? qrCode;
  
  ChargingStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.totalBatteries,
    required this.availableBatteries,
    required this.availableSlots,
    required this.isActive,
    this.shopId,
    this.price,
    this.depositAmount,
    this.qrCode,
  });
  
  /// Pourcentage de batteries disponibles
  double get availabilityPercentage => 
      totalBatteries > 0 ? (availableBatteries / totalBatteries) * 100 : 0;
  
  /// Indique si la borne a des batteries disponibles
  bool get hasBatteries => availableBatteries > 0;
  
  /// Calcule la distance en kilomètres entre la borne et une position donnée
  /// en utilisant la formule de Haversine
  double calculateDistance(double lat, double lng) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres
    
    // Conversion des degrés en radians
    final double latRad1 = latitude * (pi / 180);
    final double latRad2 = lat * (pi / 180);
    final double lngDiffRad = (lng - longitude) * (pi / 180);
    final double latDiffRad = (lat - latitude) * (pi / 180);
    
    // Formule de Haversine
    final double a = 
        sin(latDiffRad / 2) * sin(latDiffRad / 2) +
        cos(latRad1) * cos(latRad2) * 
        sin(lngDiffRad / 2) * sin(lngDiffRad / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Crée une instance de ChargingStation à partir d'un objet JSON de l'API Bajie Charging
  factory ChargingStation.fromBajieApi(Map<String, dynamic> json) {
    final cabinetData = json['cabinet'] as Map<String, dynamic>;
    final shopData = json['shop'] as Map<String, dynamic>;
    final batteriesData = json['batteries'] as List<dynamic>;
    final priceStrategyData = json['priceStrategy'] as Map<String, dynamic>;
    
    // Calcul du nombre de batteries disponibles
    final int totalSlots = cabinetData['slots'] as int? ?? 0;
    final int emptySlots = cabinetData['emptySlots'] as int? ?? 0;
    final int availableBatteries = batteriesData.length;
    
    return ChargingStation(
      id: cabinetData['id'] as String? ?? '',
      name: shopData['name'] as String? ?? 'Borne sans nom',
      latitude: double.tryParse(shopData['latitude'] as String? ?? '0') ?? 0,
      longitude: double.tryParse(shopData['longitude'] as String? ?? '0') ?? 0,
      address: shopData['address'] as String? ?? '',
      totalBatteries: totalSlots,
      availableBatteries: availableBatteries,
      availableSlots: emptySlots,
      isActive: cabinetData['online'] as bool? ?? false,
      shopId: shopData['id'] as String?,
      price: priceStrategyData['price'] as double?,
      depositAmount: priceStrategyData['depositAmount'] as double?,
      qrCode: cabinetData['qrCode'] as String?,
    );
  }
  
  /// Crée une instance de ChargingStation à partir d'un objet JSON (format ancien)
  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      totalBatteries: json['totalBatteries'] as int,
      availableBatteries: json['availableBatteries'] as int,
      availableSlots: json['availableSlots'] as int? ?? 0,
      isActive: json['isActive'] as bool,
      shopId: json['shopId'] as String?,
      price: json['price'] as double?,
      depositAmount: json['depositAmount'] as double?,
      qrCode: json['qrCode'] as String?,
    );
  }
  
  /// Convertit l'instance en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'totalBatteries': totalBatteries,
      'availableBatteries': availableBatteries,
      'availableSlots': availableSlots,
      'isActive': isActive,
      'shopId': shopId,
      'price': price,
      'depositAmount': depositAmount,
      'qrCode': qrCode,
    };
  }
  
  /// Crée une copie de l'instance avec les champs spécifiés modifiés
  ChargingStation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    int? totalBatteries,
    int? availableBatteries,
    int? availableSlots,
    bool? isActive,
    String? shopId,
    double? price,
    double? depositAmount,
    String? qrCode,
  }) {
    return ChargingStation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      totalBatteries: totalBatteries ?? this.totalBatteries,
      availableBatteries: availableBatteries ?? this.availableBatteries,
      availableSlots: availableSlots ?? this.availableSlots,
      isActive: isActive ?? this.isActive,
      shopId: shopId ?? this.shopId,
      price: price ?? this.price,
      depositAmount: depositAmount ?? this.depositAmount,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
