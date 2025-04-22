import 'package:flutter/material.dart';
import 'package:yapluca_migration/config/app_colors.dart';
import 'package:yapluca_migration/routes/app_router.dart';

/// Classe contenant les styles pour les écrans du tableau de bord
class DashboardStyles {
  // Style pour l'AppBar
  static AppBar appBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  // Style pour le BottomNavigationBar
  static BottomNavigationBar bottomNavigationBar(int selectedIndex, Function(int) onTap) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.electrical_services),
          label: 'Bornes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Statistiques',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Utilisateurs',
        ),
      ],
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }

  // Style pour les titres de section
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  // Style pour les sous-titres
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Style pour les valeurs importantes
  static TextStyle valueStyle(Color color) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  // Style pour les boutons d'action
  static ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Style pour les cartes
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Padding standard pour les conteneurs
  static const EdgeInsets standardPadding = EdgeInsets.all(16.0);

  // Style pour les chips de filtre
  static Chip buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          width: 1,
        ),
      ),
      onDeleted: null,
      deleteIcon: null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // Style pour les cartes de statistiques
  static Container buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Style pour le footer commun à toutes les pages
  static Widget buildFooter(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterItem(context, Icons.home, 'Accueil', currentIndex == 0),
              _buildFooterItem(context, Icons.map, 'Carte', currentIndex == 1),
              _buildFooterItem(context, Icons.qr_code_scanner, 'Scanner', currentIndex == 2),
              _buildFooterItem(context, Icons.history, 'Historique', currentIndex == 3),
              _buildFooterItem(context, Icons.person, 'Profil', currentIndex == 4),
            ],
          ),
        ),
      ),
    );
  }

  // Élément du footer
  static Widget _buildFooterItem(BuildContext context, IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          if (label == 'Accueil') {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (label == 'Carte') {
            Navigator.pushReplacementNamed(context, AppRouter.map);
          } else if (label == 'Scanner') {
            Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
          } else if (label == 'Historique') {
            Navigator.pushReplacementNamed(context, AppRouter.borrowings);
          } else if (label == 'Profil') {
            Navigator.pushReplacementNamed(context, AppRouter.profile);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
