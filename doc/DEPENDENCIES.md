# Dépendances du projet Yapluca

Ce document liste toutes les dépendances Flutter/Dart utilisées dans le projet, ainsi que leur utilité principale. Ce fichier sert de référence rapide pour la migration, la maintenance ou l'audit du projet.

---

## 1. Dépendances principales (pubspec.yaml)

### Firebase & Authentification
- **firebase_core** : Initialisation du SDK Firebase
- **firebase_auth** : Authentification des utilisateurs (email, Google, Facebook, etc.)
- **cloud_firestore** : Base de données temps réel Firestore
- **firebase_storage** : Stockage de fichiers (images, documents)
- **cloud_functions** : Appel de fonctions cloud Firebase
- **google_sign_in** : Authentification Google
- **flutter_facebook_auth** : Authentification Facebook
- **google_sign_in_web** : Auth Google pour le web

### UI/UX & Navigation
- **flutter_map** : Affichage de cartes interactives
- **latlong2** : Gestion des coordonnées géographiques
- **cupertino_icons** : Icônes iOS
- **flutter_svg** : Affichage d'images SVG
- **intl** : Internationalisation, gestion des dates/nombres
- **flutter_cache_manager** : Gestion du cache d'images/fichiers
- **flutter_compass** : Accès à la boussole du device

### Fonctionnalités natives
- **geolocator** : Géolocalisation
- **permission_handler** : Gestion des permissions (GPS, stockage, etc.)
- **shared_preferences** : Stockage local clé/valeur
- **flutter_secure_storage** : Stockage sécurisé (tokens, secrets)
- **url_launcher** : Ouvrir des liens externes
- **mobile_scanner** : Scanner QR/Barcodes (fork local)
- **flutter_stripe** : Paiement Stripe
- **http** : Requêtes HTTP

### State Management
- **provider** : Gestion d'état

---

## 2. Dev dependencies
- **flutter_test** : Outils de tests unitaires Flutter
- **flutter_lints** : Linting et conventions de code
- **flutter_launcher_icons** : Génération des icônes d'app

---

## 3. Assets déclarés
- assets/images/
- assets/icons/
- assets/dynamsoft/

---

## 4. Plugins locaux
- **mobile_scanner** : Chemin local `./mobile_scanner-develop` (fork/patch natif)

---

## 5. Autres fichiers liés
- **codemagic.yaml** : CI/CD (Codemagic)
- **firebase.json, firestore.rules, google-services.json** : Config Firebase

---

## 6. Pour aller plus loin
- Pour la liste complète des versions et sous-dépendances, voir le fichier `pubspec.lock`.
- Pour chaque dépendance, consulter la doc officielle sur pub.dev pour l'équivalent React/JS lors de la migration.

---

**Document généré automatiquement pour la reprise et la migration du projet.**
