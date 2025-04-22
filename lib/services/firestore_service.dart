import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/charging_station_model.dart';
import '../models/rent_order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _stationsCollection => _firestore.collection('chargingStations');
  CollectionReference get _rentOrdersCollection => _firestore.collection('rentOrders');

  // ===== UTILISATEURS =====

  // Obtenir un utilisateur par son ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Créer ou mettre à jour un utilisateur
  Future<void> setUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la création/mise à jour de l\'utilisateur: $e');
      rethrow;
    }
  }

  // Mettre à jour le solde d'un utilisateur
  Future<void> updateUserBalance(String userId, double amount) async {
    try {
      await _usersCollection.doc(userId).update({
        'balance': FieldValue.increment(amount)
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du solde: $e');
      rethrow;
    }
  }

  // ===== BORNES DE RECHARGE =====

  // Obtenir toutes les bornes de recharge
  Future<List<ChargingStationModel>> getAllChargingStations() async {
    try {
      QuerySnapshot snapshot = await _stationsCollection.get();
      return snapshot.docs.map((doc) => 
        ChargingStationModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        )
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des bornes de recharge: $e');
      return [];
    }
  }

  // Obtenir une borne de recharge par son ID
  Future<ChargingStationModel?> getChargingStationById(String stationId) async {
    try {
      DocumentSnapshot doc = await _stationsCollection.doc(stationId).get();
      if (doc.exists) {
        return ChargingStationModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la borne de recharge: $e');
      return null;
    }
  }

  // Créer ou mettre à jour une borne de recharge
  Future<void> setChargingStation(ChargingStationModel station) async {
    try {
      await _stationsCollection.doc(station.id).set(
        station.toMap(), 
        SetOptions(merge: true)
      );
    } catch (e) {
      print('Erreur lors de la création/mise à jour de la borne de recharge: $e');
      rethrow;
    }
  }

  // Mettre à jour le nombre de batteries disponibles
  Future<void> updateBatteryAvailability(String stationId, int change) async {
    try {
      await _stationsCollection.doc(stationId).update({
        'availableBatteries': FieldValue.increment(change)
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des batteries disponibles: $e');
      rethrow;
    }
  }

  // ===== LOCATIONS =====

  // Obtenir toutes les locations d'un utilisateur
  Future<List<RentOrderModel>> getUserRentOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _rentOrdersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();
      
      return snapshot.docs.map((doc) => 
        RentOrderModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        )
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des locations: $e');
      return [];
    }
  }

  // Obtenir les locations actives d'un utilisateur
  Future<List<RentOrderModel>> getActiveRentOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _rentOrdersCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();
      
      return snapshot.docs.map((doc) => 
        RentOrderModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        )
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des locations actives: $e');
      return [];
    }
  }

  // Créer une nouvelle location
  Future<String> createRentOrder(RentOrderModel order) async {
    try {
      // Créer la location
      DocumentReference docRef = await _rentOrdersCollection.add(order.toMap());
      
      // Mettre à jour le nombre de batteries disponibles
      await updateBatteryAvailability(order.stationId, -1);
      
      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création de la location: $e');
      rethrow;
    }
  }

  // Terminer une location
  Future<void> completeRentOrder(
    String orderId, 
    String returnStationId, 
    double cost
  ) async {
    try {
      // Récupérer la location
      DocumentSnapshot doc = await _rentOrdersCollection.doc(orderId).get();
      if (!doc.exists) {
        throw Exception('Location non trouvée');
      }
      
      RentOrderModel order = RentOrderModel.fromMap(
        doc.data() as Map<String, dynamic>, 
        doc.id
      );
      
      // Mettre à jour la location
      await _rentOrdersCollection.doc(orderId).update({
        'status': 'completed',
        'endTime': Timestamp.now(),
        'cost': cost,
        'returnStationId': returnStationId
      });
      
      // Mettre à jour le nombre de batteries disponibles dans la station de retour
      await updateBatteryAvailability(returnStationId, 1);
      
      // Mettre à jour le solde de l'utilisateur (rembourser la caution moins le coût)
      double balanceChange = order.deposit - cost;
      if (balanceChange != 0) {
        await updateUserBalance(order.userId, balanceChange);
      }
    } catch (e) {
      print('Erreur lors de la finalisation de la location: $e');
      rethrow;
    }
  }

  // Écouter les changements sur une borne de recharge
  Stream<ChargingStationModel> streamChargingStation(String stationId) {
    return _stationsCollection.doc(stationId).snapshots().map(
      (snapshot) => ChargingStationModel.fromMap(
        snapshot.data() as Map<String, dynamic>, 
        snapshot.id
      )
    );
  }

  // Écouter les changements sur les locations actives d'un utilisateur
  Stream<List<RentOrderModel>> streamActiveRentOrders(String userId) {
    return _rentOrdersCollection
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => 
          RentOrderModel.fromMap(
            doc.data() as Map<String, dynamic>, 
            doc.id
          )
        ).toList()
      );
  }
}
