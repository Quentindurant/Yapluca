import 'package:flutter/foundation.dart';
import '../models/api_response_model.dart';
import '../models/cabinet_model.dart';
import '../models/device_info_model.dart';
import '../services/api_service.dart';
import '../../services/firestore_service.dart';
import '../../models/charging_station_model.dart';
import '../../models/rent_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChargingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  
  // State variables
  List<Cabinet> _cabinets = [];
  DeviceInfo? _currentDeviceInfo;
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _userRentOrders = [];
  
  // Firebase state variables
  List<ChargingStationModel> _chargingStations = [];
  List<RentOrderModel> _firebaseRentOrders = [];
  
  // Getters
  List<Cabinet> get cabinets => _cabinets;
  DeviceInfo? get currentDeviceInfo => _currentDeviceInfo;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get userRentOrders => _userRentOrders;
  
  // Firebase getters
  List<ChargingStationModel> get chargingStations => _chargingStations;
  List<RentOrderModel> get firebaseRentOrders => _firebaseRentOrders;
  
  // Fetch all cabinets/devices
  Future<void> fetchCabinets() async {
    debugPrint('ChargingProvider: fetchCabinets called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.getDeviceList();
      
      debugPrint('ChargingProvider: getDeviceList response - code: ${response.code}, msg: ${response.msg}');
      
      if (response.isSuccess && response.data != null) {
        _cabinets = response.data!;
        debugPrint('ChargingProvider: Loaded ${_cabinets.length} cabinets');
        
        // Log some cabinet details for debugging
        if (_cabinets.isNotEmpty) {
          final cabinet = _cabinets.first;
          debugPrint('ChargingProvider: First cabinet - id: ${cabinet.id}, remark: ${cabinet.remark}, online: ${cabinet.online}');
        }
      } else {
        _errorMessage = response.msg ?? 'Failed to fetch cabinets';
        debugPrint('ChargingProvider: Error fetching cabinets - $_errorMessage');
        
        // Ne plus injecter de bornes fictives. La liste reste vide en cas d'échec.
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('ChargingProvider: Exception in fetchCabinets - $_errorMessage');
      

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  

  
  // Fetch device info by device ID
  Future<void> fetchDeviceInfo(String deviceId) async {
    debugPrint('ChargingProvider: fetchDeviceInfo called for deviceId: $deviceId');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.getDeviceInfo(deviceId);
      
      debugPrint('ChargingProvider: getDeviceInfo response - code: ${response.code}, msg: ${response.msg}');
      
      if (response.isSuccess && response.data != null) {
        _currentDeviceInfo = response.data;
        debugPrint('ChargingProvider: Device info loaded successfully');
        
        // Log device info details for debugging
        if (_currentDeviceInfo != null) {
          final cabinet = _currentDeviceInfo!.cabinet;
          debugPrint('ChargingProvider: Cabinet - id: ${cabinet?.id}, remark: ${cabinet?.remark}, online: ${cabinet?.online}');
          
          final shop = _currentDeviceInfo!.shop;
          debugPrint('ChargingProvider: Shop - id: ${shop?.id}, name: ${shop?.name}');
          
          final batteries = _currentDeviceInfo!.batteries;
          debugPrint('ChargingProvider: Batteries count: ${batteries?.length ?? 0}');
        }
      } else {
        _errorMessage = response.msg ?? 'Failed to fetch device info';
        debugPrint('ChargingProvider: Error fetching device info - $_errorMessage');
        

      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('ChargingProvider: Exception in fetchDeviceInfo - $_errorMessage');
      

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  

  
  // Create rent order
  Future<Map<String, dynamic>?> createRentOrder(String deviceId, int slotNum) async {
    debugPrint('ChargingProvider: createRentOrder called for deviceId: $deviceId, slotNum: $slotNum');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.createRentOrder(deviceId, slotNum);
      
      debugPrint('ChargingProvider: createRentOrder response - code: ${response.code}, msg: ${response.msg}');
      
      if (response.isSuccess && response.data != null) {
        // Refresh user rent orders after creating a new one
        await fetchUserRentOrders();
        return response.data;
      } else {
        _errorMessage = response.msg ?? 'Failed to create rent order';
        debugPrint('ChargingProvider: Error creating rent order - $_errorMessage');
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('ChargingProvider: Exception in createRentOrder - $_errorMessage');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch user's rent orders
  Future<void> fetchUserRentOrders() async {
    debugPrint('ChargingProvider: fetchUserRentOrders called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Utiliser l'API existante
      final response = await _apiService.getUserRentOrders();
      
      if (response.isSuccess && response.data != null) {
        _userRentOrders = response.data!;
        debugPrint('ChargingProvider: Loaded ${_userRentOrders.length} rent orders');
      } else {
        _errorMessage = response.msg ?? 'Failed to fetch rent orders';
        debugPrint('ChargingProvider: Error fetching rent orders - $_errorMessage');
        
        // Créer des données fictives pour le débogage si l'API échoue
        // _createMockRentOrders(); // Commenté temporairement pour la génération de l'APK
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('ChargingProvider: Exception fetching rent orders - $e');
      
      // Créer des données fictives pour le débogage en cas d'erreur
      // _createMockRentOrders(); // Commenté temporairement pour la génération de l'APK
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Charger les bornes de recharge depuis Firebase
  Future<void> fetchChargingStations() async {
    debugPrint('ChargingProvider: fetchChargingStations from Firebase called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _chargingStations = await _firestoreService.getAllChargingStations();
      debugPrint('ChargingProvider: Loaded ${_chargingStations.length} charging stations from Firebase');
    } catch (e) {
      _errorMessage = 'Error fetching charging stations: $e';
      debugPrint('ChargingProvider: Error fetching charging stations from Firebase - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Charger les locations d'un utilisateur depuis Firebase
  Future<void> fetchUserRentOrdersFromFirebase(String userId) async {
    debugPrint('ChargingProvider: fetchUserRentOrdersFromFirebase called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _firebaseRentOrders = await _firestoreService.getUserRentOrders(userId);
      debugPrint('ChargingProvider: Loaded ${_firebaseRentOrders.length} rent orders from Firebase');
    } catch (e) {
      _errorMessage = 'Error fetching rent orders: $e';
      debugPrint('ChargingProvider: Error fetching rent orders from Firebase - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Louer une batterie (Firebase)
  Future<bool> rentBattery(String userId, String stationId, String deviceId) async {
    debugPrint('ChargingProvider: rentBattery from Firebase called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Vérifier si la station existe et a des batteries disponibles
      final station = await _firestoreService.getChargingStationById(stationId);
      if (station == null) {
        _errorMessage = 'Station de recharge non trouvée';
        return false;
      }
      
      if (!station.isActive) {
        _errorMessage = 'Cette station n\'est pas active';
        return false;
      }
      
      if (!station.hasBatteries) {
        _errorMessage = 'Aucune batterie disponible dans cette station';
        return false;
      }
      
      // Créer une nouvelle location
      final rentOrder = RentOrderModel(
        id: '', // Sera généré par Firestore
        userId: userId,
        stationId: stationId,
        deviceId: deviceId,
        startTime: DateTime.now(),
        status: 'active',
        deposit: 15.0, // Caution fixe de 15€
      );
      
      // Enregistrer la location dans Firestore
      final orderId = await _firestoreService.createRentOrder(rentOrder);
      
      // Recharger les locations de l'utilisateur
      await fetchUserRentOrdersFromFirebase(userId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la location: $e';
      debugPrint('ChargingProvider: Error renting battery - $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Retourner une batterie (Firebase)
  Future<bool> returnBattery(String orderId, String returnStationId) async {
    debugPrint('ChargingProvider: returnBattery from Firebase called');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Calculer le coût de la location (exemple: 1€ par heure, plafonné à 5€)
      // Dans un cas réel, cette logique serait plus complexe
      final doc = await FirebaseFirestore.instance.collection('rentOrders').doc(orderId).get();
      if (!doc.exists) {
        _errorMessage = 'Location non trouvée';
        return false;
      }
      
      final order = RentOrderModel.fromMap(doc.data()!, doc.id);
      final durationHours = order.duration.inHours;
      final cost = durationHours <= 0 ? 1.0 : (durationHours * 1.0).clamp(1.0, 5.0);
      
      // Finaliser la location
      await _firestoreService.completeRentOrder(orderId, returnStationId, cost);
      
      // Recharger les locations de l'utilisateur
      await fetchUserRentOrdersFromFirebase(order.userId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors du retour de la batterie: $e';
      debugPrint('ChargingProvider: Error returning battery - $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Écouter les changements sur une borne de recharge
  Stream<ChargingStationModel> streamChargingStation(String stationId) {
    return _firestoreService.streamChargingStation(stationId);
  }
  
  // Écouter les changements sur les locations actives d'un utilisateur
  Stream<List<RentOrderModel>> streamActiveRentOrders(String userId) {
    return _firestoreService.streamActiveRentOrders(userId);
  }
  
  // Return battery
  Future<bool> returnBatteryApi(String orderId, String deviceId) async {
    debugPrint('ChargingProvider: returnBattery called for orderId: $orderId, deviceId: $deviceId');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.returnBattery(orderId, deviceId);
      
      debugPrint('ChargingProvider: returnBattery response - code: ${response.code}, msg: ${response.msg}');
      
      if (response.isSuccess) {
        // Refresh user rent orders after returning a battery
        await fetchUserRentOrders();
        return true;
      } else {
        _errorMessage = response.msg ?? 'Failed to return battery';
        debugPrint('ChargingProvider: Error returning battery - $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('ChargingProvider: Exception in returnBattery - $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Process scanned QR code
  Future<bool> processScannedQRCode(String qrCode) async {
    debugPrint('ChargingProvider: processScannedQRCode called for qrCode: $qrCode');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Assuming the QR code contains the device ID
      await fetchDeviceInfo(qrCode);
      
      if (_currentDeviceInfo != null && _currentDeviceInfo!.cabinet != null) {
        return true;
      } else {
        _errorMessage = 'Invalid QR code or device not found';
        debugPrint('ChargingProvider: Error processing QR code - $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error processing QR code: $e';
      debugPrint('ChargingProvider: Exception in processScannedQRCode - $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear current device info
  void clearCurrentDeviceInfo() {
    debugPrint('ChargingProvider: clearCurrentDeviceInfo called');
    _currentDeviceInfo = null;
    notifyListeners();
  }
  
  // Set authentication token
  Future<void> setAuthToken(String username, String password) async {
    debugPrint('ChargingProvider: setAuthToken called for username: $username, password: $password');
    await _apiService.setAuthToken(username, password);
  }
  
  // Clear authentication token
  Future<void> clearAuthToken() async {
    debugPrint('ChargingProvider: clearAuthToken called');
    await _apiService.clearAuthToken();
  }
}
