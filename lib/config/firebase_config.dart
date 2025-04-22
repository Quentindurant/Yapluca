import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  // Configuration Firebase pour l'application
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Configuration Web
      return const FirebaseOptions(
        apiKey: "AIzaSyBJYLzl1Q7uZEoyuhNpSQWSClt54wCK2SE",
        authDomain: "yapluca-65fcc.firebaseapp.com",
        projectId: "yapluca-65fcc",
        storageBucket: "yapluca-65fcc.firebasestorage.app",
        messagingSenderId: "1058815227110",
        appId: "1:1058815227110:web:c167366232ee837b0cf727",
        measurementId: "G-NV22RXGK69",
      );
    } else {
      // Configuration pour Android/iOS
      // Ces valeurs sont extraites automatiquement des fichiers google-services.json et GoogleService-Info.plist
      return const FirebaseOptions(
        apiKey: "AIzaSyBJYLzl1Q7uZEoyuhNpSQWSClt54wCK2SE",
        appId: "1:1058815227110:web:c167366232ee837b0cf727",
        messagingSenderId: "1058815227110",
        projectId: "yapluca-65fcc",
        storageBucket: "yapluca-65fcc.firebasestorage.app",
      );
    }
  }
}
