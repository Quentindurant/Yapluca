import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const deviceId = 'BJD60151'; // Remplace par le vrai deviceId si besoin
  const username = 'MaximeRiviere';
  const password = 'MR!2025';
  final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

  final url = Uri.parse('https://developer.chargenow.top/cdb-open-api/v1/rent/cabinet/query?deviceId=$deviceId');
  final response = await http.get(url, headers: {'Authorization': basicAuth});

  print('Status: [32m${response.statusCode}[0m');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['code'] == 0 && data['data'] != null) {
      final online = data['data']['cabinet']['online'];
      print('Borne trouvée. Statut online: $online');
      if (online == true) {
        print('\u001b[32mLa borne est ACTIVE !\u001b[0m');
      } else {
        print('\u001b[31mLa borne est INACTIVE.\u001b[0m');
      }
    } else {
      throw Exception('Réponse inattendue: ${response.body}');
    }
  } else {
    throw Exception('Erreur HTTP: ${response.statusCode}');
  }
}
