import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class ChargingStationService {
  // Méthode pour récupérer les stations à proximité depuis l'API réelle
  Future<List<ChargingStation>> getNearbyStations(double latitude, double longitude) async {
    // Appel à l'API chargenow.top pour récupérer les bornes réelles
    const username = 'MaximeRiviere';
    const password = 'MR!2025';
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    // TODO: Remplacer par l'endpoint qui liste toutes les bornes si disponible
    // Ici, exemple avec un seul deviceId (à généraliser si besoin)
    final deviceIds = [
      'BJD60151', // Ajoute ici tous les deviceId connus
    ];
    List<ChargingStation> stations = [];
    for (final deviceId in deviceIds) {
      final url = Uri.parse('https://developer.chargenow.top/cdb-open-api/v1/rent/cabinet/query?deviceId=$deviceId');
      final response = await http.get(url, headers: {'Authorization': basicAuth});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['data'] != null) {
          final cabinet = data['data']['cabinet'];
          final shop = data['data']['shop'];
          final totalBatteries = data['data']['cabinet']['slots'] ?? 0;
          final availableBatteries = data['data']['cabinet']['emptySlots'] ?? 0;
          stations.add(ChargingStation(
            id: cabinet['id'] ?? deviceId,
            name: shop['name'] ?? 'Borne $deviceId',
            address: shop['address'] ?? '',
            latitude: double.tryParse(shop['latitude'] ?? '') ?? 0.0,
            longitude: double.tryParse(shop['longitude'] ?? '') ?? 0.0,
            totalBatteries: totalBatteries,
            availability: availableBatteries,
            isOpen: cabinet['online'] ?? true,
            openingHours: shop['openingTime'],
            imageUrl: shop['logo'],
          ));
        }
      }
    }
    return stations;
  }

  // Méthode pour récupérer toutes les stations depuis l'API
  Future<List<ChargingStation>> getAllStations() async {
    const username = 'MaximeRiviere';
    const password = 'MR!2025';
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final url = Uri.parse('https://developer.chargenow.top/cdb-open-api/v1/cabinet/getAllDevice');
    final response = await http.get(url, headers: {'Authorization': basicAuth});
    List<ChargingStation> stations = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 0 && data['data'] != null) {
        for (final device in data['data']) {
          final deviceId = device['pCabinetid'];
          // Appel à l'endpoint de détail pour chaque borne
          final detailUrl = Uri.parse('https://developer.chargenow.top/cdb-open-api/v1/rent/cabinet/query?deviceId=$deviceId');
          final detailResp = await http.get(detailUrl, headers: {'Authorization': basicAuth});
          if (detailResp.statusCode == 200) {
            final detailData = json.decode(detailResp.body);
            if (detailData['code'] == 0 && detailData['data'] != null) {
              final cabinet = detailData['data']['cabinet'];
              final shop = detailData['data']['shop'];
              final totalBatteries = cabinet['slots'] ?? 0;
              final availableBatteries = cabinet['emptySlots'] ?? 0;
              stations.add(ChargingStation(
                id: cabinet['id'] ?? deviceId,
                name: shop['name'] ?? 'Borne $deviceId',
                address: shop['address'] ?? '',
                latitude: double.tryParse(shop['latitude'] ?? '') ?? 0.0,
                longitude: double.tryParse(shop['longitude'] ?? '') ?? 0.0,
                totalBatteries: totalBatteries,
                availability: availableBatteries,
                isOpen: cabinet['online'] ?? true,
                openingHours: shop['openingTime'],
                imageUrl: shop['logo'],
              ));
            }
          }
        }
      }
    }
    return stations;
  }

  // Méthode pour récupérer les stations favorites (désactivée, car plus de données fictives)
  Future<List<ChargingStation>> getFavoriteStations() async {
    // Optionnel : tu peux implémenter une vraie API pour les favoris ici
    return [];
  }

  // Méthode pour ajouter une station aux favoris (à implémenter avec l'API réelle si besoin)
  Future<void> addToFavorites(String stationId) async {
    // À implémenter avec l'API réelle
    return;
  }

  // Méthode pour retirer une station des favoris (à implémenter avec l'API réelle si besoin)
  Future<void> removeFromFavorites(String stationId) async {
    // À implémenter avec l'API réelle
    return;
  }
}
