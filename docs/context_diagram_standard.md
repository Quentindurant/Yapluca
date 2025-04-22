# Diagramme de Contexte - YapluCa

## Description des Acteurs

### Utilisateur Mobile
- **Description** : Utilisateur final de l'application YapluCa
- **Interactions** :
  - Localisation des bornes de recharge
  - Emprunt et retour de batteries
  - Gestion du profil utilisateur
  - Réception de notifications

### Administrateur
- **Description** : Gestionnaire du système YapluCa
- **Interactions** :
  - Gestion des bornes de recharge
  - Consultation des statistiques d'utilisation
  - Administration des utilisateurs
  - Configuration du système

### Partenaire Commercial
- **Description** : Établissement hébergeant des bornes de recharge
- **Interactions** :
  - Suivi de l'utilisation des bornes
  - Accès aux rapports d'activité
  - Gestion des emplacements

## Description des Services Externes

### OpenStreetMap
- **Description** : Service de cartographie gratuit
- **Interactions** :
  - Fourniture des cartes pour la localisation des bornes
  - API de géolocalisation

### Firebase
- **Description** : Plateforme de développement d'applications mobiles
- **Interactions** :
  - Authentification des utilisateurs
  - Base de données en temps réel
  - Stockage des données
  - Service de notifications push

## Légende

- **O**
- **|** : Représente un acteur (utilisateur humain)
- **+--------+**
- **|        |** : Représente un système
- **|        |**
- **+--------+**
- **Ligne** : Représente une interaction entre un acteur et le système

## Remarques

Ce diagramme de contexte illustre les frontières du système YapluCa et ses interactions avec les acteurs externes. Il sert de base pour comprendre la portée du projet et identifier les principales parties prenantes.
