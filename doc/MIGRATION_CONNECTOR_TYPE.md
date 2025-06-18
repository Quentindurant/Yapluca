# Migration : Ajout de la gestion des types de connecteur

## 1. Nouvelle collection Firestore : connector_types

Exemple de document :
{
  id: "usb-c",
  name: "USB-C",
  icon: "assets/icons/usb_c.png",
  description: "Connecteur universel USB Type-C."
}

## 2. Modèle Dart ajouté : lib/models/connector_type.dart
## 3. Service ajouté : lib/services/connector_type_service.dart
## 4. Ajout du champ favoriteConnectorTypeId dans UserModel
## 5. Ajout du champ connectorTypeId dans ChargingStationModel
## 6. Ajout du sélecteur de connecteur favori sur la page profil
## 7. Préparation de l’affichage d’icônes différentes sur la carte selon le type de connecteur

Pour compléter :
- Ajouter les icônes des connecteurs dans assets/icons/ et référencer le chemin dans Firestore.
- Mettre à jour la collection charging_stations pour chaque station avec le champ connectorTypeId.
- Compléter la logique d’affichage de la carte pour utiliser _buildStationMarker.

---

**Cette migration permet à chaque utilisateur de choisir un connecteur favori et d’afficher des stations avec des icônes différentes selon le type de connecteur.**
