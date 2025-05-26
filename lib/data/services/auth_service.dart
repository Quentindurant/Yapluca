import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_models;
import '../../main.dart' show isFirebaseAvailable;

/// Service pour gérer l'authentification des utilisateurs avec Firebase
class AuthService {
  // Services Firebase
  firebase_auth.FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;
  
  // Mode de secours si Firebase n'est pas disponible
  bool _useLocalMode = false;
  app_models.User? _mockUser;
  bool _isLoggedIn = false;
  final List<app_models.User> _registeredUsers = [];
  
  // Clés pour SharedPreferences (mode local)
  static const String _usersKey = 'yapluca_users';
  static const String _isLoggedInKey = 'yapluca_is_logged_in';
  static const String _currentUserKey = 'yapluca_current_user';
  
  AuthService() {
    // Vérifier si Firebase est disponible (variable globale définie dans main.dart)
    if (isFirebaseAvailable) {
      try {
        _firebaseAuth = firebase_auth.FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _useLocalMode = false;
        print('AuthService: Mode Firebase actif');
      } catch (e) {
        _useLocalMode = true;
        print('AuthService: Erreur lors de l\'initialisation de Firebase: $e');
      }
    } else {
      _useLocalMode = true;
      print('AuthService: Mode local actif (Firebase non disponible)');
    }
    
    // Charger les données locales dans tous les cas
    _loadLocalData();
  }
  
  /// Charge les données depuis SharedPreferences (mode local)
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Charger l'état de connexion
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      // Charger les utilisateurs enregistrés
      final usersJson = prefs.getStringList(_usersKey);
      if (usersJson != null && usersJson.isNotEmpty) {
        _registeredUsers.clear();
        for (final userJson in usersJson) {
          try {
            final userMap = jsonDecode(userJson) as Map<String, dynamic>;
            final user = app_models.User.fromJson(userMap);
            _registeredUsers.add(user);
          } catch (e) {
            print('Erreur lors du chargement d\'un utilisateur: $e');
          }
        }
      }
      
