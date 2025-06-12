# Documentation technique complète du projet Yapluca

## 1. Présentation générale

Yapluca est une application Flutter multi-plateforme (iOS/Android/Web) centrée autour de la gestion de stations de recharge, d’emprunt de batteries, et de services utilisateurs associés (auth, paiement, géolocalisation, etc.). L’architecture du code est modulaire, orientée métier, et sépare bien la logique, l’UI, les modèles et les services.

---

## 2. Arborescence et organisation du code (lib/)

- **config/** : Thèmes, couleurs, configurations UI, paramètres Firebase.
- **core/** : (Vide ou à compléter)
- **data/** : Modèles de données, providers (gestion d’état), repositories, services d’accès aux données.
    - **models/** : Modèles de données métiers (Battery, User, ChargingStation, Shop, etc.).
    - **providers/** : Providers pour la gestion d’état (ex : charging_provider).
    - **repositories/** : (Vide ou à compléter)
- **domain/** : (Contient un sous-dossier models, usage à préciser)
- **models/** : Modèles de données principaux (charging_station, rent_order, user, etc.).
- **presentation/** : Toute la couche UI (widgets, écrans, providers d’UI).
    - **providers/** : Providers liés à l’UI (auth_provider, station_provider).
    - **screens/** : Tous les écrans/pages de l’app (login, home, map, admin, profile, etc.).
    - **widgets/** : Composants UI réutilisables (boutons, cartes, header, etc.).
- **providers/** : Providers principaux (auth_provider, charging_station_provider).
- **routes/** : Définition des routes/navigation (app_router).
- **services/** : Services métiers (auth_service, firestore_service, charging_station_service, etc.).
- **utils/** : Fonctions utilitaires (auth_utils, geocoding_utils, overpass_utils).
- **main.dart** : Point d’entrée de l’application.

---

## 3. Fonctionnement global

### a. Authentification & Sécurité
- Auth multi-fournisseurs : Firebase Auth (email, Google, Facebook).
- Providers et services dédiés : `auth_provider`, `auth_service`.
- Stockage sécurisé des tokens avec `flutter_secure_storage`.

### b. Gestion des utilisateurs et profils
- Modèle `user_model.dart` (lib/models et data/models/user.dart).
- Écrans : login, register, edit_profile, profile, support.

### c. Gestion des stations et batteries
- Modèles : `charging_station`, `battery_model`, `cabinet_model`, etc.
- Providers : `charging_station_provider`, `charging_provider`.
- Services : `charging_station_service`, `firestore_service`.
- Écrans : map_screen, station_details_screen, borrowings_screen, loans_screen.

### d. Paiement
- Intégration Stripe via `flutter_stripe`.
- Widget dédié : `stripe_payment_button`.

### e. Géolocalisation & Map
- Utilisation de `geolocator`, `flutter_map`, `latlong2`.
- Écran principal : `map_screen`.

### f. Scan QR/Barcodes
- Plugin natif local `mobile_scanner` (fork dans `mobile_scanner-develop`).
- Écrans : `minimal_qr_scanner`, `webview_scanner`.

### g. Navigation
- Centralisée dans `routes/app_router.dart`.
- Utilisation probable de Navigator 2.0 ou package équivalent.

### h. Gestion d’état
- Providers multiples (auth, charging, station, etc.) dans `providers/` et `presentation/providers/`.
- Utilisation du package `provider`.

### i. UI/UX
- Thèmes, couleurs, styles dans `config/`.
- Composants réutilisables dans `presentation/widgets/`.
- Styles spécifiques pour l’auth, le dashboard, etc.

---

## 4. Modèles de données principaux

- **User** : Attributs d’authentification, profil, historique d’emprunt.
- **ChargingStation** : Localisation, disponibilité, capacité, etc.
- **Battery** : Statut, historique, association à un user/station.
- **Cabinet** : Conteneur physique de batteries.
- **Shop** : Points de retrait/partenaires.
- **RentOrder** : Emprunt en cours ou passé.

---

## 5. Écrans principaux (screens/)

- **login_screen.dart** : Connexion utilisateur
- **register_screen.dart** : Inscription
- **home_screen.dart** : Tableau de bord principal
- **map_screen.dart** : Carte interactive des stations
- **profile_screen.dart** : Profil utilisateur
- **edit_profile_screen.dart** : Modification du profil
- **admin_dashboard_screen.dart** : Interface admin
- **station_details_screen.dart** : Détails d’une station
- **borrowings_screen.dart** : Liste des emprunts
- **battery_borrowing_screen.dart** : Emprunt de batterie
- **loans_screen.dart** : Prêts en cours
- **support_screen.dart** : Support utilisateur
- **terms_conditions_screen.dart** : CGU
- **splash_screen.dart** : Splash/chargement
- **webview_scanner.dart**, **minimal_qr_scanner.dart** : Scan QR

---

## 6. Services et logique métier

- **auth_service.dart** : Toute la logique d’authentification (Firebase, Google, Facebook, gestion tokens).
- **firestore_service.dart** : Accès à la base Firestore (CRUD, requêtes complexes).
- **charging_station_service.dart** : Gestion métier des stations et batteries.
- **google_sign_in_platform.dart** : Intégration Google sign-in spécifique plateforme.

---

## 7. Utilitaires

- **auth_utils.dart** : Fonctions utilitaires liées à l’auth.
- **geocoding_utils.dart** : Fonctions de géocodage/adresses.
- **overpass_utils.dart** : Fonctions pour requêtes Overpass (cartographie).

---

## 8. Plugins natifs et spécifiques

- **mobile_scanner-develop/** : Fork local du plugin scanner QR/Barcodes, modifié pour besoins spécifiques.
- **flutter_secure_storage** : Stockage sécurisé natif.
- **flutter_map** : Affichage cartographique natif.
- **flutter_stripe** : Paiement natif Stripe.

---

## 9. Documentation et ressources annexes

- **docs/** : CDC, diagrammes, Gantt, diagrammes de contexte/activité/package, etc.
- **assets/** : Images, icônes, ressources statiques.

---

## 10. Conseils pour la reprise ou la migration

- Bien cartographier les modèles et services principaux.
- Identifier tous les écrans et leur logique métier associée.
- Repérer les dépendances natives à remplacer côté React/JS.
- S’appuyer sur les diagrammes du dossier docs/ pour comprendre les flux et l’architecture.
- Compléter le README avec les infos de ce document pour onboarder rapidement un nouveau dev.

---

**Document généré automatiquement pour la reprise, la maintenance ou la migration du projet Yapluca.**
