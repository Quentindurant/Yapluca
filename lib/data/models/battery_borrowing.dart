import 'package:intl/intl.dart';

/// Modèle représentant un emprunt de batterie dans l'application YapluCa
class BatteryBorrowing {
  final String id;
  final String userId;
  final String stationId;
  final String batteryId;
  final DateTime borrowingTime;
  final DateTime? returnTime;
  final double depositAmount;
  final bool isActive;
  
  BatteryBorrowing({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.batteryId,
    required this.borrowingTime,
    this.returnTime,
    required this.depositAmount,
    this.isActive = true,
  });
  
  /// Alias pour borrowingTime pour maintenir la compatibilité
  DateTime get startTime => borrowingTime;
  
  /// Alias pour returnTime pour maintenir la compatibilité
  DateTime? get endTime => returnTime;
  
  /// Durée de l'emprunt en minutes
  int get durationInMinutes {
    if (returnTime == null) {
      // Si la batterie n'a pas été rendue, calculer la durée jusqu'à maintenant
      return DateTime.now().difference(borrowingTime).inMinutes;
    } else {
      // Sinon, calculer la durée entre l'emprunt et le retour
      return returnTime!.difference(borrowingTime).inMinutes;
    }
  }
  
  /// Formatte la durée de l'emprunt en texte lisible
  String get formattedDuration {
    final minutes = durationInMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }
  
  /// Formatte la date d'emprunt en texte lisible
  String get formattedBorrowingTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(borrowingTime);
  }
  
  /// Formatte la date de retour en texte lisible
  String? get formattedReturnTime {
    return returnTime != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(returnTime!) 
        : null;
  }
  
  /// Crée une instance de BatteryBorrowing à partir d'un objet JSON
  factory BatteryBorrowing.fromJson(Map<String, dynamic> json) {
    return BatteryBorrowing(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stationId: json['stationId'] as String,
      batteryId: json['batteryId'] as String,
      borrowingTime: DateTime.parse(json['borrowingTime'] as String),
      returnTime: json['returnTime'] != null 
          ? DateTime.parse(json['returnTime'] as String) 
          : null,
      depositAmount: (json['depositAmount'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  /// Convertit l'instance en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stationId': stationId,
      'batteryId': batteryId,
      'borrowingTime': borrowingTime.toIso8601String(),
      'returnTime': returnTime?.toIso8601String(),
      'depositAmount': depositAmount,
      'isActive': isActive,
    };
  }
  
  /// Crée une copie de l'instance avec les champs spécifiés modifiés
  BatteryBorrowing copyWith({
    String? id,
    String? userId,
    String? stationId,
    String? batteryId,
    DateTime? borrowingTime,
    DateTime? returnTime,
    double? depositAmount,
    bool? isActive,
  }) {
    return BatteryBorrowing(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      batteryId: batteryId ?? this.batteryId,
      borrowingTime: borrowingTime ?? this.borrowingTime,
      returnTime: returnTime ?? this.returnTime,
      depositAmount: depositAmount ?? this.depositAmount,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// Marque l'emprunt comme terminé avec la date de retour spécifiée
  BatteryBorrowing markAsReturned([DateTime? returnDateTime]) {
    return copyWith(
      returnTime: returnDateTime ?? DateTime.now(),
      isActive: false,
    );
  }
}
