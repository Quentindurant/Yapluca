import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'google_sign_in_platform.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Configurer GoogleSignIn avec des options spécifiques pour éviter les redirections
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );

  // Clés pour le stockage sécurisé
  static const String _authCredentialsKey = 'auth_credentials';
  static const String _userDataKey = 'user_data';
  static const String _authMethodKey = 'auth_method';

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Vérifier si l'utilisateur est connecté
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Initialiser l'authentification au démarrage de l'application
  Future<void> initAuth() async {
    try {
      // Vérifier si nous avons des identifiants stockés
      final String? authMethod = await _secureStorage.read(key: _authMethodKey);
      
      if (authMethod == 'google' && currentUser == null) {
        print('Session Google précédente détectée');
        // Note: Nous avons simplifié cette méthode pour éviter les problèmes au démarrage
        // La reconnexion se fera automatiquement via Firebase
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'authentification: $e');
      // Ne pas propager l'erreur, l'utilisateur devra se connecter normalement
    }
  }

  // Inscription avec email et mot de passe
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer un document utilisateur dans Firestore
      await _createUserDocument(userCredential.user!, name);

      return userCredential;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      // Déconnexion de Google si l'utilisateur était connecté avec Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      // Déconnexion de Firebase
      await _auth.signOut();
      
      // Effacer les données stockées localement
      final storage = FlutterSecureStorage();
      await storage.delete(key: 'user_token');
      await storage.delete(key: 'user_refresh_token');
      
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw e;
    }
  }

  // Connexion avec Google - Méthode optimisée pour une expérience intégrée
  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Début de la connexion Google (méthode intégrée)');
      
      // Initialiser GoogleSignIn avec des options spécifiques pour une expérience intégrée
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        signInOption: SignInOption.standard,
        // Spécifier le client ID Android pour éviter les erreurs 404
        clientId: '1058815227110-vr8a0jt8qqvdj9h7kfm7vqrjg5q9ht3q.apps.googleusercontent.com',
      );
      
      // Déconnecter l'utilisateur précédent pour éviter les problèmes de cache
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      // Lancer le processus de connexion natif
      print('Ouverture du sélecteur de compte Google natif');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Aucun compte Google sélectionné');
        throw FirebaseAuthException(
          code: 'user-cancelled',
          message: 'Connexion Google annulée par l\'utilisateur',
        );
      }
      
      print('Compte Google sélectionné: ${googleUser.email}');
      
      // Obtenir les tokens d'authentification
      print('Obtention des tokens d\'authentification');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Vérifier que les tokens sont valides
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Tokens Google invalides');
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Impossible d\'obtenir des identifiants Google valides',
        );
      }
      
      // Créer les identifiants Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Connexion à Firebase
      print('Connexion à Firebase avec les identifiants Google');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Vérifier si c'est un nouvel utilisateur
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print('Nouvel utilisateur détecté, création du profil utilisateur');
        await _createUserProfileIfNotExists(userCredential.user);
      }
      
      print('Connexion Google réussie: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (e) {
      print('Erreur lors de la connexion Google: $e');
      
      // Si l'erreur est liée à un problème de réseau ou de configuration Google
      if (e.toString().contains('network') || 
          e.toString().contains('ERROR_NETWORK') || 
          e.toString().contains('404') || 
          e.toString().contains('failed')) {
        
        print('Tentative avec la méthode alternative');
        try {
          // Méthode alternative utilisant directement le provider
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          
          // Utiliser signInWithProvider qui est plus direct
          final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);
          
          if (userCredential.user != null) {
            await _createUserProfileIfNotExists(userCredential.user);
          }
          
          return userCredential;
        } catch (alternativeError) {
          print('Erreur avec la méthode alternative: $alternativeError');
          throw FirebaseAuthException(
            code: 'google-sign-in-failed',
            message: 'Problème avec les services Google. Veuillez réessayer plus tard.',
          );
        }
      }
      
      throw e;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Créer un document utilisateur dans Firestore
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'photoURL': user.photoURL,
    });
  }
  
  // Méthode pour la compatibilité avec le code existant
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Mettre à jour le profil utilisateur avec le nom
      await userCredential.user?.updateDisplayName(name);
      
      // Créer le document utilisateur dans Firestore
      if (userCredential.user != null) {
        await _createUserProfileIfNotExists(userCredential.user);
      }
      
      return userCredential;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      throw e;
    }
  }
  
  // Obtenir les données du profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
          
      if (doc.exists) {
        // Récupérer les données et s'assurer que tous les champs nécessaires sont présents
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        
        // Ajouter l'UID s'il est manquant
        if (!userData.containsKey('uid')) {
          userData['uid'] = currentUser!.uid;
        }
        
        // S'assurer que les champs essentiels existent
        userData['name'] = userData['name'] ?? currentUser!.displayName ?? 'Utilisateur';
        userData['email'] = userData['email'] ?? currentUser!.email ?? '';
        userData['profilePicture'] = userData['profilePicture'] ?? currentUser!.photoURL;
        userData['balance'] = userData['balance'] ?? 0.0;
        
        return userData;
      }
      
      // Si le document n'existe pas, créer un profil de base
      final defaultUserData = {
        'uid': currentUser!.uid,
        'name': currentUser!.displayName ?? 'Utilisateur',
        'email': currentUser!.email ?? '',
        'profilePicture': currentUser!.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0.0,
      };
      
      // Créer le document utilisateur s'il n'existe pas
      await _firestore.collection('users').doc(currentUser!.uid).set(defaultUserData);
      
      return defaultUserData;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }
  
  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }
  
  // Obtenir l'historique des locations
  Future<List<Map<String, dynamic>>> getRentalHistory() async {
    if (currentUser == null) return [];
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('rentals')
          .where('placeholder', isEqualTo: null)
          .orderBy('startTime', descending: true)
          .get();
          
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }
  
  // Créer le profil utilisateur si celui-ci n'existe pas
  Future<void> _createUserProfileIfNotExists(User? user) async {
    if (user == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (!doc.exists) {
        // Créer un profil de base
        final defaultUserData = {
          'uid': user.uid,
          'name': user.displayName ?? 'Utilisateur',
          'email': user.email ?? '',
          'profilePicture': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 0.0,
        };
        
        // Créer le document utilisateur
        await _firestore.collection('users').doc(user.uid).set(defaultUserData);
      }
    } catch (e) {
      print('Erreur lors de la création du profil: $e');
    }
  }
}
