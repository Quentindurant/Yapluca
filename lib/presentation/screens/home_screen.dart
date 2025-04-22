import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yapluca_migration/config/app_colors.dart';
import 'package:yapluca_migration/models/charging_station.dart';
import 'package:yapluca_migration/providers/auth_provider.dart';
import 'package:yapluca_migration/providers/charging_station_provider.dart';
import 'package:yapluca_migration/data/providers/charging_provider.dart';
import 'package:yapluca_migration/data/models/cabinet_model.dart';
import 'package:yapluca_migration/data/models/shop_model.dart';
import 'package:yapluca_migration/utils/auth_utils.dart';
import 'package:yapluca_migration/presentation/widgets/bottom_nav_bar.dart';
import 'package:yapluca_migration/presentation/widgets/primary_button.dart';
import 'package:yapluca_migration/presentation/widgets/station_card.dart';
import 'package:yapluca_migration/presentation/widgets/yapluca_logo.dart';
import 'package:yapluca_migration/presentation/screens/map_screen.dart';
import '../../routes/app_router.dart'; // Correction du chemin d'import AppRouter
import 'package:yapluca_migration/utils/geocoding_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yapluca_migration/utils/overpass_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _userCity;
  bool _isGettingCity = false;
  List<OverpassPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.checkAuth()) {
        return;
      }
      Provider.of<ChargingProvider>(context, listen: false).fetchCabinets();
      Provider.of<ChargingStationProvider>(context, listen: false).fetchNearbyStations();
      await _getUserCity();
    });
  }

  Future<void> _getUserCity() async {
    setState(() { _isGettingCity = true; });
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final city = await GeocodingUtils.getCityFromCoordinates(pos.latitude, pos.longitude);
      setState(() { _userCity = city; });
      _fetchNearbyPlaces(pos.latitude, pos.longitude);
    } catch (_) {
      setState(() { _userCity = null; });
    } finally {
      setState(() { _isGettingCity = false; });
    }
  }

  Future<void> _fetchNearbyPlaces(double lat, double lon) async {
    setState(() => _isLoadingPlaces = true);
    try {
      final places = await OverpassUtils.getNearbyPlaces(lat: lat, lon: lon);
      debugPrint('[YapluCa] Overpass: lat=$lat, lon=$lon, lieux trouvés=${places.length}');
      setState(() => _nearbyPlaces = places);
      // Fallback Paris si aucun lieu trouvé
      if (places.isEmpty && (lat != 48.8566 || lon != 2.3522)) {
        debugPrint('[YapluCa] Aucun lieu trouvé, fallback Paris');
        final fallback = await OverpassUtils.getNearbyPlaces(lat: 48.8566, lon: 2.3522);
        setState(() => _nearbyPlaces = fallback);
      }
    } catch (e) {
      debugPrint('[YapluCa] Erreur Overpass: $e');
      setState(() => _nearbyPlaces = []);
    } finally {
      setState(() => _isLoadingPlaces = false);
    }
  }

  List<FavoriteLocationCard> _getFavoritesForCity() {
    // Remplace cette logique par tes vrais favoris si tu as une base de données
    if (_userCity == null) return [];
    final allFavorites = [
      {
        'city': 'Paris',
        'name': 'Parc des princes',
        'image': 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      },
      {
        'city': 'Paris',
        'name': 'Galerie Lafayette',
        'image': 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      },
      {
        'city': 'Lyon',
        'name': 'Le petit café',
        'image': 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1171&q=80',
      },
    ];
    return allFavorites.where((fav) => fav['city']?.toLowerCase() == _userCity?.toLowerCase()).map((fav) => FavoriteLocationCard(
      name: fav['name']!,
      imageUrl: fav['image']!,
      onTap: () {},
    )).toList();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigation vers d'autres écrans selon l'index
    if (index != 0) {
      switch (index) {
        case 1:
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/loans');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final stationProvider = Provider.of<ChargingStationProvider>(context);
    final chargingProvider = Provider.of<ChargingProvider>(context);
    final nearbyStations = stationProvider.nearbyStations;
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
      body: RefreshIndicator(
        onRefresh: () async {
          await stationProvider.fetchNearbyStations();
          await chargingProvider.fetchCabinets();
        },
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Section Lieux à proximité (lieux de la ville)
                _buildSectionHeader('Lieux à proximité'),
                const SizedBox(height: 12),
                if (_isGettingCity || _isLoadingPlaces)
                  const Center(child: CircularProgressIndicator())
                else if (_userCity == null)
                  const Text('Ville non détectée', style: TextStyle(color: Colors.red))
                else if (_nearbyPlaces.isEmpty)
                  Text('Aucun lieu à proximité trouvé pour $_userCity')
                else
                  SizedBox(
                    height: 145,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nearbyPlaces.length > 5 ? 5 : _nearbyPlaces.length,
                      separatorBuilder: (context, i) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final place = _nearbyPlaces[i];
                        // Images différentes pour chaque card restaurant/café/bar, etc.
                        final restaurantImages = [
                          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
                          'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'https://images.unsplash.com/photo-1502301103665-0b95cc738daf?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mzl8fHJlc3RhdXJhbnR8ZW58MHx8MHx8fDA%3D',
                        ];
                        final cafeImages = [
                          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ];
                        final barImages = [
                          'https://images.unsplash.com/photo-1543007630-9710e4a00a20?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'https://images.unsplash.com/photo-1437418747212-8d9709afab22?q=80&w=1664&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=400&q=80',
                        ];
                        final parkImages = [
                          'https://images.unsplash.com/photo-1711369093144-2ada6e035a84?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ];
                        final museumImages = [
                          'https://images.unsplash.com/photo-1554907984-15263bfd63bd?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'https://images.unsplash.com/photo-1491156855053-9cdff72c7f85?q=80&w=2128&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ];
                        final fastFoodImages = [
                          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                          'https://images.unsplash.com/photo-1561758033-d89a9ad46330?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ];
                        final playgroundImages = [
                          'https://images.unsplash.com/photo-1568480289356-5a75d0fd47fc?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ];
                        final castleImages = [
                          'https://images.unsplash.com/photo-1679254137914-afc36bd91a02?q=80&w=1904&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' ,
                        ];
                        final defaultImages = [
                          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80', // jolie ville
                        ];
                        String imageUrl;
                        switch (place.type) {
                          case 'restaurant':
                            imageUrl = restaurantImages[i % restaurantImages.length];
                            break;
                          case 'cafe':
                            imageUrl = cafeImages[i % cafeImages.length];
                            break;
                          case 'bar':
                            imageUrl = barImages[i % barImages.length];
                            break;
                          case 'park':
                            imageUrl = parkImages[i % parkImages.length];
                            break;
                          case 'museum':
                            imageUrl = museumImages[i % museumImages.length];
                            break;
                          case 'fast_food':
                            imageUrl = fastFoodImages[i % fastFoodImages.length];
                            break;
                          case 'playground':
                            imageUrl = playgroundImages[i % playgroundImages.length];
                            break;
                          case 'castle':
                            imageUrl = castleImages[i % castleImages.length];
                            break;
                          default:
                            imageUrl = defaultImages[i % defaultImages.length];
                        }
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: SizedBox(
                            width: 170,
                            height: 138,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    imageUrl,
                                    height: 54,
                                    width: 170,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      height: 54,
                                      width: 170,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 32),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 48,
                                        child: Text(
                                          place.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        place.type,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                // Section Bornes à proximité
                _buildSectionHeader('Bornes à proximité'),
                const SizedBox(height: 16),
                _buildFilterTabs(),
                const SizedBox(height: 16),
                if (stationProvider.isLoading || chargingProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                else if (nearbyStations.isEmpty && cabinets.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: [
                      if (cabinets.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Bornes de recharge disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cabinets.length,
                          itemBuilder: (context, index) {
                            final station = _convertCabinetToStation(cabinets[index]);
                            return StationCard(
                              station: station,
                              onRentNow: () {
                                Navigator.pushNamed(context, AppRouter.qrScanner);
                              },
                              onDetails: () {
                                Navigator.pushNamed(context, '/station_details', arguments: station);
                              },
                              onMap: () {
                                Navigator.pushNamed(context, '/map', arguments: station);
                              },
                            );
                          },
                        ),
                      ],
                      if (nearbyStations.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Bornes à proximité',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: nearbyStations.length,
                          itemBuilder: (context, index) {
                            return StationCard(
                              station: nearbyStations[index],
                              onRentNow: () {
                                Navigator.pushNamed(context, AppRouter.qrScanner);
                              },
                              onDetails: () {
                                Navigator.pushNamed(context, '/station_details', arguments: nearbyStations[index]);
                              },
                              onMap: () {
                                Navigator.pushNamed(context, '/map', arguments: nearbyStations[index]);
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: const [
                Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('Détails', isSelected: true),
        const SizedBox(width: 12),
        _buildFilterTab('Avis'),
        const SizedBox(width: 12),
        _buildFilterTab('Tags'),
      ],
    );
  }

  Widget _buildFilterTab(String label, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        // TODO: Implémenter le filtrage
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune station à proximité',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier votre position ou d\'élargir votre zone de recherche',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Rafraîchir',
                onPressed: () {
                  Provider.of<ChargingStationProvider>(context, listen: false).fetchNearbyStations();
                },
                isFullWidth: false,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Convertir un Cabinet en ChargingStation pour l'affichage
  ChargingStation _convertCabinetToStation(Cabinet cabinet) {
    return ChargingStation(
      id: cabinet.id ?? 'unknown',
      name: cabinet.remark ?? 'Borne de recharge',
      address: 'Emplacement ${cabinet.shopId ?? "inconnu"}',
      distance: '< 1 km',
      availability: cabinet.emptySlots ?? 0,
      totalBatteries: cabinet.slots ?? 0,
      imageUrl: 'https://images.unsplash.com/photo-1565043589221-7546f13df25d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80',
      isOpen: cabinet.online ?? false,
      openingHours: '24h/24',
      latitude: 0.0, // Coordonnées par défaut
      longitude: 0.0, // Coordonnées par défaut
    );
  }
  
  // Afficher les détails d'une borne
  void _showCabinetDetails(Cabinet cabinet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cabinet.remark ?? 'Borne de recharge',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', cabinet.id ?? 'N/A'),
              _buildDetailRow('Type', cabinet.type ?? 'N/A'),
              _buildDetailRow('Statut', cabinet.online == true ? 'En ligne' : 'Hors ligne'),
              _buildDetailRow('Batteries disponibles', '${cabinet.emptySlots ?? 0}/${cabinet.slots ?? 0}'),
              _buildDetailRow('QR Code', cabinet.qrCode ?? 'N/A'),
              _buildDetailRow('Magasin', cabinet.shopId ?? 'N/A'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Emprunter une batterie',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.qrScanner);
                  },
                  icon: Icons.battery_charging_full,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Construire une ligne de détails
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
