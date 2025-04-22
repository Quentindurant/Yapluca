import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../data/models/battery_borrowing.dart';
import '../../data/models/charging_station.dart';
import '../../data/models/borrowing_status.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/station_provider.dart';
import '../../routes/app_router.dart';

/// Écran de gestion des emprunts de batterie
class BatteryBorrowingScreen extends StatefulWidget {
  final String stationId;

  const BatteryBorrowingScreen({
    Key? key,
    required this.stationId,
  }) : super(key: key);

  @override
  State<BatteryBorrowingScreen> createState() => _BatteryBorrowingScreenState();
}

class _BatteryBorrowingScreenState extends State<BatteryBorrowingScreen> {
  bool _isLoading = true;
  ChargingStation? _station;
  final TextEditingController _codeController = TextEditingController();
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _loadStationDetails();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Charge les détails de la borne
  Future<void> _loadStationDetails() async {
    final stationProvider = Provider.of<StationProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      await stationProvider.getStationDetails(widget.stationId);
      setState(() {
        _station = stationProvider.selectedStation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des détails: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Emprunte une batterie
  Future<void> _borrowBattery() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code affiché sur la borne'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    // Simuler une vérification du code et un emprunt
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isConfirming = false;
    });

    if (_codeController.text == '1234') { // Code de démonstration
      // Créer un nouvel emprunt
      final borrowing = BatteryBorrowing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 'user1',
        stationId: widget.stationId,
        batteryId: 'BAT-${DateTime.now().millisecondsSinceEpoch % 1000}',
        borrowingTime: DateTime.now(),
        returnTime: null,
        depositAmount: 20.0,
        isActive: true,
      );

      // Afficher une confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batterie empruntée avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );

        // Afficher les instructions
        _showBorrowingSuccessDialog(borrowing);
      }
    } else {
      // Code incorrect
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code incorrect. Veuillez réessayer.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Affiche un dialogue de confirmation d'emprunt
  void _showBorrowingSuccessDialog(BatteryBorrowing borrowing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Batterie empruntée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vous pouvez maintenant récupérer votre batterie dans le compartiment ouvert.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Informations importantes :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              icon: Icons.access_time,
              text: 'Durée maximale : 24 heures',
            ),
            _buildInfoItem(
              icon: Icons.euro,
              text: 'Caution : 20€ (débitée après 24h)',
            ),
            _buildInfoItem(
              icon: Icons.battery_charging_full,
              text: 'Batterie n° ${borrowing.batteryId}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, borrowing);
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  /// Construit un élément d'information avec icône
  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emprunter une batterie',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _station == null
              ? const Center(child: Text('Borne introuvable'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Informations sur la borne
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _station!.hasBatteries
                                                ? AppColors.primaryColor
                                                : Colors.red.shade400,
                                            borderRadius: BorderRadius.circular(25),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _station!.hasBatteries
                                                ? Icons.battery_full
                                                : Icons.battery_alert,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _station!.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _station!.address,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStationStat(
                                          icon: Icons.battery_full,
                                          value: '${_station!.availableBatteries}',
                                          label: 'Batteries',
                                          color: AppColors.primaryColor,
                                        ),
                                        _buildStationStat(
                                          icon: Icons.euro,
                                          value: '${_station!.depositAmount?.toStringAsFixed(0) ?? '0'}€',
                                          label: 'Caution',
                                          color: Colors.orange,
                                        ),
                                        _buildStationStat(
                                          icon: Icons.access_time,
                                          value: '24h',
                                          label: 'Durée max',
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Instructions d'emprunt
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Comment emprunter une batterie',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInstructionStep(
                                    number: 1,
                                    text: 'Vérifiez que vous êtes bien devant la borne',
                                  ),
                                  _buildInstructionStep(
                                    number: 2,
                                    text: 'Entrez le code affiché sur l\'écran de la borne',
                                  ),
                                  _buildInstructionStep(
                                    number: 3,
                                    text: 'Récupérez votre batterie dans le compartiment ouvert',
                                  ),
                                  _buildInstructionStep(
                                    number: 4,
                                    text: 'Vous avez 24h pour rendre la batterie dans n\'importe quelle borne',
                                  ),
                                  const SizedBox(height: 24),

                                  // Formulaire d'emprunt
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Entrez le code affiché sur la borne',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _codeController,
                                          decoration: InputDecoration(
                                            hintText: 'Code à 4 chiffres',
                                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryColor),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          maxLength: 4,
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _station!.hasBatteries ? _borrowBattery : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              disabledBackgroundColor: Colors.grey.shade300,
                                            ),
                                            child: _isConfirming
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Emprunter une batterie',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildFooterItem(context, Icons.home, 'Accueil', false),
                              _buildFooterItem(context, Icons.map, 'Carte', false),
                              _buildFooterItem(context, Icons.qr_code_scanner, 'Scanner', false),
                              _buildFooterItem(context, Icons.history, 'Historique', false),
                              _buildFooterItem(context, Icons.person, 'Profil', false),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Construit un élément du footer
  Widget _buildFooterItem(BuildContext context, IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        // Navigation
        if (!isActive) {
          if (label == 'Accueil') {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (label == 'Carte') {
            Navigator.pushReplacementNamed(context, AppRouter.map);
          } else if (label == 'Scanner') {
            Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
          } else if (label == 'Historique') {
            Navigator.pushReplacementNamed(context, AppRouter.borrowings);
          } else if (label == 'Profil') {
            Navigator.pushReplacementNamed(context, AppRouter.profile);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une étape d'instruction
  Widget _buildInstructionStep({required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une statistique de la borne
  Widget _buildStationStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
