import 'package:flutter/material.dart';
import 'data/services/charging_station_service.dart';
import 'data/models/charging_station.dart';

void main() {
  runApp(const TestApiApp());
}

class TestApiApp extends StatelessWidget {
  const TestApiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test API YapluCa',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const TestApiScreen(),
    );
  }
}

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final ChargingStationService _service = ChargingStationService();
  bool _isLoading = false;
  String _resultText = 'Appuyez sur un bouton pour tester l\'API';
  List<ChargingStation> _stations = [];

  Future<void> _testGetAllStations() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Chargement des bornes...';
    });

    try {
      final stations = await _service.getChargingStations();
      setState(() {
        _isLoading = false;
        _stations = stations;
        _resultText = 'Succès! ${stations.length} bornes récupérées';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = 'Erreur: $e';
      });
    }
  }

  Future<void> _testGetStationById() async {
    // ID de test - à remplacer par un ID valide si nécessaire
    const String testId = 'BJD60151';
    
    setState(() {
      _isLoading = true;
      _resultText = 'Chargement de la borne $testId...';
    });

    try {
      final station = await _service.getStationById(testId);
      setState(() {
        _isLoading = false;
        _resultText = 'Succès! Borne récupérée: ${station.name}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API YapluCa'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetAllStations,
              child: const Text('Tester getChargingStations()'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetStationById,
              child: const Text('Tester getStationById()'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_resultText),
                ),
              ),
            if (_stations.isNotEmpty) ...[  
              const SizedBox(height: 16),
              const Text('Liste des bornes récupérées:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _stations.length,
                  itemBuilder: (context, index) {
                    final station = _stations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(station.name),
                        subtitle: Text(
                          'ID: ${station.id}\n'
                          'Batteries: ${station.availableBatteries}, '
                          'Emplacements: ${station.availableSlots}\n'
                          'Position: ${station.latitude}, ${station.longitude}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
