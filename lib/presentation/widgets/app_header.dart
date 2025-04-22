import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';

/// Widget d'en-tête réutilisable pour l'application YapluCa
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Titre à afficher dans l'en-tête
  final String title;
  
  /// Actions à afficher à droite de l'en-tête
  final List<Widget>? actions;
  
  /// Indique si le bouton de retour doit être affiché
  final bool showBackButton;
  
  /// Style d'affichage du header (standard ou élégant)
  final HeaderStyle style;
  
  /// Fonction appelée lorsque le bouton de retour est pressé
  final VoidCallback? onBackPressed;

  const AppHeader({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.style = HeaderStyle.standard,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case HeaderStyle.elegant:
        return _buildElegantHeader(context);
      case HeaderStyle.standard:
      default:
        return _buildStandardHeader(context);
    }
  }
  
  /// Construit un header standard avec AppBar
  Widget _buildStandardHeader(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadius),
          bottomRight: Radius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }
  
  /// Construit un header élégant avec un design personnalisé
  Widget _buildElegantHeader(BuildContext context) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadius),
          bottomRight: Radius.circular(AppTheme.borderRadius),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Titre centré
          Positioned.fill(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          // Bouton retour à gauche
          if (showBackButton)
            Positioned(
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            ),
          
          // Actions à droite
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Styles disponibles pour l'en-tête
enum HeaderStyle {
  /// Style standard avec AppBar
  standard,
  
  /// Style élégant avec design personnalisé
  elegant,
}
