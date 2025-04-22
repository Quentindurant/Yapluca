import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../data/models/charging_station.dart';
import '../../data/services/charging_station_service.dart';
import '../../routes/app_router.dart';

/// Écran de détails d'une borne de recharge
class StationDetailsScreen extends StatefulWidget {
  final String stationId;

  const StationDetailsScreen({
    Key? key,
    required this.stationId,
  }) : super(key: key);

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> with SingleTickerProviderStateMixin {
  final ChargingStationService _stationService = ChargingStationService();
  bool _isLoading = true;
  ChargingStation? _station;
  
  // Animation pour les éléments de l'interface
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  // Pour l'effet de chargement
  bool _showLoadingEffect = false;
  Timer? _loadingEffectTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialiser les animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _loadStationDetails();
    
    // Effet de chargement
    _loadingEffectTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showLoadingEffect = !_showLoadingEffect;
        });
      }
    });
    
    // Démarrer l'animation après un court délai
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _loadingEffectTimer?.cancel();
    super.dispose();
  }

  /// Charge les détails de la borne de recharge
  Future<void> _loadStationDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final station = await _stationService.getStationById(widget.stationId);
      setState(() {
        _station = station;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Afficher une erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des détails: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: AppColors.white,
              onPressed: _loadStationDetails,
            ),
          ),
        );
      }
    }
  }

  /// Gère l'emprunt d'une batterie
  void _handleBorrowBattery() {
    if (_station == null || !_station!.hasBatteries) return;

    // Naviguer vers l'écran d'emprunt de batterie
    Navigator.pushNamed(
      context,
      AppRouter.batteryBorrowing,
      arguments: widget.stationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingIndicator()
          : _buildContent(),
    );
  }
  
  /// Construit l'indicateur de chargement
  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            value: _showLoadingEffect ? null : 0.75,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chargement des détails...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Construit le contenu principal de l'écran
  Widget _buildContent() {
    if (_station == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Borne non trouvée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // En-tête avec image et nom de la borne
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _station!.name,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Fond avec dégradé
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Motif de fond
                Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: GridPainter(color: AppColors.white),
                  ),
                ),
                // Icône de la borne
                Center(
                  child: Icon(
                    Icons.store,
                    color: AppColors.white,
                    size: 80,
                  ),
                ),
                // Bouton de retour
                Positioned(
                  top: 40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Contenu principal
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte d'information principale
                  _buildMainInfoCard(),
                  const SizedBox(height: 24),

                  // Section des batteries disponibles
                  Row(
                    children: [
                      Icon(
                        Icons.battery_charging_full,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Disponibilité',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAvailabilityCard(),
                  const SizedBox(height: 24),

                  // Section des informations sur le partenaire
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informations sur le partenaire',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPartnerInfoCard(),
                  const SizedBox(height: 24),

                  // Section des instructions
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Comment emprunter une batterie',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionsCard(),
                  const SizedBox(height: 32),

                  // Bouton d'emprunt
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _station!.hasBatteries ? _handleBorrowBattery : null,
                      icon: Icon(
                        _station!.hasBatteries ? Icons.flash_on : Icons.battery_alert,
                      ),
                      label: Text(
                        _station!.hasBatteries
                            ? 'Emprunter une batterie'
                            : 'Aucune batterie disponible',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _station!.hasBatteries 
                            ? AppColors.primaryColor 
                            : AppColors.error,
                        disabledBackgroundColor: AppColors.error.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construit la carte d'information principale
  Widget _buildMainInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adresse
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _station!.address,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Horaires d'ouverture
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires d\'ouverture',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lun - Ven: 8h00 - 20h00\nSam - Dim: 10h00 - 18h00',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte de disponibilité des batteries
  Widget _buildAvailabilityCard() {
    final bool hasBatteries = _station!.hasBatteries;
    final int availablePercentage = (_station!.availableBatteries / _station!.totalBatteries * 100).round();
    
    return Card(
      elevation: 4,
      shadowColor: AppColors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Indicateur de disponibilité
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasBatteries ? AppColors.primaryColor.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
                    border: Border.all(
                      color: hasBatteries ? AppColors.primaryColor : AppColors.error,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_station!.availableBatteries}/${_station!.totalBatteries}',
                          style: TextStyle(
                            color: hasBatteries ? AppColors.primaryColor : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'batteries',
                          style: TextStyle(
                            color: hasBatteries ? AppColors.primaryColor : AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Informations de disponibilité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasBatteries ? 'Batteries disponibles' : 'Aucune batterie disponible',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: hasBatteries ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasBatteries
                            ? 'Vous pouvez emprunter une batterie dans cette borne.'
                            : 'Toutes les batteries sont actuellement empruntées.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _station!.availableBatteries / _station!.totalBatteries,
                          backgroundColor: AppColors.grey200,
                          color: hasBatteries ? AppColors.success : AppColors.error,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$availablePercentage% de batteries disponibles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte d'information sur le partenaire
  Widget _buildPartnerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informations sur l\'emplacement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Informations du magasin/emplacement
            if (_station?.shopId != null)
              ListTile(
                leading: Icon(
                  Icons.business,
                  color: AppColors.primaryColor.withOpacity(0.7),
                ),
                title: const Text('ID du magasin'),
                subtitle: Text(_station?.shopId ?? 'Non disponible'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            // Prix et caution
            if (_station?.price != null)
              ListTile(
                leading: Icon(
                  Icons.euro,
                  color: AppColors.primaryColor.withOpacity(0.7),
                ),
                title: const Text('Prix de location'),
                subtitle: Text('${_station?.price?.toStringAsFixed(2) ?? '0.00'} €/heure'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            if (_station?.depositAmount != null)
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryColor.withOpacity(0.7),
                ),
                title: const Text('Caution requise'),
                subtitle: Text('${_station?.depositAmount?.toStringAsFixed(2) ?? '0.00'} €'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            // QR Code
            if (_station?.qrCode != null)
              ListTile(
                leading: Icon(
                  Icons.qr_code,
                  color: AppColors.primaryColor.withOpacity(0.7),
                ),
                title: const Text('Code QR disponible'),
                subtitle: const Text('Scannez pour emprunter rapidement'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte d'instructions
  Widget _buildInstructionsCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionStep(
              number: 1,
              title: 'Vérifiez la disponibilité',
              description: 'Assurez-vous qu\'il y a des batteries disponibles dans cette borne.',
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              number: 2,
              title: 'Empruntez une batterie',
              description: 'Appuyez sur le bouton ci-dessous et suivez les instructions à l\'écran.',
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              number: 3,
              title: 'Utilisez la batterie',
              description: 'Connectez votre téléphone à la batterie pour le recharger.',
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              number: 4,
              title: 'Rendez la batterie',
              description: 'Rendez la batterie dans n\'importe quelle borne YapluCa dans les 24 heures.',
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une étape d'instruction
  Widget _buildInstructionStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro de l'étape
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Contenu de l'étape
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Peintre personnalisé pour dessiner un motif de grille
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 20.0;

    // Lignes horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Lignes verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
