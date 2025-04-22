import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_colors.dart';
import '../../models/charging_station.dart';
import '../../providers/charging_station_provider.dart';
import '../../data/providers/charging_provider.dart';
import '../../data/models/cabinet_model.dart';
import '../../data/services/location_service.dart';
import '../../utils/auth_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/yapluca_logo.dart';
import '../../routes/app_router.dart'; // Correction du chemin d'import AppRouter

/// Fournisseur de tuiles de carte avec mise en cache pour de meilleures performances
class CachedNetworkTileProvider extends TileProvider {
  final BaseCacheManager _cacheManager;

  CachedNetworkTileProvider({BaseCacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    
    return NetworkImage(url);
  }

  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final z = coordinates.z;
    final x = coordinates.x;
    final y = coordinates.y;
    final r = options.additionalOptions['r'] ?? '';
    
    String url = '';
    if (options.urlTemplate != null) {
      url = options.urlTemplate!
          .replaceAll('{z}', z.toString())
          .replaceAll('{x}', x.toString())
          .replaceAll('{y}', y.toString())
          .replaceAll('{r}', r);
    } else {
      // URL de secours si urlTemplate est null
      url = 'https://tile.openstreetmap.org/$z/$x/$y.png'
          .replaceAll('$z', z.toString())
          .replaceAll('$x', x.toString())
          .replaceAll('$y', y.toString());
    }
    
    final subdomains = options.subdomains;
    if (subdomains.isNotEmpty) {
      final index = (x + y) % subdomains.length;
      return url.replaceAll('{s}', subdomains[index]);
    }
    
    return url;
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  int _currentIndex = 1;
  Position? _currentPosition;
  ChargingStation? _selectedStation;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [
    'Tour Eiffel, 75007 Paris',
    '1 rue de Rivoli, 75001 Paris',
  ];
  bool _isLoading = false;
  String? _locationError;

  // Ajouter une variable pour le style de carte
  String _currentMapStyle = 'light';

  // Définir les différents styles de carte disponibles
  final Map<String, String> _mapStyles = {
    'standard': 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'light': 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
    'dark': 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    'terrain': 'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.png',
    'toner': 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}{r}.png',
    'watercolor': 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Vérifier si l'utilisateur est authentifié
      if (!context.checkAuth()) {
        return; // Ne pas continuer si l'utilisateur n'est pas authentifié
      }
      await _askLocationPermission();
      _getCurrentLocation();
      Provider.of<ChargingStationProvider>(context, listen: false).fetchNearbyStations();
      // Charger les bornes réelles depuis l'API
      Provider.of<ChargingProvider>(context, listen: false).fetchCabinets();
    });
  }

  Future<void> _askLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission accordée, rien à faire de plus
    } else if (status.isDenied) {
      // Permission refusée, tu peux afficher un message ou proposer d'ouvrir les paramètres
      _showLocationPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      // L'utilisateur a refusé définitivement la permission
      openAppSettings();
    }
  }

  /// Demande la permission de géolocalisation et récupère la position actuelle
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      // Importer le service de localisation
      final locationService = LocationService();

      // Vérifier les permissions d'abord
      bool hasPermissions = await locationService.checkAndRequestPermissions();
      if (!hasPermissions) {
        setState(() {
          _locationError = 'Permissions de localisation non accordées';
          _isLoading = false;
        });
        
        // Afficher un dialogue pour guider l'utilisateur
        _showLocationPermissionDialog();
        return;
      }

      // Utiliser la stratégie optimisée du service de localisation
      Position? position = await locationService.getCurrentPosition(
        onPositionUpdate: (Position updatedPosition) {
          // Cette fonction sera appelée deux fois potentiellement:
          // 1. D'abord avec la dernière position connue (rapide mais moins précise)
          // 2. Ensuite avec la position actuelle précise (plus lente mais plus précise)
          setState(() {
            _currentPosition = updatedPosition;
            _mapController.move(
              LatLng(updatedPosition.latitude, updatedPosition.longitude),
              15.0,
            );
            _isLoading = false;
          });
          
          // Charger les stations à proximité à chaque mise à jour de position
          _loadNearbyStations(updatedPosition.latitude, updatedPosition.longitude);
        },
      );

      // Si nous avons une position initiale (sans callback), l'utiliser
      if (position != null && _currentPosition == null) {
        setState(() {
          _currentPosition = position;
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
          _isLoading = false;
        });
        
        // Charger les stations à proximité
        _loadNearbyStations(position.latitude, position.longitude);
      } else if (position == null && _currentPosition == null) {
        // Si aucune position n'a été obtenue, utiliser la position par défaut
        setState(() {
          _locationError = 'Impossible d\'obtenir votre position. Utilisation d\'une position par défaut.';
          _isLoading = false;
        });
        
        _useDefaultPosition();
      }
    } catch (e) {
      setState(() {
        _locationError = 'Erreur lors de la récupération de la position: $e';
        _isLoading = false;
      });
      print('Erreur de géolocalisation: $e');
      
      // En cas d'erreur, utiliser une position par défaut
      _useDefaultPosition();
    }
  }

  /// Méthode pour utiliser une position par défaut (Paris)
  void _useDefaultPosition() {
    // Coordonnées de Paris
    double defaultLat = 48.8566;
    double defaultLng = 2.3522;
    
    setState(() {
      _currentPosition = Position(
        latitude: defaultLat,
        longitude: defaultLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      
      _mapController.move(
        LatLng(defaultLat, defaultLng),
        13.0, // Zoom un peu plus éloigné pour voir plus de Paris
      );
    });
    
    // Charger les stations à proximité
    _loadNearbyStations(defaultLat, defaultLng);
  }

  /// Charger les stations à proximité
  void _loadNearbyStations(double latitude, double longitude) {
    Provider.of<ChargingStationProvider>(context, listen: false)
        .fetchNearbyStations(latitude: latitude, longitude: longitude);
  }

  /// Afficher un dialogue pour guider l'utilisateur sur l'activation des permissions
  Future<void> _showLocationPermissionDialog() {
    final locationService = LocationService();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions de localisation requises'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text('Les permissions de localisation sont nécessaires pour afficher les bornes de recharge près de vous.'),
                SizedBox(height: 10),
                Text('Veuillez suivre ces étapes pour activer la localisation:'),
                SizedBox(height: 10),
                Text('1. Ouvrez les Paramètres de votre appareil'),
                Text('2. Allez dans Applications > YapluCa'),
                Text('3. Sélectionnez Autorisations > Localisation'),
                Text('4. Activez l\'accès à la localisation'),
                SizedBox(height: 10),
                Text('Note: Sur certains appareils Android, vous devrez peut-être activer la localisation précise et l\'autorisation "Autoriser tout le temps" pour une meilleure expérience.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ouvrir les Paramètres de l\'application'),
              onPressed: () {
                Navigator.of(context).pop();
                locationService.openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Ouvrir les Paramètres de localisation'),
              onPressed: () {
                Navigator.of(context).pop();
                locationService.openLocationSettings();
              },
            ),
            TextButton(
              child: const Text('Continuer sans localisation'),
              onPressed: () {
                Navigator.of(context).pop();
                // Utiliser une position par défaut
                _useDefaultPosition();
              },
            ),
          ],
        );
      },
    );
  }

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
      } else if (index == 3) {
        Navigator.pushReplacementNamed(context, '/loans');
      } else if (index == 4) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    }
  }

  void _selectStation(ChargingStation station) {
    setState(() {
      _selectedStation = station;
    });
    
    _mapController.move(
      LatLng(station.latitude, station.longitude),
      15.0,
    );
  }

  void _clearSelectedStation() {
    setState(() {
      _selectedStation = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<ChargingStationProvider>(context);
    final chargingProvider = Provider.of<ChargingProvider>(context);
    final stations = stationProvider.nearbyStations;
    final cabinets = chargingProvider.cabinets;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF373643),
        title: const YaplucaLogo(height: 40),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Afficher les notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic, color: Colors.white),
            tooltip: 'Support',
            onPressed: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          
          // Barre de recherche
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un lieu...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey600),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          
          // Détails de la station sélectionnée
          if (_selectedStation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStation!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: _selectedStation!.availability > 0
                                        ? AppColors.primaryColor
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedStation!.availability > 0
                                        ? '${_selectedStation!.availability} disponibles'
                                        : 'Aucune disponible',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedStation!.availability > 0
                                          ? AppColors.textSecondary
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedStation!.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSelectedStation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 1, color: AppColors.grey200),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Itinéraire',
                            onPressed: () {
                              // Afficher l'itinéraire
                            },
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Réserver',
                            onPressed: () {
                              // Réserver une batterie
                            },
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Boutons de zoom et de localisation
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    _getCurrentLocation();
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.layers,
                  onPressed: () {
                    _showMapStyleSelector();
                  },
                ),
              ],
            ),
          ),
          
          // Indicateur de chargement de la localisation
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildMap() {
    final stationProvider = Provider.of<ChargingStationProvider>(context);
    final chargingProvider = Provider.of<ChargingProvider>(context);
    final stations = stationProvider.nearbyStations;
    final cabinets = chargingProvider.cabinets;
    
    // Position par défaut (Paris)
    final LatLng defaultPosition = LatLng(48.8566, 2.3522);
    
    // Position actuelle ou par défaut
    final LatLng center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : defaultPosition;
    
    // Préparer les marqueurs de stations en dehors du build pour optimiser les performances
    final List<Marker> stationMarkers = [];
    
    // Ajouter les marqueurs pour les stations fictives
    if (stations.isNotEmpty) {
      for (final station in stations) {
        stationMarkers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(station.latitude, station.longitude),
            child: GestureDetector(
              onTap: () => _selectStation(station),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: station.availability > 0
                      ? AppColors.primaryColor
                      : Colors.red,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    // Ajouter les marqueurs pour les bornes réelles
    if (cabinets.isNotEmpty) {
      for (final cabinet in cabinets) {
        // Vérifier si les coordonnées sont valides
        if (cabinet.latitude != null && cabinet.longitude != null) {
          final ChargingStation station = ChargingStation(
            id: cabinet.id ?? 'cabinet-${cabinet.hashCode}',
            name: cabinet.name ?? 'Borne ${cabinet.id ?? cabinet.hashCode}',
            address: cabinet.address ?? 'Adresse non disponible',
            latitude: cabinet.latitude!,
            longitude: cabinet.longitude!,
            totalBatteries: cabinet.totalBatteries ?? cabinet.slots ?? 0,
            availability: cabinet.availableBatteries ?? cabinet.emptySlots ?? 0,
            isOpen: cabinet.isActive ?? cabinet.online ?? true,
            openingHours: '24h/24',
            imageUrl: 'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80',
            distance: _currentPosition != null
                ? '${(Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  cabinet.latitude!,
                  cabinet.longitude!,
                ) / 1000).toStringAsFixed(1)} km' // Convertir en km
                : null,
          );
          
          stationMarkers.add(
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(cabinet.latitude!, cabinet.longitude!),
              child: GestureDetector(
                onTap: () => _selectStation(station),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.battery_charging_full,
                    color: (cabinet.availableBatteries ?? 0) > 0
                        ? AppColors.primaryColor
                        : Colors.red,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds(center, center),
          maxZoom: 14.0,
          minZoom: 14.0,
        ),
        maxZoom: 18.0,
        minZoom: 3.0,
        onTap: (_, __) {
          // Désélectionner la station en cliquant ailleurs sur la carte
          setState(() {
            _selectedStation = null;
          });
        },
      ),
      children: [
        // Couche de tuiles de carte
        TileLayer(
          urlTemplate: _mapStyles[_currentMapStyle],
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.yapluca.app',
          // Ajouter des options de mise en cache pour améliorer les performances
          tileProvider: CachedNetworkTileProvider(),
        ),
        
        // Marqueur de position actuelle
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        
        // Couche de marqueurs pour toutes les stations
        MarkerLayer(markers: stationMarkers),
      ],
    );
  }

  // Méthode pour construire un bouton de contrôle de la carte
  Widget _buildMapControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryColor),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 20,
      ),
    );
  }

  // Méthode pour afficher le sélecteur de style de carte
  void _showMapStyleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir un style de carte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mapStyles.keys.map((style) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentMapStyle = style;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentMapStyle == style
                          ? AppColors.primaryColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      style.substring(0, 1).toUpperCase() + style.substring(1),
                      style: TextStyle(
                        color: _currentMapStyle == style ? Colors.white : AppColors.textPrimary,
                        fontWeight: _currentMapStyle == style ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
