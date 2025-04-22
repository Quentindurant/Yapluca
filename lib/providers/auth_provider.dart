import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _error = '';
  bool _isAuthenticated = false;
  bool _hasCheckedAuth = false;
  UserModel? _user;
  User? _firebaseUser;
  
  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _user?.email;
  String? get userName => _user?.name;
  bool get hasCheckedAuth => _hasCheckedAuth;
  UserModel? get user => _user;
  User? get firebaseUser => _firebaseUser;
  
  // Constructeur
  AuthProvider() {
    _initializeAuthState();
  }
  
  // Initialiser l'état d'authentification
  Future<void> _initializeAuthState() async {
    // Écouter les changements d'état d'authentification
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // L'utilisateur est connecté
        _isAuthenticated = true;
        _firebaseUser = user;
        // Charger les données utilisateur depuis Firestore
        await _loadUserData();
      } else {
        // L'utilisateur est déconnecté
        _isAuthenticated = false;
        _user = null;
        _firebaseUser = null;
      }
      _hasCheckedAuth = true;
      notifyListeners();
    });
    
    // Tenter de restaurer la session si possible
    try {
      await _authService.initAuth();
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'authentification: $e');
    }
  }
  
  // Charger les données utilisateur depuis Firestore
  Future<void> _loadUserData() async {
    try {
      if (!_isAuthenticated || _firebaseUser == null) return;
      
      _isLoading = true;
      notifyListeners();
      
      final userData = await _authService.getUserProfile();
      if (userData != null) {
        _user = UserModel.fromMap(userData);
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger le profil utilisateur (méthode publique)
  Future<void> loadUserProfile() async {
    if (_isLoading) return; // Éviter les appels multiples
    await _loadUserData();
  }
  
  // Vérifier l'état d'authentification
  Future<void> checkAuthStatus() async {
    if (_hasCheckedAuth) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _isAuthenticated = true;
        try {
          await _loadUserData();
        } catch (e) {
          print('Erreur lors du chargement des données utilisateur: $e');
          // Continuer même si le chargement des données a échoué
        }
      } else {
        _isAuthenticated = false;
        _user = null;
        _firebaseUser = null;
      }
    } catch (e) {
      print('Erreur lors de la vérification de l\'authentification: $e');
      _isAuthenticated = false;
      _error = e.toString();
    } finally {
      _isLoading = false;
      _hasCheckedAuth = true;
      notifyListeners();
    }
  }
  
  // Inscription avec email et mot de passe
  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      
      // Mettre à jour l'état d'authentification
      _isAuthenticated = true;
      
      // Attendre un court instant pour permettre à Firebase de mettre à jour l'état d'authentification
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Charger les données utilisateur
      await _loadUserData();
    } catch (e) {
      _error = 'Erreur lors de l\'inscription: ${e.toString()}';
      _isAuthenticated = false;
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Connexion avec email et mot de passe
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _isAuthenticated = true;
      await _loadUserData(); // Charger les données utilisateur
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _error = 'Aucun utilisateur trouvé avec cet email.';
          break;
        case 'wrong-password':
          _error = 'Mot de passe incorrect.';
          break;
        case 'invalid-email':
          _error = 'Format d\'email invalide.';
          break;
        case 'user-disabled':
          _error = 'Ce compte a été désactivé.';
          break;
        default:
          _error = 'Erreur de connexion: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Erreur: ${e.toString()}';
      print('Erreur de connexion: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Connexion avec Google
  Future<void> signInWithGoogle() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      print('Tentative de connexion avec Google...');
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential.user != null) {
        _isAuthenticated = true;
        _firebaseUser = userCredential.user;
        
        // Attendre un court instant pour permettre à Firebase de mettre à jour l'état d'authentification
        await Future.delayed(const Duration(milliseconds: 300));
        
        print('Connexion Google réussie');
        
        // Charger les données utilisateur
        await _loadUserData();
      } else {
        _error = 'Échec de la connexion Google: aucun utilisateur retourné';
        _isAuthenticated = false;
        print(_error);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-cancelled':
          errorMessage = 'Connexion annulée par l\'utilisateur';
          break;
        case 'network-request-failed':
          errorMessage = 'Problème de connexion internet. Vérifiez votre connexion.';
          break;
        default:
          errorMessage = 'Erreur lors de la connexion avec Google: ${e.message}';
      }
      
      _error = errorMessage;
      _isAuthenticated = false;
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'Erreur lors de la connexion avec Google: ${e.toString()}';
      _isAuthenticated = false;
      print('Erreur générique: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _user = null;
      _firebaseUser = null;
      
      // Forcer la mise à jour de l'interface
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la déconnexion: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'invalid-email':
          _error = 'Format d\'email invalide.';
          break;
        case 'user-not-found':
          _error = 'Aucun utilisateur trouvé avec cet email.';
          break;
        default:
          _error = 'Erreur de réinitialisation du mot de passe: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Mettre à jour le profil de l'utilisateur
  Future<bool> updateProfile({String? displayName, String? photoURL, String? phoneNumber, String? address}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final data = <String, dynamic>{};
      
      if (displayName != null && displayName.isNotEmpty) {
        data['name'] = displayName;
      }
      
      if (photoURL != null) {
        data['profilePicture'] = photoURL;
      }
      
      if (phoneNumber != null) {
        data['phoneNumber'] = phoneNumber;
      }
      
      if (address != null) {
        data['address'] = address;
      }
      
      if (data.isNotEmpty) {
        await _authService.updateUserProfile(data);
        await _loadUserData(); // Recharger les données après la mise à jour
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Obtenir l'historique des locations
  Future<List<RentalModel>> getRentalHistory() async {
    try {
      final rentalData = await _authService.getRentalHistory();
      return rentalData.asMap().entries.map((entry) {
        return RentalModel.fromMap(entry.value, entry.value['id'] ?? entry.key.toString());
      }).toList();
    } catch (e) {
      _error = 'Erreur lors de la récupération de l\'historique: ${e.toString()}';
      return [];
    }
  }
}
