import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../data/providers/charging_provider.dart';
import '../../data/models/rent_order_model.dart';
import '../../utils/auth_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/yapluca_logo.dart';
import '../../routes/app_router.dart'; // Correction du chemin d'import AppRouter

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  int _currentIndex = 3; // Index pour la page d'emprunts (maintenant 3)

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Vérifier si l'utilisateur est authentifié
      if (!context.checkAuth()) {
        return; // Ne pas continuer si l'utilisateur n'est pas authentifié
      }
      
      // Charger les emprunts au démarrage
      Provider.of<ChargingProvider>(context, listen: false).fetchUserRentOrders();
    });
  }

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      
      // Navigation vers d'autres écrans selon l'index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/scanner');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chargingProvider = Provider.of<ChargingProvider>(context);
    final userRentOrders = chargingProvider.userRentOrders;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF373643),
        title: const YaplucaLogo(height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Afficher les notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<ChargingProvider>(context, listen: false).fetchUserRentOrders(),
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes emprunts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Afficher les emprunts en cours
                if (chargingProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                else if (userRentOrders.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userRentOrders.length,
                    itemBuilder: (context, index) {
                      final order = userRentOrders[index];
                      return _buildLoanCard(order);
                    },
                  ),
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.battery_alert,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun emprunt en cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas d\'emprunt de batterie en cours.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Emprunter une batterie',
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRouter.qrScanner); // Modification
            },
            icon: Icons.qr_code_scanner,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoanCard(dynamic order) {
    // Extraire les informations de l'ordre de location
    final String orderId = order['id'] ?? 'Inconnu';
    final String deviceId = order['deviceId'] ?? 'Inconnu';
    final String batteryId = order['batteryId'] ?? 'Inconnu';
    final int slotNum = order['slotNum'] ?? 0;
    final String status = order['status'] ?? 'En cours';
    final String createTime = order['createTime'] ?? DateTime.now().toString();
    
    // Calculer la durée d'emprunt
    final DateTime createDateTime = DateTime.tryParse(createTime) ?? DateTime.now();
    final Duration duration = DateTime.now().difference(createDateTime);
    final String durationText = _formatDuration(duration);
    
    // Calculer le coût estimé (exemple: 1€ par heure)
    final double estimatedCost = duration.inHours * 1.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'RENTING' ? AppColors.primaryColor : AppColors.grey400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status == 'RENTING' ? 'En cours' : 'Terminé',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Commande #${orderId.substring(0, math.min(8, orderId.length))}',
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.battery_charging_full,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Batterie portable',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $batteryId',
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Emplacement: $slotNum',
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Durée',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Coût estimé',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${estimatedCost.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (status == 'RENTING')
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Retourner la batterie',
                  onPressed: () => _returnBattery(orderId, deviceId),
                  icon: Icons.assignment_return,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''} ${duration.inHours % 24} heure${duration.inHours % 24 > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''} ${duration.inMinutes % 60} minute${duration.inMinutes % 60 > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
  
  Future<void> _returnBattery(String orderId, String deviceId) async {
    // Afficher une boîte de dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retourner la batterie'),
        content: const Text('Êtes-vous sûr de vouloir retourner cette batterie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
      
      try {
        // Appeler l'API pour retourner la batterie
        final success = await Provider.of<ChargingProvider>(context, listen: false)
            .returnBattery(orderId, deviceId);
        
        // Fermer l'indicateur de chargement
        Navigator.pop(context);
        
        if (success) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Batterie retournée avec succès'),
              backgroundColor: AppColors.successColor,
            ),
          );
        } else {
          // Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du retour de la batterie: ${Provider.of<ChargingProvider>(context, listen: false).errorMessage}'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } catch (e) {
        // Fermer l'indicateur de chargement
        Navigator.pop(context);
        
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }
}
