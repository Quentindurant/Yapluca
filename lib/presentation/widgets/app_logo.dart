import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_colors.dart';

/// Widget réutilisable pour afficher le logo de l'application YapluCa
class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final bool withBackground;
  final bool usePng;
  
  const AppLogo({
    Key? key,
    this.width = 350,
    this.height = 200,
    this.fit = BoxFit.contain,
    this.withBackground = true,
    this.usePng = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcul de la taille du logo à l'intérieur du conteneur
    final double logoWidth = withBackground ? width * 3 : width;
    final double logoHeight = withBackground ? height * 3 : height;
    
    // Logo Widget (SVG ou PNG selon le paramètre)
    Widget logoWidget;
    
    if (usePng) {
      // Utilisation du logo PNG sans fond
      logoWidget = Image.asset(
        'assets/images/logo-removebg-preview.png',
        width: logoWidth,
        height: logoHeight,
        fit: fit,
      );
    } else {
      // Utilisation du logo SVG
      logoWidget = SvgPicture.asset(
        'assets/images/logo.svg',
        width: logoWidth,
        height: logoHeight,
        fit: fit,
      );
    }
    
    if (withBackground) {
      // Version avec fond blanc - conteneur plus grand pour permettre au logo de s'agrandir
      return Container(
        width: width * 1.5,  // Beaucoup plus large
        height: height * 0.7, // Mais moins haut pour ressembler à l'image de référence
        padding: EdgeInsets.zero, // Pas de padding pour maximiser l'espace du logo
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        // Utilisation de FittedBox pour permettre au logo de s'adapter au conteneur
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: logoWidget,
          ),
        ),
      );
    } else {
      // Version sans fond blanc
      return logoWidget;
    }
  }
}
