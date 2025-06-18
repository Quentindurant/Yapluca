import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;

import '../../config/app_colors.dart';
import '../../models/charging_station.dart';
import '../../models/connector_type.dart';
import '../../services/connector_type_service.dart';
import '../../providers/charging_station_provider.dart';
import '../../data/providers/charging_provider.dart';
import '../../data/services/location_service.dart';
import '../../utils/auth_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/yapluca_logo.dart';
import '../../routes/app_router.dart';

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
    var url = options.urlTemplate!
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{r}', r);

    final subdomains = options.subdomains;
    if (subdomains.isNotEmpty) {
      final index = (x + y) % subdomains.length;
      url = url.replaceAll('{s}', subdomains[index]);
    }
    return url;
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

////////////////////////////////////// Connector ////////////////////////////////////////
class _MapScreenState extends State<MapScreen> {
  List<ConnectorType> _connectorTypes = [];
  Map<String, String> _connectorIcons = {}; // id -> icon path

  double? _heading;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  Position? _currentPosition;
  ChargingStation? _selectedStation;
  String _currentMapStyle = 'light';
  List<LatLng> _routePoints = [];
  String? _routeError;
  bool _isLoading = false;
  int _currentIndex = 1;

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
    _askLocationPermission();
    _getCurrentLocation();
    _loadConnectorTypes();
  }

  Future<void> _loadConnectorTypes() async {
    final types = await ConnectorTypeService().getConnectorTypes();
    setState(() {
      _connectorTypes = types;
      _connectorIcons = {for (var t in types) t.id: t.icon};
    });
  }

  Future<void> _askLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showLocationPermissionDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationService = LocationService();
    setState(() => _isLoading = true);

    try {
      final hasPermissions = await locationService.checkAndRequestPermissions();
      if (!hasPermissions) {
        _showLocationPermissionDialog();
        _useDefaultPosition();
        return;
      }

      final position = await locationService.getCurrentPosition(
        onPositionUpdate: (pos) {
          setState(() {
            _currentPosition = pos;
            _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
            _isLoading = false;
          });
        },
      );

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _mapController.move(LatLng(position.latitude, position.longitude), 15);
          _isLoading = false;
        });
      } else {
        _useDefaultPosition();
      }
    } catch (e) {
      _useDefaultPosition();
    }
  }

  void _useDefaultPosition() {
    final defaultLat = 48.8566;
    final defaultLng = 2.3522;
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
      _mapController.move(LatLng(defaultLat, defaultLng), 13);
      _isLoading = false;
    });
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localisation requise'),
        content: const Text('Activez la localisation dans les paramètres '),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // TODO: Intégrer les appels API de https://apifox.com/apidoc/shared/4855b8fe-4c43-48f6-8bd6-37cc29b98fe5
  // Exemple : récupérer les bornes et cabinets, créer les modèles et afficher sur la carte

  @override
  Widget build(BuildContext context) {
    final LatLng center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(48.8566, 2.3522);

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
              // TODO: Afficher les notifications
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
                            text: _isRouteLoading ? 'Chargement...' : 'Itinéraire',
                            onPressed: _isRouteLoading ? null : () { _showRouteToStation(); },
                            height: 40,
                          ),
                        ),
                        if (_routeError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_routeError!, style: TextStyle(color: Colors.red)),
                          ),
                        if (_routePoints.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              child: Text('Effacer l\'itinéraire'),
                              onPressed: _clearRoute,
                            ),
                          ),
                        const SizedBox(width: 12),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),

          

          // Boutons de zoom, style, recentrage
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
                  onPressed: _getCurrentLocation,
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.layers,
                  onPressed: _showMapStyleSelector,
                ),
              ],
            ),
          ),

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
    // === AJOUT : méthodes et variables privées manquantes ===
  String _searchQuery = '';
  bool _isRouteLoading = false;

  void _clearSelectedStation() {
    setState(() {
      _selectedStation = null;
    });
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeError = null;
    });
  }

  Future<void> _showRouteToStation() async {
    if (_currentPosition == null || _selectedStation == null) return;
    setState(() {
      _isRouteLoading = true;
      _routeError = null;
    });
    try {
      final start = _currentPosition!;
      final end = _selectedStation!;
      final apiKey = '5b3ce3597851110001cf624862699bc05cd54f5c9ca8520a053d9ac8';
      final url = Uri.parse('https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;
        final points = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
        setState(() {
          _routePoints = points;
          _isRouteLoading = false;
        });
        if (points.isNotEmpty) {
          _mapController.move(points.first, 15.0);
        }
      } else {
        setState(() {
          _routeError = 'Erreur lors de la récupération de l\'itinéraire';
          _isRouteLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _routeError = 'Erreur: $e';
        _isRouteLoading = false;
      });
    }
  }

  Widget _buildMap() {
    final stationProvider = Provider.of<ChargingStationProvider>(context);
    final chargingProvider = Provider.of<ChargingProvider>(context);
    // === Bornes de test en dur (mode démo) ===
    final demoStations = [
      ChargingStation(
        id: 'station-republique',
        name: 'Station République',
        latitude: 48.867,
        longitude: 2.363,
        totalBatteries: 5,
        availability: 3,
        isOpen: true,
        address: 'Place de la République, Paris',
        connectorTypeId: 'USB-C',
      ),
      ChargingStation(
        id: 'station-gare-lyon',
        name: 'Station Gare de Lyon',
        latitude: 48.844,
        longitude: 2.373,
        totalBatteries: 4,
        availability: 2,
        isOpen: true,
        address: 'Gare de Lyon, Paris',
        connectorTypeId: 'lightning',
      ),
      ChargingStation(
        id: 'station-montparnasse',
        name: 'Station Montparnasse',
        latitude: 48.841,
        longitude: 2.320,
        totalBatteries: 3,
        availability: 1,
        isOpen: true,
        address: 'Gare Montparnasse, Paris',
        connectorTypeId: 'unknow',
      ),
      ChargingStation(
        id: 'station-bastille',
        name: 'Station Bastille',
        latitude: 48.853,
        longitude: 2.369,
        totalBatteries: 6,
        availability: 4,
        isOpen: true,
        address: 'Place de la Bastille, Paris',
        connectorTypeId: 'USB-C',
      ),
      ChargingStation(
        id: 'station-opera',
        name: 'Station Opéra',
        latitude: 48.870,
        longitude: 2.332,
        totalBatteries: 4,
        availability: 2,
        isOpen: true,
        address: 'Opéra Garnier, Paris',
        connectorTypeId: 'lightning',
      ),
      ChargingStation(
        id: 'station-chatelet',
        name: 'Station Châtelet',
        latitude: 48.858,
        longitude: 2.347,
        totalBatteries: 5,
        availability: 3,
        isOpen: true,
        address: 'Châtelet, Paris',
        connectorTypeId: 'USB-C',
      ),
      ChargingStation(
        id: 'station-nation',
        name: 'Station Nation',
        latitude: 48.848,
        longitude: 2.395,
        totalBatteries: 2,
        availability: 1,
        isOpen: true,
        address: 'Place de la Nation, Paris',
        connectorTypeId: 'unknow',
      ),
      ChargingStation(
        id: 'station-trocadero',
        name: 'Station Trocadéro',
        latitude: 48.863,
        longitude: 2.288,
        totalBatteries: 3,
        availability: 2,
        isOpen: true,
        address: 'Trocadéro, Paris',
        connectorTypeId: 'lightning',
      ),
      ChargingStation(
        id: 'station-bnf',
        name: 'Station BNF',
        latitude: 48.833,
        longitude: 2.376,
        totalBatteries: 7,
        availability: 5,
        isOpen: true,
        address: 'Bibliothèque François Mitterrand, Paris',
        connectorTypeId: 'USB-C',
      ),
      ChargingStation(
        id: 'station-defense',
        name: 'Station La Défense',
        latitude: 48.892,
        longitude: 2.236,
        totalBatteries: 6,
        availability: 3,
        isOpen: true,
        address: 'La Défense, Paris',
        connectorTypeId: 'lightning',
      ),
      // Ajoute d'autres bornes si besoin...
    ];
    // Correction : affiche TOUJOURS toutes les bornes de test, sans filtrage
    final stations = [...demoStations, ...stationProvider.nearbyStations];

    final cabinets = chargingProvider.cabinets;
    final LatLng? userPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    final List<Marker> stationMarkers = [];
    for (final station in stations) {
      // Sélectionne l'icône selon le type de connecteur (fallback si inconnu)
      final connectorIcon = _connectorIcons[station.connectorTypeId?.toLowerCase() ?? ''] ??
          'assets/icons/energy.png';
      stationMarkers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(station.latitude, station.longitude),
          child: GestureDetector(
            onTap: () => setState(() => _selectedStation = station),
            child: Image.asset(
              connectorIcon,
              width: 32,
              height: 32,
              color: station.availability > 0 ? AppColors.primaryColor : Colors.red,
              colorBlendMode: BlendMode.modulate,
            ),
          ),
        ),
      );
    }
    for (final cabinet in cabinets) {
      if (cabinet.latitude != null && cabinet.longitude != null) {
        stationMarkers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(cabinet.latitude!, cabinet.longitude!),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStation = ChargingStation(
                    id: cabinet.id ?? 'cabinet-${cabinet.hashCode}',
                    name: cabinet.name ?? 'Borne',
                    address: cabinet.address ?? 'Adresse inconnue',
                    latitude: cabinet.latitude!,
                    longitude: cabinet.longitude!,
                    totalBatteries: cabinet.totalBatteries ?? cabinet.slots ?? 0,
                    availability: cabinet.availableBatteries ?? cabinet.emptySlots ?? 0,
                    isOpen: cabinet.isActive ?? cabinet.online ?? true,
                    openingHours: '24h/24',
                    imageUrl: '',
                    distance: null,
                  );
                });
              },
              child: Image.asset(
                'assets/icons/energy.png',
                width: 28,
                height: 28,
                color: (cabinet.availableBatteries ?? 0) > 0 ? AppColors.primaryColor : Colors.red,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
        );
      }
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        
        
        maxZoom: 20,
        onTap: (_, __) => setState(() => _selectedStation = null),
      ),
      children: [
        TileLayer(
          urlTemplate: _mapStyles[_currentMapStyle]!,
          subdomains: ['a', 'b', 'c'],
          additionalOptions: {'r': '@2x'},
          tileProvider: CachedNetworkTileProvider(),
          maxZoom: 19,
          retinaMode: true,
          userAgentPackageName: 'com.yapluca.app',
        ),
        if (userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 46,
                height: 46,
                point: userPosition,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Champ de vision (cône semi-transparent)
                    if (_heading != null)
                      Transform.rotate(
                        angle: (_heading ?? 0) * (3.1415926535 / 180),
                        child: CustomPaint(
                          size: const Size(46, 46),
                          painter: _VisionConePainter(),
                        ),
                      ),
                    // Cercle de fond pour la position
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 28,
                    ),
                    // Point central
                    Icon(
                      Icons.circle,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        MarkerLayer(markers: stationMarkers),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blueAccent,
                strokeWidth: 5.0,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRoutePolyline() {
    return IgnorePointer(
      child: Builder(
        builder: (context) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              
              
            ),
            children: [
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: Colors.blueAccent,
                    strokeWidth: 5.0,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

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

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        // On est déjà sur la map
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
      } else if (index == 3) {
        Navigator.pushReplacementNamed(context, '/loans');
      } else if (index == 4) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    }
  }
  // === FIN AJOUT ===
}

class _VisionConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primaryColor.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final double angle = 60 * 3.1415926535 / 180; // 60° field of view
    final Offset center = Offset(size.width / 2, size.height / 2);
    final ui.Path path = ui.Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -angle / 2 - 3.1415926535 / 2,
        angle,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

