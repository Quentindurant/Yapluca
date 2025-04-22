/// Modèle représentant un utilisateur de l'application YapluCa
class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final bool isAdmin;
  final List<String> activeBorrowings; // IDs des emprunts actifs
  final double depositAmount; // Montant de la caution
  final String? avatarUrl; // URL de l'avatar de l'utilisateur
  final DateTime memberSince; // Date d'inscription
  final double creditBalance; // Solde de crédit de l'utilisateur
  final String referralCode; // Code de parrainage
  final int referralsCount; // Nombre d'amis parrainés
  final double referralEarnings; // Montant gagné grâce aux parrainages
  
  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.isAdmin = false,
    this.activeBorrowings = const [],
    this.depositAmount = 0.0,
    this.avatarUrl,
    required this.memberSince,
    this.creditBalance = 0.0,
    this.referralCode = 'YAPLUCA',
    this.referralsCount = 0,
    this.referralEarnings = 0.0,
  });
  
  /// Alias pour fullName pour maintenir la compatibilité
  String get name => fullName;
  
  /// Indique si l'utilisateur a des emprunts actifs
  bool get hasActiveBorrowings => activeBorrowings.isNotEmpty;
  
  /// Crée une instance de User à partir d'un objet JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      activeBorrowings: (json['activeBorrowings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: json['avatarUrl'] as String?,
      memberSince: DateTime.parse(json['memberSince'] as String),
      creditBalance: (json['creditBalance'] as num?)?.toDouble() ?? 0.0,
      referralCode: json['referralCode'] as String? ?? 'YAPLUCA',
      referralsCount: (json['referralsCount'] as num?)?.toInt() ?? 0,
      referralEarnings: (json['referralEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  /// Convertit l'instance en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isAdmin': isAdmin,
      'activeBorrowings': activeBorrowings,
      'depositAmount': depositAmount,
      'avatarUrl': avatarUrl,
      'memberSince': memberSince.toIso8601String(),
      'creditBalance': creditBalance,
      'referralCode': referralCode,
      'referralsCount': referralsCount,
      'referralEarnings': referralEarnings,
    };
  }
  
  /// Crée une copie de l'instance avec les champs spécifiés modifiés
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    bool? isAdmin,
    List<String>? activeBorrowings,
    double? depositAmount,
    String? avatarUrl,
    DateTime? memberSince,
    double? creditBalance,
    String? referralCode,
    int? referralsCount,
    double? referralEarnings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAdmin: isAdmin ?? this.isAdmin,
      activeBorrowings: activeBorrowings ?? this.activeBorrowings,
      depositAmount: depositAmount ?? this.depositAmount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
      creditBalance: creditBalance ?? this.creditBalance,
      referralCode: referralCode ?? this.referralCode,
      referralsCount: referralsCount ?? this.referralsCount,
      referralEarnings: referralEarnings ?? this.referralEarnings,
    );
  }
}
