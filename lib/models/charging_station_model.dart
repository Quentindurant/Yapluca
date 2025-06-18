import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class ChargingStationModel {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final int totalBatteries;
  final int availableBatteries;
  final String status; // 'active', 'maintenance', 'inactive'
  final double? rating;
  final DateTime? lastUpdated;
  final String? connectorTypeId; // Ajout du type de connecteur

  ChargingStationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.totalBatteries,
    required this.availableBatteries,
    required this.status,
    this.rating,
    this.lastUpdated,
    this.connectorTypeId,
  });

  // Convertir en LatLng pour Flutter Map (OpenStreetMap)
  latlong2.LatLng get latLng => latlong2.LatLng(location.latitude, location.longitude);

  // Vérifier si la station a des batteries disponibles
  bool get hasBatteries => availableBatteries > 0;

  // Vérifier si la station est active
  bool get isActive => status == 'active';

  // Créer un ChargingStationModel à partir d'un Map (Firestore document)
  factory ChargingStationModel.fromMap(Map<String, dynamic> data, String docId) {
    return ChargingStationModel(
      id: docId,
      name: data['name'] ?? 'Station sans nom',
      address: data['address'] ?? 'Adresse inconnue',
      location: data['location'] ?? const GeoPoint(0, 0),
      totalBatteries: data['totalBatteries'] ?? 0,
      availableBatteries: data['availableBatteries'] ?? 0,
      status: data['status'] ?? 'inactive',
      rating: (data['rating'] ?? 0.0).toDouble(),
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : null,
      connectorTypeId: data['connectorTypeId'],
    );
  }

  // Convertir ChargingStationModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'location': location,
      'totalBatteries': totalBatteries,
      'availableBatteries': availableBatteries,
      'connectorTypeId': connectorTypeId,
      'status': status,
      'rating': rating,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Créer une copie avec des modifications
  ChargingStationModel copyWith({
    String? name,
    String? address,
    GeoPoint? location,
    int? totalBatteries,
    int? availableBatteries,
    String? status,
    double? rating,
  }) {
    return ChargingStationModel(
      id: this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      totalBatteries: totalBatteries ?? this.totalBatteries,
      availableBatteries: availableBatteries ?? this.availableBatteries,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      lastUpdated: DateTime.now(),
    );
  }
}
