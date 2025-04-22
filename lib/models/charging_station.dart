class ChargingStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalBatteries;
  final int availability;
  final bool isOpen;
  final String? openingHours;
  final String? imageUrl;
  final String? distance;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalBatteries,
    required this.availability,
    required this.isOpen,
    this.openingHours,
    this.imageUrl,
    this.distance,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      totalBatteries: json['totalBatteries'],
      availability: json['availability'],
      isOpen: json['isOpen'],
      openingHours: json['openingHours'],
      imageUrl: json['imageUrl'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'totalBatteries': totalBatteries,
      'availability': availability,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'imageUrl': imageUrl,
      'distance': distance,
    };
  }
}
