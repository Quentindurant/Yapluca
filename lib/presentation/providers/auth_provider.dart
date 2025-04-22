import 'package:flutter/foundation.dart';
import 'package:yapluca_migration/data/models/user.dart';
import 'package:yapluca_migration/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _error = '';
  bool _hasCheckedAuth = false;
  final AuthService _authService = AuthService();

  // Expose le service d'authentification pour le débogage
  AuthService get authService => _authService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String get error => _error;
  bool get hasCheckedAuth => _hasCheckedAuth;

  /// Initialise l'état d'authentification au démarrage de l'application
  Future<void> checkAuthStatus() async {
    if (_hasCheckedAuth) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      _isLoading = false;
      _hasCheckedAuth = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _hasCheckedAuth = true;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email: email, password: password);
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

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
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

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        fullName: name,
        email: email,
        password: password,
      );
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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Rafraîchit les données de l'utilisateur actuel
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;
    
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du rafraîchissement des données: $e');
      // Ne pas mettre à jour l'état d'erreur pour éviter de perturber l'interface
    }
  }

  /// Met à jour les informations de l'utilisateur
  void updateUserProfile({String? fullName, String? phoneNumber}) {
    if (_currentUser == null) return;
    
    try {
      // Créer une copie mise à jour de l'utilisateur actuel
      final updatedUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        fullName: fullName ?? _currentUser!.fullName,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        isAdmin: _currentUser!.isAdmin,
        activeBorrowings: _currentUser!.activeBorrowings,
        depositAmount: _currentUser!.depositAmount,
        avatarUrl: _currentUser!.avatarUrl,
        memberSince: _currentUser!.memberSince,
      );
      
      // Mettre à jour l'utilisateur dans le service d'authentification
      _authService.updateUserProfile(updatedUser).then((user) {
        _currentUser = user;
        notifyListeners();
      }).catchError((error) {
        _error = error.toString();
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
