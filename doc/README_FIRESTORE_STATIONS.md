# Ajout de bornes de test avec types de connecteurs dans Firestore

Pour tester la fonctionnalité de différenciation des types de connecteurs sur la carte et dans le profil utilisateur, ajoutez ces bornes dans la collection `charging_stations` de Firestore :

- **station-republique**
  - name: Station République
  - latitude: 48.867
  - longitude: 2.363
  - connectorTypeId: USB-C
  - description: Borne test USB-C au centre de Paris

- **station-gare-lyon**
  - name: Station Gare de Lyon
  - latitude: 48.844
  - longitude: 2.373
  - connectorTypeId: lightning
  - description: Borne test Lightning à la gare de Lyon

- **station-montparnasse**
  - name: Station Montparnasse
  - latitude: 48.841
  - longitude: 2.320
  - connectorTypeId: unknow
  - description: Borne test Micro-USB à Montparnasse

**N'oubliez pas :**
- Le champ `connectorTypeId` doit correspondre à un id de la collection `connector_types`
- Ajoutez les icônes dans `assets/icons/` pour que l'affichage soit correct
- L'utilisateur peut choisir son favori depuis le profil, et la liste est toujours à jour
