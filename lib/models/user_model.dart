class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phoneNumber;
  final String? address;
  final double balance;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.address,
    this.balance = 0.0,
    this.createdAt,
  });

  // Créer un UserModel à partir d'un Map (Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as dynamic).toDate() 
          : null,
    );
  }

  // Convertir UserModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'address': address,
      'balance': balance,
      // Ne pas inclure createdAt lors de la mise à jour
    };
  }

  // Créer une copie de UserModel avec des modifications
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? address,
    double? balance,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RentalModel {
  final String id;
  final String cabinetId;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active', 'completed', 'cancelled'
  final double? amount;

  RentalModel({
    required this.id,
    required this.cabinetId,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.amount,
  });

  // Créer un RentalModel à partir d'un Map (Firestore document)
  factory RentalModel.fromMap(Map<String, dynamic> data, String id) {
    return RentalModel(
      id: id,
      cabinetId: data['cabinetId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      startTime: (data['startTime'] as dynamic).toDate(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as dynamic).toDate() 
          : null,
      status: data['status'] ?? 'active',
      amount: data['amount'] != null 
          ? (data['amount'] as num).toDouble() 
          : null,
    );
  }

  // Convertir RentalModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'cabinetId': cabinetId,
      'deviceId': deviceId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'amount': amount,
    };
  }
}
