import 'package:cloud_firestore/cloud_firestore.dart';

class RentOrderModel {
  final String id;
  final String userId;
  final String stationId;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active', 'completed', 'cancelled'
  final double deposit; // Caution
  final double? cost;
  final String? returnStationId;

  RentOrderModel({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.deposit,
    this.cost,
    this.returnStationId,
  });

  // Calculer la durée de location
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else {
      return DateTime.now().difference(startTime);
    }
  }

  // Vérifier si la location est active
  bool get isActive => status == 'active';

  // Créer un RentOrderModel à partir d'un Map (Firestore document)
  factory RentOrderModel.fromMap(Map<String, dynamic> data, String docId) {
    return RentOrderModel(
      id: docId,
      userId: data['userId'] ?? '',
      stationId: data['stationId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : null,
      status: data['status'] ?? 'active',
      deposit: (data['deposit'] ?? 0.0).toDouble(),
      cost: data['cost'] != null ? (data['cost'] as num).toDouble() : null,
      returnStationId: data['returnStationId'],
    );
  }

  // Convertir RentOrderModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    final map = {
      'userId': userId,
      'stationId': stationId,
      'deviceId': deviceId,
      'startTime': Timestamp.fromDate(startTime),
      'status': status,
      'deposit': deposit,
    };

    // Ajouter les champs optionnels s'ils sont présents
    if (endTime != null) {
      map['endTime'] = Timestamp.fromDate(endTime!);
    }
    if (cost != null) {
      map['cost'] = cost as Object;  // Cast explicite pour éviter l'erreur de nullabilité
    }
    if (returnStationId != null) {
      map['returnStationId'] = returnStationId as Object;  // Cast explicite pour éviter l'erreur de nullabilité
    }

    return map;
  }

  // Créer une copie avec des modifications
  RentOrderModel copyWith({
    String? status,
    DateTime? endTime,
    double? cost,
    String? returnStationId,
  }) {
    return RentOrderModel(
      id: this.id,
      userId: this.userId,
      stationId: this.stationId,
      deviceId: this.deviceId,
      startTime: this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      deposit: this.deposit,
      cost: cost ?? this.cost,
      returnStationId: returnStationId ?? this.returnStationId,
    );
  }
}
