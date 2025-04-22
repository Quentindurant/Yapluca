import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassPlace {
  final String name;
  final String type;
  final double lat;
  final double lon;

  OverpassPlace({required this.name, required this.type, required this.lat, required this.lon});
}

class OverpassUtils {
  /// Récupère les lieux d'intérêt (restaurants, cafés, bars, monuments, parcs) autour de la position donnée
  static Future<List<OverpassPlace>> getNearbyPlaces({
    required double lat,
    required double lon,
    int radiusMeters = 1200, // Rayon de recherche en mètres
  }) async {
    // Les types de lieux à rechercher (amenity/tourism/leisure)
    final filters = [
      'amenity~"restaurant|cafe|bar|pub|fast_food"',
      'tourism~"museum|attraction|gallery|viewpoint|zoo|theme_park"',
      'leisure~"park|garden|playground"',
      'historic',
    ];
    final query = '''[out:json];(
      node(around:$radiusMeters,$lat,$lon)[${filters.join('] ; node(around:$radiusMeters,$lat,$lon)[')}];
    );out center;''';
    final url = 'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List elements = data['elements'] ?? [];
      return elements
          .where((e) => e['tags'] != null && (e['tags']['name'] ?? '').toString().isNotEmpty)
          .map<OverpassPlace>((e) => OverpassPlace(
                name: e['tags']['name'],
                type: e['tags']['amenity'] ?? e['tags']['tourism'] ?? e['tags']['leisure'] ?? e['tags']['historic'] ?? 'lieu',
                lat: e['lat']?.toDouble() ?? e['center']?['lat']?.toDouble() ?? 0.0,
                lon: e['lon']?.toDouble() ?? e['center']?['lon']?.toDouble() ?? 0.0,
              ))
          .toList();
    } else {
      throw Exception('Erreur Overpass API: ${response.statusCode}');
    }
  }
}