      // Charger l'utilisateur actuel
      final currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null && _isLoggedIn) {
        try {
          final userMap = jsonDecode(currentUserJson) as Map<String, dynamic>;
          _mockUser = app_models.User.fromJson(userMap);
        } catch (e) {
          print('Erreur lors du chargement de l\'utilisateur actuel: $e');
          _isLoggedIn = false;
        }
      }
      
      // Si aucun utilisateur n'est enregistré, créer l'utilisateur de démonstration
      if (_registeredUsers.isEmpty) {
        _createLocalDemoUser();
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      _createLocalDemoUser();
    }
  }
  
  /// Sauvegarde les données dans SharedPreferences (mode local)
  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sauvegarder l'état de connexion
      await prefs.setBool(_isLoggedInKey, _isLoggedIn);
      
      // Sauvegarder les utilisateurs enregistrés
      final usersJson = _registeredUsers.map((user) => jsonEncode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
      
      // Sauvegarder l'utilisateur actuel
      if (_mockUser != null) {
        await prefs.setString(_currentUserKey, jsonEncode(_mockUser!.toJson()));
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des données: $e');
    }
  }
  
  /// Crée l'utilisateur de démonstration (mode local)
  void _createLocalDemoUser() {
    final demoUser = app_models.User(
      id: 'user123',
      email: 'demo@yapluca.com',
      fullName: 'Utilisateur YapluCa',
      phoneNumber: '+33612345678',
      isAdmin: true, // Admin pour pouvoir voir tous les utilisateurs
      activeBorrowings: const [], // Liste vide d'emprunts actifs
      depositAmount: 10.0,
      avatarUrl: null,
      memberSince: DateTime.now().subtract(const Duration(days: 30)),
    );
    
    // Ajouter l'utilisateur de démonstration à la liste des utilisateurs enregistrés
    _registeredUsers.add(demoUser);
    
    // Définir l'utilisateur actuel comme l'utilisateur de démonstration
    _mockUser = demoUser;
  }
  
  /// Convertit un utilisateur Firebase en utilisateur de l'application
  Future<app_models.User?> _firebaseUserToAppUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null || _useLocalMode || _firestore == null) return null;
    
    try {
      // Récupérer les données de l'utilisateur depuis Firestore
      final userDoc = await _firestore!.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        // L'utilisateur existe dans Firestore
        final userData = userDoc.data()!;
        
        return app_models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: userData['fullName'] ?? firebaseUser.displayName ?? 'Utilisateur',
          phoneNumber: userData['phoneNumber'] ?? firebaseUser.phoneNumber,
          isAdmin: userData['isAdmin'] ?? false,
          activeBorrowings: List<String>.from(userData['activeBorrowings'] ?? []),
          depositAmount: (userData['depositAmount'] ?? 10.0).toDouble(),
          avatarUrl: userData['avatarUrl'] ?? firebaseUser.photoURL,
          memberSince: userData['memberSince'] != null 
              ? (userData['memberSince'] as Timestamp).toDate()
              : DateTime.now(),
        );
      } else {
        // L'utilisateur n'existe pas encore dans Firestore, créer un nouveau document
        final newUser = app_models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? 'Utilisateur',
          phoneNumber: firebaseUser.phoneNumber,
          isAdmin: false,
          activeBorrowings: const [],
          depositAmount: 10.0,
          avatarUrl: firebaseUser.photoURL,
          memberSince: DateTime.now(),
        );
        
        // Enregistrer l'utilisateur dans Firestore
        await _firestore!.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
        
        return newUser;
      }
    } catch (e) {
      print('Erreur lors de la conversion de l\'utilisateur Firebase: $e');
      return null;
    }
  }
  
  /// Récupère l'utilisateur actuellement connecté
  Future<app_models.User?> get currentUser async {
    if (_useLocalMode) {
      return _isLoggedIn ? _mockUser : null;
    } else {
      final firebaseUser = _firebaseAuth?.currentUser;
      return await _firebaseUserToAppUser(firebaseUser);
    }
  }
  
  /// Récupère l'utilisateur actuellement connecté de manière asynchrone
  /// Utile pour initialiser l'état de l'application
  Future<app_models.User?> getCurrentUser() async {
    if (_useLocalMode) {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 300));
      return _isLoggedIn ? _mockUser : null;
    } else {
      final firebaseUser = _firebaseAuth?.currentUser;
      return await _firebaseUserToAppUser(firebaseUser);
    }
  }
  
  /// Stream qui émet l'utilisateur actuel à chaque changement d'état d'authentification
  Stream<app_models.User?> get authStateChanges {
    if (_useLocalMode) {
      // Retourner un stream qui émet l'utilisateur actuel
      return Stream.value(_isLoggedIn ? _mockUser : null);
    } else {
      // Convertir le stream d'état d'authentification Firebase en stream d'utilisateur de l'application
      return _firebaseAuth!.authStateChanges().asyncMap(_firebaseUserToAppUser);
    }
  }
  
  /// Inscrit un nouvel utilisateur avec email et mot de passe
  Future<app_models.User> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    if (_useLocalMode) {
      // Mode local
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si l'email est déjà utilisé
      if (_registeredUsers.any((user) => user.email == email)) {
        throw Exception('Cet email est déjà utilisé par un autre compte.');
      }
      
      // Créer un nouvel utilisateur
      final newUser = app_models.User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        isAdmin: false,
        activeBorrowings: const [], // Liste vide d'emprunts actifs
        depositAmount: 10.0,
        avatarUrl: null,
        memberSince: DateTime.now(),
      );
      
      // Ajouter le nouvel utilisateur à la liste des utilisateurs enregistrés
      _registeredUsers.add(newUser);
      
      // Mettre à jour l'utilisateur actuel et l'état de connexion
      _mockUser = newUser;
      _isLoggedIn = true;
      
      // Sauvegarder les données
      await _saveLocalData();
      
      return newUser;
    } else {
      // Mode Firebase
      try {
        // Créer l'utilisateur dans Firebase Auth
        final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user == null) {
          throw Exception('Erreur lors de la création du compte.');
        }
        
        // Mettre à jour le nom d'affichage
        await userCredential.user!.updateDisplayName(fullName);
        
        // Créer l'utilisateur dans Firestore
        final newUser = app_models.User(
          id: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isAdmin: false,
          activeBorrowings: const [],
          depositAmount: 10.0,
          avatarUrl: null,
          memberSince: DateTime.now(),
        );
        
        // Enregistrer l'utilisateur dans Firestore
        await _firestore!.collection('users').doc(userCredential.user!.uid).set(newUser.toJson());
        
        return newUser;
      } catch (e) {
        if (e is firebase_auth.FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              throw Exception('Cet email est déjà utilisé par un autre compte.');
            case 'invalid-email':
              throw Exception('L\'adresse email est invalide.');
            case 'weak-password':
              throw Exception('Le mot de passe est trop faible.');
            default:
              throw Exception('Erreur lors de la création du compte: ${e.message}');
          }
        } else {
          throw Exception('Erreur lors de la création du compte: $e');
        }
      }
    }
  }
  
  /// Connecte un utilisateur avec email et mot de passe
  Future<app_models.User> signIn({
    required String email,
    required String password,
  }) async {
    if (_useLocalMode) {
      // Mode local
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Rechercher l'utilisateur par email
      final userIndex = _registeredUsers.indexWhere((user) => user.email == email);
      
      if (userIndex == -1) {
        throw Exception('Aucun utilisateur trouvé avec cet email.');
      }
      
      // Dans une vraie application, on vérifierait le mot de passe hashé
      // Pour cette version locale, on accepte n'importe quel mot de passe
      // Cela permet de se connecter facilement en mode local pour les tests
      
      // Mettre à jour l'utilisateur actuel et l'état de connexion
      _mockUser = _registeredUsers[userIndex];
      _isLoggedIn = true;
      
      // Sauvegarder les données
      await _saveLocalData();
      
      return _mockUser!;
    } else {
      // Mode Firebase
      try {
        // Connecter l'utilisateur avec Firebase Auth
        final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user == null) {
          throw Exception('Erreur lors de la connexion.');
        }
        
        // Récupérer les données de l'utilisateur depuis Firestore
        final appUser = await _firebaseUserToAppUser(userCredential.user);
        
        if (appUser == null) {
          throw Exception('Erreur lors de la récupération des données utilisateur.');
        }
        
        return appUser;
      } catch (e) {
        if (e is firebase_auth.FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              throw Exception('Aucun utilisateur trouvé avec cet email.');
            case 'wrong-password':
              throw Exception('Mot de passe incorrect.');
            case 'invalid-email':
              throw Exception('L\'adresse email est invalide.');
            case 'user-disabled':
              throw Exception('Ce compte a été désactivé.');
            default:
              throw Exception('Erreur lors de la connexion: ${e.message}');
          }
        } else {
          throw Exception('Erreur lors de la connexion: $e');
        }
      }
    }
  }
  
  /// Déconnecte l'utilisateur actuel
  Future<void> signOut() async {
    if (_useLocalMode) {
      // Mode local
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mettre à jour l'état de connexion
      _isLoggedIn = false;
      
      // Sauvegarder les données
      await _saveLocalData();
    } else {
      // Mode Firebase
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _firebaseAuth?.signOut();
    }
  }
  
  /// Connecte un utilisateur avec Google
  Future<app_models.User> signInWithGoogle() async {
    if (_useLocalMode) {
      // Mode local - simuler une connexion Google
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si un utilisateur Google existe déjà
      final existingUserIndex = _registeredUsers.indexWhere((user) => user.email == 'utilisateur@gmail.com');
      
      app_models.User googleUser;
      
      if (existingUserIndex >= 0) {
        // Utiliser l'utilisateur existant
        googleUser = _registeredUsers[existingUserIndex];
      } else {
        // Créer un nouvel utilisateur Google simulé
        googleUser = app_models.User(
          id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
          email: 'utilisateur@gmail.com',
          fullName: 'Utilisateur Google',
          phoneNumber: null,
          isAdmin: false,
          activeBorrowings: const [],
          depositAmount: 10.0,
          avatarUrl: 'https://lh3.googleusercontent.com/a/default-user',
          memberSince: DateTime.now(),
        );
        
        // Ajouter l'utilisateur à la liste
        _registeredUsers.add(googleUser);
      }
      
      // Mettre à jour l'utilisateur actuel et l'état de connexion
      _mockUser = googleUser;
      _isLoggedIn = true;
      
      // Sauvegarder les données
      await _saveLocalData();
      
      return googleUser;
    } else {
      // Mode Firebase
      try {
        // Déclencher le flux de connexion Google
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        
        if (googleUser == null) {
          throw Exception('Connexion Google annulée par l\'utilisateur.');
        }
        
        // Obtenir les détails d'authentification du compte Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Créer un credential Firebase avec le token Google
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Connecter l'utilisateur avec Firebase Auth
        final userCredential = await _firebaseAuth!.signInWithCredential(credential);
        
        if (userCredential.user == null) {
          throw Exception('Erreur lors de la connexion avec Google.');
        }
        
        // Vérifier si l'utilisateur existe déjà dans Firestore
        final userDoc = await _firestore!.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // L'utilisateur n'existe pas encore dans Firestore, créer un nouveau document
          final newUser = app_models.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            fullName: userCredential.user!.displayName ?? 'Utilisateur Google',
            phoneNumber: userCredential.user!.phoneNumber,
            isAdmin: false,
            activeBorrowings: const [],
            depositAmount: 10.0,
            avatarUrl: userCredential.user!.photoURL,
            memberSince: DateTime.now(),
          );
          
          // Enregistrer l'utilisateur dans Firestore
          await _firestore!.collection('users').doc(userCredential.user!.uid).set(newUser.toJson());
        }
        
        // Récupérer les données de l'utilisateur depuis Firestore
        final appUser = await _firebaseUserToAppUser(userCredential.user);
        
        if (appUser == null) {
          throw Exception('Erreur lors de la récupération des données utilisateur.');
        }
        
        return appUser;
      } catch (e) {
        if (e is firebase_auth.FirebaseAuthException) {
          throw Exception('Erreur lors de la connexion avec Google: ${e.message}');
        } else {
          throw Exception('Erreur lors de la connexion avec Google: $e');
        }
      }
    }
  }
  
  /// Met à jour les informations de l'utilisateur
  Future<app_models.User> updateUserProfile(app_models.User updatedUser) async {
    if (_useLocalMode) {
      // Mode local
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      if (!_isLoggedIn || _mockUser == null) {
        throw Exception('Aucun utilisateur connecté.');
      }
      
      // Trouver l'index de l'utilisateur actuel dans la liste
      final userIndex = _registeredUsers.indexWhere((user) => user.id == _mockUser!.id);
      
      if (userIndex == -1) {
        throw Exception('Utilisateur non trouvé dans la base de données.');
      }
      
      // Mettre à jour l'utilisateur dans la liste
      _registeredUsers[userIndex] = updatedUser;
      
      // Mettre à jour l'utilisateur actuel
      _mockUser = updatedUser;
      
      // Sauvegarder les données
      await _saveLocalData();
      
      return updatedUser;
    } else {
      // Mode Firebase
      try {
        final firebaseUser = _firebaseAuth?.currentUser;
        
        if (firebaseUser == null) {
          throw Exception('Aucun utilisateur connecté.');
        }
        
        // Mettre à jour le nom d'affichage si nécessaire
        if (updatedUser.fullName != firebaseUser.displayName) {
          await firebaseUser.updateDisplayName(updatedUser.fullName);
        }
        
        // Mettre à jour les données dans Firestore
        await _firestore!.collection('users').doc(firebaseUser.uid).update(updatedUser.toJson());
        
        return updatedUser;
      } catch (e) {
        throw Exception('Erreur lors de la mise à jour du profil: $e');
      }
    }
  }
  
  /// Réinitialise le mot de passe d'un utilisateur
  Future<void> resetPassword(String email) async {
    if (_useLocalMode) {
      // Mode local
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si l'email existe
      if (!_registeredUsers.any((user) => user.email == email)) {
        throw Exception('Aucun utilisateur trouvé avec cet email.');
      }
      
      // Dans une vraie application, on enverrait un email de réinitialisation
      // Ici, on simule simplement le succès
    } else {
      // Mode Firebase
      try {
        await _firebaseAuth?.sendPasswordResetEmail(email: email);
      } catch (e) {
        if (e is firebase_auth.FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              throw Exception('Aucun utilisateur trouvé avec cet email.');
            case 'invalid-email':
              throw Exception('L\'adresse email est invalide.');
            default:
              throw Exception('Erreur lors de la réinitialisation du mot de passe: ${e.message}');
          }
        } else {
          throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
        }
      }
    }
  }
  
  /// Récupère tous les utilisateurs enregistrés (pour débogage)
  Future<List<app_models.User>> getAllUsers() async {
    if (_useLocalMode) {
      return List.unmodifiable(_registeredUsers);
    } else {
      try {
        final snapshot = await _firestore!.collection('users').get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return app_models.User.fromJson(data);
        }).toList();
      } catch (e) {
        print('Erreur lors de la récupération des utilisateurs: $e');
        return [];
      }
    }
  }
  
  /// Indique si le service fonctionne en mode local ou Firebase
  bool get isLocalMode => _useLocalMode;
}
