import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

/// Service pour accéder à l'API des bornes de recharge Bajie Charging
class ChargingStationService {
  // URL de base de l'API
  final String baseUrl = 'https://developer.chargenow.top/cdb-open-api/v1';
  
  // Clé d'authentification Basic (à remplacer par la vraie clé)
  final String authHeader = 'Basic Og==';
  
  /// Récupère toutes les bornes de recharge
  Future<List<ChargingStation>> getChargingStations() async {
    try {
      print('Tentative de récupération des bornes de recharge');
      final response = await http.get(
        Uri.parse('$baseUrl/rent/cabinet/query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authHeader,
        },
      );
      
      print('Réponse de l\'API (status: ${response.statusCode}): ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('code') && responseData['code'] == 0 && responseData.containsKey('data')) {
          final data = responseData['data'];
          final List<ChargingStation> stations = [];
          
          if (data is Map<String, dynamic> && data.containsKey('cabinetList')) {
            final cabinetList = data['cabinetList'] as List<dynamic>;
            print('Nombre de bornes récupérées: ${cabinetList.length}');
            
            for (var cabinetData in cabinetList) {
              try {
                stations.add(ChargingStation.fromBajieApi(cabinetData));
              } catch (e) {
                print('Erreur lors de la conversion d\'une borne: $e');
              }
            }
          } else {
            print('Format de données inattendu: ${data.runtimeType}');
          }
          
          return stations;
        } else {
          print('Format de réponse inattendu: ${response.body.substring(0, min(100, response.body.length))}...');
          throw Exception('Format de réponse inattendu');
        }
      } else {
        print('Échec de la récupération des bornes: ${response.statusCode}');
        throw Exception('Échec de la récupération des bornes: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des bornes: $e');
      // Ne plus retourner de bornes fictives en production
      return []; // ou throw e; si tu veux afficher une erreur à l'utilisateur
    }
  }
  
  /// Récupère une borne de recharge par son ID
  Future<ChargingStation> getStationById(String deviceId) async {
    try {
      print('Tentative de récupération de la borne avec ID: $deviceId');
      final response = await http.get(
        Uri.parse('$baseUrl/rent/cabinet/query?deviceId=$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authHeader,
        },
      );
      
      print('Réponse de l\'API (status: ${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('code') && responseData['code'] == 0 && responseData.containsKey('data')) {
          print('Données de la borne récupérées avec succès');
          return ChargingStation.fromBajieApi(responseData['data']);
        } else {
          print('Format de réponse inattendu: ${response.body}');
          throw Exception('Format de réponse inattendu: ${response.body}');
        }
      } else {
        print('Échec de la récupération de la borne: ${response.statusCode}');
        throw Exception('Échec de la récupération de la borne: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la borne: $e');
      // Ne plus retourner de borne fictive en production
      throw Exception('Impossible de récupérer la borne $deviceId');
    }
  }
  
  /// Récupère les bornes de recharge à proximité d'une position
  Future<List<ChargingStation>> getNearbyStations(
    double latitude,
    double longitude,
    {double radiusInKm = 5.0}
  ) async {
    try {
      // L'API ne semble pas avoir d'endpoint pour les bornes à proximité
      // On récupère donc toutes les bornes et on filtre par distance
      final allStations = await getChargingStations();
      
      // Filtrer les stations par distance
      return allStations.where((station) {
        final distance = station.calculateDistance(latitude, longitude);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des bornes à proximité: $e');
      return [];
    }
  }
  
  /// Crée une commande de location pour une batterie
  Future<Map<String, dynamic>> createRentOrder(String deviceId, int slotNum) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rent/order/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authHeader,
        },
        body: json.encode({
          'deviceId': deviceId,
          'slotNum': slotNum,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('code') && responseData['code'] == 0) {
          return responseData['data'];
        } else {
          throw Exception('Erreur lors de la création de la commande: ${responseData['msg']}');
        }
      } else {
        throw Exception('Échec de la création de la commande: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      throw e;
    }
  }
  
  /// Génère des données fictives pour le développement
  List<ChargingStation> _getMockStations() {
    return [
      ChargingStation(
        id: 'BJD60151',
        name: 'Café Central',
        latitude: 48.8566,
        longitude: 2.3522,
        address: '15 Rue de Rivoli, 75001 Paris',
        totalBatteries: 10,
        availableBatteries: 7,
        availableSlots: 3,
        isActive: true,
        shopId: 'shop1',
        price: 2.5,
        depositAmount: 20.0,
        qrCode: 'https://example.com/qr/BJD60151',
      ),
      ChargingStation(
        id: 'BJD60152',
        name: 'Hôtel Lumière',
        latitude: 48.8606,
        longitude: 2.3376,
        address: '23 Avenue des Champs-Élysées, 75008 Paris',
        totalBatteries: 8,
        availableBatteries: 2,
        availableSlots: 6,
        isActive: true,
        shopId: 'shop2',
        price: 2.0,
        depositAmount: 20.0,
        qrCode: 'https://example.com/qr/BJD60152',
      ),
      ChargingStation(
        id: 'BJD60153',
        name: 'Espace Coworking',
        latitude: 48.8744,
        longitude: 2.3526,
        address: '5 Boulevard de Clichy, 75009 Paris',
        totalBatteries: 12,
        availableBatteries: 0,
        availableSlots: 12,
        isActive: true,
        shopId: 'shop3',
        price: 3.0,
        depositAmount: 25.0,
        qrCode: 'https://example.com/qr/BJD60153',
      ),
      ChargingStation(
        id: 'BJD60154',
        name: 'Bibliothèque Municipale',
        latitude: 48.8600,
        longitude: 2.3400,
        address: '10 Rue de la Bibliothèque, 75005 Paris',
        totalBatteries: 6,
        availableBatteries: 4,
        availableSlots: 2,
        isActive: true,
        shopId: 'shop4',
        price: 2.0,
        depositAmount: 15.0,
        qrCode: 'https://example.com/qr/BJD60154',
      ),
      ChargingStation(
        id: 'BJD60155',
        name: 'Centre Commercial',
        latitude: 48.8550,
        longitude: 2.3450,
        address: '50 Avenue du Commerce, 75015 Paris',
        totalBatteries: 15,
        availableBatteries: 9,
        availableSlots: 6,
        isActive: false,
        shopId: 'shop5',
        price: 2.5,
        depositAmount: 20.0,
        qrCode: 'https://example.com/qr/BJD60155',
      ),
    ];
  }
}
