import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yapluca_migration/config/app_colors.dart';
import 'package:yapluca_migration/providers/auth_provider.dart' as app_provider;
import 'package:yapluca_migration/presentation/widgets/bottom_nav_bar.dart';
// import 'package:yapluca_migration/presentation/widgets/primary_button.dart'; // Paiement désactivé
import 'package:yapluca_migration/presentation/widgets/yapluca_logo.dart';
import 'terms_conditions_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../routes/app_router.dart'; // Correction du chemin d'import AppRouter
// import '../screens/add_balance_screen.dart'; // Paiement désactivé

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Index pour la page de profil
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<app_provider.AuthProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authProvider.checkAuthStatus();
      if (authProvider.isAuthenticated) {
        await authProvider.loadUserProfile();
      }
    });
  }

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRouter.qrScanner);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/loans');
          break;
      }
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<app_provider.AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_provider.AuthProvider>(context);
    final user = authProvider.user;
    final isLoading = authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF373643),
        title: const YaplucaLogo(height: 40),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic, color: Colors.white),
            tooltip: 'Support',
            onPressed: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: !authProvider.isAuthenticated
            ? Center(
                child: Text('Veuillez vous reconnecter pour accéder à votre profil.', style: TextStyle(fontSize: 16)),
              )
            : isLoading || user == null
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: user.profilePicture != null && (user.email).contains('@gmail.com')
                              ? NetworkImage(user.profilePicture!)
                              : null,
                          child: (user.profilePicture == null || !(user.email).contains('@gmail.com'))
                              ? const Icon(Icons.person, size: 48)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name.isNotEmpty ? user.name : 'Utilisateur',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryColor),
                          label: const Text("Conditions d'utilisation", style: TextStyle(color: AppColors.primaryColor)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: AppColors.primaryColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.primaryColor),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Informations personnelles',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24, thickness: 1),
                                _buildInfoRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: user.email ?? 'Non renseigné',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Téléphone',
                                  value: user.phoneNumber ?? 'Non renseigné',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'Adresse',
                                  value: user.address ?? 'Non renseignée',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Membre depuis',
                                  value: user.createdAt != null
                                      ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                      : 'Date inconnue',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _signOut,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text('Se déconnecter'),
                              ],
                            ),
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ]
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
    Widget? trailing,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
