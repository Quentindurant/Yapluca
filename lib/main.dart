import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'config/app_colors.dart';
import 'config/app_theme.dart';
import 'config/app_config.dart';
import 'config/firebase_config.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/loans_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/minimal_qr_scanner.dart';
import 'presentation/screens/support_screen.dart';
import 'presentation/widgets/auth_wrapper.dart';
import 'providers/auth_provider.dart' as app_provider;
import 'providers/charging_station_provider.dart';
import 'data/providers/charging_provider.dart';
import 'services/auth_service.dart';

// Variable globale pour indiquer si Firebase est disponible
bool isFirebaseAvailable = false;

// Personnaliser l'apparence de l'écran de connexion Google
void customizeGoogleSignIn() {
  // Personnaliser l'apparence de l'écran de connexion Google
  FirebaseAuth.instance.setLanguageCode('fr'); // Définir la langue en français
  
  // Note: Nous avons supprimé le code qui causait un crash
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseConfig.platformOptions,
    );

    // ⚠️ Activation App Check Play Integrity : doit être juste après Firebase.initializeApp et AVANT tout autre code Firebase !
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // Token accepté par Firebase
      appleProvider: AppleProvider.debug, // Laisse debug si tu ne testes pas sur iOS
    );
    print('Firebase App Check activé avec Play Integrity');

    isFirebaseAvailable = true;
    print('Firebase initialisé avec succès');

    // Initialiser l'authentification pour restaurer la session si possible
    final authService = AuthService();
    await authService.initAuth();
    
  } catch (e) {
    isFirebaseAvailable = false;
    print('Erreur lors de l\'initialisation de Firebase: $e');
    
    // Afficher plus de détails sur l'erreur pour le débogage
    if (e is FirebaseException) {
      print('Code d\'erreur Firebase: ${e.code}');
      print('Message d\'erreur Firebase: ${e.message}');
    }
  }
  
  // Fixer l'orientation de l'application en mode portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Personnaliser la barre d'état
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Personnaliser l'apparence de Google Sign-In
  try {
    customizeGoogleSignIn();
  } catch (e) {
    print('Erreur lors de la personnalisation de Google Sign-In: $e');
  }
  

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_provider.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChargingStationProvider()),
        ChangeNotifierProvider(create: (_) => ChargingProvider()),
      ],
      child: Consumer<app_provider.AuthProvider>(
        builder: (context, authProvider, _) {
          // Vérifier l'état d'authentification au démarrage de l'application
          if (!authProvider.hasCheckedAuth) {
            authProvider.checkAuthStatus();
          }
          
          return MaterialApp(
            title: 'YapluCa',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF373643),
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              scaffoldBackgroundColor: Colors.grey[50],
            ),
            home: authProvider.hasCheckedAuth
                ? authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen()
                : const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/map': (context) => const MapScreen(),
              '/loans': (context) => const LoansScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/scanner': (context) => MinimalQRScannerScreen(),
              '/support': (context) => const SupportScreen(),
            },
            onGenerateRoute: (settings) {
              // Redirection vers la page de connexion si l'utilisateur n'est pas authentifié
              if (!authProvider.isAuthenticated && 
                  settings.name != '/login' && 
                  settings.name != '/register' && 
                  settings.name != '/reset_password') {
                return MaterialPageRoute(builder: (context) => const LoginScreen());
              }
              return null;
            },
            // Ajouter des transitions de page personnalisées
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              
              // Appliquer des animations fluides et des polices lisibles
              return ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(
                  physics: const BouncingScrollPhysics(),
                  overscroll: false,
                ),
                child: child,
              );
            },
          );
        }
      ),
    );
  }
}
