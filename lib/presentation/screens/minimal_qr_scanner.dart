import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../routes/app_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/yapluca_logo.dart'; // Import YaplucaLogo

/// Un scanner QR code minimaliste sans aucune fonctionnalité complexe
/// Conçu pour être le plus simple possible et éviter tout problème d'initialisation
class MinimalQRScannerScreen extends StatefulWidget {
  const MinimalQRScannerScreen({Key? key}) : super(key: key);

  @override
  State<MinimalQRScannerScreen> createState() => _MinimalQRScannerScreenState();
}

class _MinimalQRScannerScreenState extends State<MinimalQRScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF373643),
        title: const YaplucaLogo(height: 40),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic, color: Colors.white),
            tooltip: 'Support',
            onPressed: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner QR code avec configuration minimale
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
              returnImage: false,
            ),
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  setState(() => _isProcessing = true);
                  // Format attendu: 'station:ID'
                  if (code.startsWith('station:')) {
                    final stationId = code.substring(8);
                    Navigator.pushReplacementNamed(
                      context, 
                      AppRouter.stationDetails,
                      arguments: stationId,
                    ).then((_) {
                      if (mounted) setState(() => _isProcessing = false);
                    });
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR code invalide. Veuillez scanner un QR code de borne YapluCa.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() => _isProcessing = false);
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRouter.map);
          } else if (index == 2) {
            // Déjà sur le scanner, ne rien faire
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRouter.borrowings);
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, AppRouter.profile);
          }
        },
      ),
    );
  }
}
