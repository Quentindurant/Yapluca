import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response_model.dart';
import '../models/device_info_model.dart';
import '../models/cabinet_model.dart';

class ApiService {
  static const String baseUrl = 'https://developer.chargenow.top/cdb-open-api/v1';
  
  // Clé d'authentification par défaut - à remplacer par les vraies informations d'authentification
  // Format: Basic base64(username:password)
  static const String authKey = 'Basic Y2RiX29wZW5fYXBpOmNkYl9vcGVuX2FwaV9wd2Q=';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers pour les requêtes API
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? authKey;
    
    debugPrint('Using auth token: $token');
    
    return {
      'Authorization': token,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Obtenir les informations d'un appareil par son ID
  Future<ApiResponse<DeviceInfo>> getDeviceInfo(String deviceId) async {
    try {
      debugPrint('Calling getDeviceInfo for deviceId: $deviceId');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/rent/cabinet/query?deviceId=$deviceId');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.fromJson(data, DeviceInfo.fromJson);
      } else {
        throw Exception('Failed to load device info: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getDeviceInfo: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: null,
      );
    }
  }

  // Obtenir la liste des appareils
  Future<ApiResponse<List<Cabinet>>> getDeviceList() async {
    try {
      debugPrint('Calling getDeviceList');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/cabinet/list');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body.substring(0, math.min(500, response.body.length))}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['code'] == 0 && responseData['data'] != null) {
          final List<dynamic> devicesJson = responseData['data'] as List<dynamic>;
          final List<Cabinet> devices = devicesJson
              .map((json) => Cabinet.fromJson(json as Map<String, dynamic>))
              .toList();
          
          debugPrint('Parsed ${devices.length} cabinets');
          
          return ApiResponse(
            code: responseData['code'] as int?,
            msg: responseData['msg'] as String?,
            data: devices,
          );
        } else {
          debugPrint('API returned error: ${responseData['msg']}');
          return ApiResponse(
            code: responseData['code'] as int?,
            msg: responseData['msg'] as String?,
            data: [],
          );
        }
      } else {
        throw Exception('Failed to load device list: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getDeviceList: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: [],
      );
    }
  }

  // Créer une commande de location
  Future<ApiResponse<Map<String, dynamic>>> createRentOrder(String deviceId, int slotNum) async {
    try {
      debugPrint('Calling createRentOrder for deviceId: $deviceId, slotNum: $slotNum');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/rent/create');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'deviceId': deviceId,
          'slotNum': slotNum,
        }),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse(
          code: data['code'] as int?,
          msg: data['msg'] as String?,
          data: data['data'] as Map<String, dynamic>?,
        );
      } else {
        throw Exception('Failed to create rent order: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in createRentOrder: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: null,
      );
    }
  }

  // Obtenir les détails d'une commande de location
  Future<ApiResponse<Map<String, dynamic>>> getRentOrderDetails(String orderId) async {
    try {
      debugPrint('Calling getRentOrderDetails for orderId: $orderId');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/rent/order/detail?orderId=$orderId');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse(
          code: data['code'] as int?,
          msg: data['msg'] as String?,
          data: data['data'] as Map<String, dynamic>?,
        );
      } else {
        throw Exception('Failed to get rent order details: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getRentOrderDetails: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: null,
      );
    }
  }

  // Obtenir les commandes de location de l'utilisateur
  Future<ApiResponse<List<dynamic>>> getUserRentOrders() async {
    try {
      debugPrint('Calling getUserRentOrders');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/rent/order/list');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body.substring(0, math.min(500, response.body.length))}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['code'] == 0 && responseData['data'] != null) {
          final List<dynamic> ordersJson = responseData['data'] as List<dynamic>;
          
          debugPrint('Parsed ${ordersJson.length} orders');
          
          return ApiResponse(
            code: responseData['code'] as int?,
            msg: responseData['msg'] as String?,
            data: ordersJson,
          );
        } else {
          debugPrint('API returned error: ${responseData['msg']}');
          return ApiResponse(
            code: responseData['code'] as int?,
            msg: responseData['msg'] as String?,
            data: [],
          );
        }
      } else {
        throw Exception('Failed to load user rent orders: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getUserRentOrders: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: [],
      );
    }
  }

  // Retourner une batterie
  Future<ApiResponse<Map<String, dynamic>>> returnBattery(String orderId, String deviceId) async {
    try {
      debugPrint('Calling returnBattery for orderId: $orderId, deviceId: $deviceId');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/rent/return');
      
      debugPrint('API URL: ${url.toString()}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'orderId': orderId,
          'deviceId': deviceId,
        }),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse(
          code: data['code'] as int?,
          msg: data['msg'] as String?,
          data: data['data'] as Map<String, dynamic>?,
        );
      } else {
        throw Exception('Failed to return battery: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in returnBattery: $e');
      return ApiResponse(
        code: -1,
        msg: 'Error: $e',
        data: null,
      );
    }
  }

  // Définir le jeton d'authentification
  Future<void> setAuthToken(String username, String password) async {
    final String credentials = '$username:$password';
    final String token = 'Basic ${base64Encode(utf8.encode(credentials))}';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Effacer le jeton d'authentification
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
