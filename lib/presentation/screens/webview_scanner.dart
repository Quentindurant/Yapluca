import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_colors.dart';
import '../../data/providers/charging_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class WebViewScannerScreen extends StatefulWidget {
  const WebViewScannerScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScannerScreen> createState() => _WebViewScannerScreenState();
}

class _WebViewScannerScreenState extends State<WebViewScannerScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasScanned = false;
  String _scannedCode = '';
  int _currentIndex = 2; // Index pour la page scanner

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // HTML pour le scanner QR basé sur jsQR
    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>YapluCa QR Scanner</title>
        <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js"></script>
        <style>
          body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-color: #f5f5f5;
          }
          #videoContainer {
            position: relative;
            width: 100%;
            max-width: 500px;
            overflow: hidden;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          }
          #video {
            width: 100%;
            height: auto;
            display: block;
          }
          #canvas {
            display: none;
          }
          #scanRegion {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border: 2px solid #18cb96;
            border-radius: 8px;
            box-sizing: border-box;
            pointer-events: none;
          }
          #scanLine {
            position: absolute;
            left: 0;
            right: 0;
            height: 2px;
            background-color: #18cb96;
            animation: scan 2s infinite ease-in-out;
          }
          @keyframes scan {
            0% { top: 10%; }
            50% { top: 90%; }
            100% { top: 10%; }
          }
          #status {
            margin-top: 20px;
            padding: 10px;
            text-align: center;
            color: #333;
            font-weight: bold;
          }
          .button {
            margin-top: 15px;
            padding: 12px 24px;
            background-color: #18cb96;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
          }
          .button:hover {
            background-color: #15b587;
          }
        </style>
      </head>
      <body>
        <div id="videoContainer">
          <video id="video" playsinline autoplay></video>
          <div id="scanRegion">
            <div id="scanLine"></div>
          </div>
        </div>
        <canvas id="canvas"></canvas>
        <div id="status">Initialisation de la caméra...</div>
        <button id="switchCamera" class="button">Changer de caméra</button>
        
        <script>
          let video = document.getElementById('video');
          let canvas = document.getElementById('canvas');
          let ctx = canvas.getContext('2d');
          let status = document.getElementById('status');
          let switchCameraButton = document.getElementById('switchCamera');
          let currentStream = null;
          let currentFacingMode = 'environment'; // 'environment' pour la caméra arrière, 'user' pour la caméra avant
          
          // Fonction pour démarrer la caméra
          async function startCamera() {
            try {
              if (currentStream) {
                currentStream.getTracks().forEach(track => track.stop());
              }
              
              const constraints = {
                video: {
                  facingMode: currentFacingMode,
                  width: { ideal: 1280 },
                  height: { ideal: 720 }
                }
              };
              
              currentStream = await navigator.mediaDevices.getUserMedia(constraints);
              video.srcObject = currentStream;
              
              // Attendre que la vidéo soit chargée
              video.onloadedmetadata = () => {
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;
                status.textContent = 'Caméra prête. Placez un QR code devant.';
                scanQRCode();
              };
            } catch (error) {
              status.textContent = 'Erreur d\\'accès à la caméra: ' + error.message;
              console.error('Erreur d\\'accès à la caméra:', error);
            }
          }
          
          // Fonction pour changer de caméra
          switchCameraButton.addEventListener('click', () => {
            currentFacingMode = currentFacingMode === 'environment' ? 'user' : 'environment';
            startCamera();
          });
          
          // Fonction pour scanner le QR code
          function scanQRCode() {
            if (!video.videoWidth) return;
            
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
            
            const code = jsQR(imageData.data, imageData.width, imageData.height, {
              inversionAttempts: "dontInvert",
            });
            
            if (code) {
              // QR code détecté
              status.textContent = 'QR Code détecté!';
              
              // Envoyer le code au Flutter
              window.flutter_inappwebview.callHandler('QRCodeDetected', code.data);
              
              // Arrêter la caméra
              if (currentStream) {
                currentStream.getTracks().forEach(track => track.stop());
              }
              
              return;
            }
            
            // Continuer à scanner
            requestAnimationFrame(scanQRCode);
          }
          
          // Démarrer la caméra au chargement
          startCamera();
        </script>
      </body>
      </html>
    ''';

    // Initialiser le contrôleur WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'QRCodeDetected',
        onMessageReceived: (JavaScriptMessage message) {
          _processCode(message.message);
        },
      )
      ..loadHtmlString(htmlContent);
  }

  void _processCode(String code) {
    if (!_hasScanned) {
      setState(() {
        _hasScanned = true;
        _scannedCode = code;
      });

      // Traiter le code QR
      final chargingProvider = Provider.of<ChargingProvider>(context, listen: false);
      chargingProvider.fetchDeviceInfo(code);
    }
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _scannedCode = '';
    });
    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    final chargingProvider = Provider.of<ChargingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // WebView pour le scanner QR
                if (!_hasScanned)
                  WebViewWidget(controller: _controller),

                // Affichage du chargement
                if (_isLoading && !_hasScanned)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),

                // Affichage du résultat du scan
                if (_hasScanned)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Code scanné: $_scannedCode',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (chargingProvider.isLoading)
                            const Column(
                              children: [
                                SizedBox(height: 20),
                                CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                                SizedBox(height: 20),
                                Text('Chargement des informations...'),
                              ],
                            )
                          else if (chargingProvider.errorMessage.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Erreur: ${chargingProvider.errorMessage}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _resetScanner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: const Text(
                                    'Scanner à nouveau',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  'Borne trouvée !',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (chargingProvider.selectedDevice != null)
                                  Text(
                                    'Station: ${chargingProvider.selectedDevice!.name}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _resetScanner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: const Text(
                                    'Scanner à nouveau',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
      ),
    );
  }
}
