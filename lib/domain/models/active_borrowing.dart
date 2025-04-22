import 'package:flutter/foundation.dart';

/// Représente un emprunt actif de batterie
class ActiveBorrowing {
  /// Identifiant unique de l'emprunt
  final String id;
  
  /// Identifiant de la batterie empruntée
  final String batteryId;
  
  /// Identifiant de la borne d'où la batterie a été empruntée
  final String stationId;
  
  /// Nom de la borne d'où la batterie a été empruntée
  final String stationName;
  
  /// Date et heure de l'emprunt
  final DateTime borrowingTime;
  
  /// Montant de la caution en euros
  final double depositAmount;
  
  /// Durée maximale d'emprunt en heures
  final int maxDurationHours;
  
  /// Niveau de charge de la batterie (en pourcentage)
  final int batteryLevel;

  /// Crée une nouvelle instance d'un emprunt actif
  ActiveBorrowing({
    required this.id,
    required this.batteryId,
    required this.stationId,
    required this.stationName,
    required this.borrowingTime,
    required this.depositAmount,
    required this.maxDurationHours,
    required this.batteryLevel,
  });

  /// Crée une instance d'ActiveBorrowing à partir d'un Map
  factory ActiveBorrowing.fromJson(Map<String, dynamic> json) {
    return ActiveBorrowing(
      id: json['id'] as String,
      batteryId: json['batteryId'] as String,
      stationId: json['stationId'] as String,
      stationName: json['stationName'] as String,
      borrowingTime: DateTime.parse(json['borrowingTime'] as String),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      maxDurationHours: json['maxDurationHours'] as int,
      batteryLevel: json['batteryLevel'] as int,
    );
  }

  /// Convertit l'instance en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batteryId': batteryId,
      'stationId': stationId,
      'stationName': stationName,
      'borrowingTime': borrowingTime.toIso8601String(),
      'depositAmount': depositAmount,
      'maxDurationHours': maxDurationHours,
      'batteryLevel': batteryLevel,
    };
  }

  /// Crée une copie de l'instance avec les valeurs spécifiées modifiées
  ActiveBorrowing copyWith({
    String? id,
    String? batteryId,
    String? stationId,
    String? stationName,
    DateTime? borrowingTime,
    double? depositAmount,
    int? maxDurationHours,
    int? batteryLevel,
  }) {
    return ActiveBorrowing(
      id: id ?? this.id,
      batteryId: batteryId ?? this.batteryId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      borrowingTime: borrowingTime ?? this.borrowingTime,
      depositAmount: depositAmount ?? this.depositAmount,
      maxDurationHours: maxDurationHours ?? this.maxDurationHours,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ActiveBorrowing &&
      other.id == id &&
      other.batteryId == batteryId &&
      other.stationId == stationId &&
      other.stationName == stationName &&
      other.borrowingTime == borrowingTime &&
      other.depositAmount == depositAmount &&
      other.maxDurationHours == maxDurationHours &&
      other.batteryLevel == batteryLevel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      batteryId.hashCode ^
      stationId.hashCode ^
      stationName.hashCode ^
      borrowingTime.hashCode ^
      depositAmount.hashCode ^
      maxDurationHours.hashCode ^
      batteryLevel.hashCode;
  }
}
