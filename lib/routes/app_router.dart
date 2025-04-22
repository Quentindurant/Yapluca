import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/map_screen.dart';
import '../presentation/screens/station_details_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/admin_dashboard_screen.dart';
import '../presentation/screens/battery_borrowing_screen.dart';
import '../presentation/screens/borrowings_screen.dart';
import '../presentation/screens/minimal_qr_scanner.dart';

/// Classe gérant les routes de l'application YapluCa
class AppRouter {
  /// Routes nommées de l'application
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String map = '/map';
  static const String stationDetails = '/station-details';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin-dashboard';
  static const String batteryBorrowing = '/battery-borrowing';
  static const String borrowings = '/borrowings';
  static const String qrScanner = '/scanner';
  
  /// Génère les routes de l'application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case map:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      
      case stationDetails:
        final String stationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => StationDetailsScreen(stationId: stationId),
        );
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case batteryBorrowing:
        final String stationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BatteryBorrowingScreen(stationId: stationId),
        );
      
      case borrowings:
        return MaterialPageRoute(builder: (_) => const BorrowingsScreen());
      
      case qrScanner:
        return MaterialPageRoute(builder: (_) => const MinimalQRScannerScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non définie: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
