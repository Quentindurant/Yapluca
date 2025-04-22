import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../routes/app_router.dart';

/// Widget de navigation en bas de l'écran pour l'application YapluCa
class YapluCaBottomNavigation extends StatelessWidget {
  /// Index de l'élément actuellement sélectionné
  final int currentIndex;
  
  /// Indique si le scanner QR doit être affiché sur la carte
  final bool showQrScannerOnMap;
  
  /// Indique si l'utilisateur a des emprunts actifs
  final bool hasActiveBorrowings;
  
  /// Montant total des cautions
  final double totalDepositAmount;

  const YapluCaBottomNavigation({
    Key? key,
    this.currentIndex = 0,
    this.showQrScannerOnMap = false,
    this.hasActiveBorrowings = false,
    this.totalDepositAmount = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex == 2 ? 1 : currentIndex, // Correction pour que le scanner ne soit jamais sélectionné
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          // Scanner QR - affiché uniquement sur la carte
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.qr_code_scanner),
                if (currentIndex == 1 && showQrScannerOnMap)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Scanner',
          ),
          // Emprunts - avec badge pour le montant total des cautions
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.battery_charging_full),
                if (hasActiveBorrowings)
                  Positioned(
                    right: -8,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${totalDepositAmount.toInt()}€',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Emprunts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  /// Gère la navigation lorsqu'un élément est sélectionné
  void _onItemTapped(BuildContext context, int index) {
    // Ne rien faire si on clique sur l'élément déjà sélectionné
    if (index == currentIndex && index != 2) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.map);
        break;
      case 2:
        Navigator.pushNamed(context, AppRouter.qrScanner);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.borrowings);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRouter.profile);
        break;
    }
  }
}
