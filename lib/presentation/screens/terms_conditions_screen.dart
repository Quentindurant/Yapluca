import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Conditions d'utilisation de YapluCa",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Définitions\n"
                "- Les données collectées sont toutes les données transmises depuis l'appareil de l'utilisateur, soit à YapluCa, soit à un tiers.\n"
                "- Les données partagées sont les données transférées à un tiers.\n"
                "- Les données traitées de façon éphémère sont utilisées uniquement le temps de répondre à une demande précise.\n\n"
                "Ce que nous divulguons :\n"
                "- Tous les types de données utilisateur collectés et/ou partagés.\n"
                "- Toutes les données transmises par les bibliothèques ou SDK utilisés dans l'appli, que ce soit à YapluCa ou à un tiers.\n"
                "- Toutes les données transférées de notre serveur à un tiers ou à une autre appli tierce sur l'appareil.\n"
                "- Toutes les données collectées ou transférées via WebView, sauf si l'utilisateur navigue sur le Web ouvert.\n\n"
                "Nous respectons la confidentialité de vos données. Pour toute question, contactez le support.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
