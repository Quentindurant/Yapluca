import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingUtils {
  /// Récupère la ville (ou commune) à partir de coordonnées GPS via Nominatim (OpenStreetMap)
  static Future<String?> getCityFromCoordinates(double lat, double lon) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=fr';
    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'YapluCaApp/1.0 (contact@yapluca.fr)',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['address'] ?? {};
      return address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? address['county'];
    }
    return null;
  }
}
