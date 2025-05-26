import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StripePaymentButton extends StatefulWidget {
  final int amount; // en centimes (ex: 299 = 2,99€)
  final String productName;
  final String successUrl;
  final String cancelUrl;

  const StripePaymentButton({
    Key? key,
    required this.amount,
    required this.productName,
    required this.successUrl,
    required this.cancelUrl,
  }) : super(key: key);

  @override
  State<StripePaymentButton> createState() => _StripePaymentButtonState();
}

class _StripePaymentButtonState extends State<StripePaymentButton> {
  bool _loading = false;

  Future<void> _startStripeCheckout() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vous connecter pour ajouter du crédit !")),
      );
      return;
    }
    // DEBUG : log utilisateur et token Firebase
    print("[DEBUG] Firebase user: "+FirebaseAuth.instance.currentUser.toString());
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    print("[DEBUG] Firebase token: $token");
    if (FirebaseAuth.instance.currentUser == null || token == null) {
      print('[DEBUG] Utilisateur non connecté ou token manquant');
    } else {
      print('[DEBUG] Utilisateur connecté, token présent');
    }
    setState(() { _loading = true; });
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('createStripeCheckoutSession');
      print('[DEBUG] Appel FirebaseFunctions...');
      try {
        final response = await callable.call({
          'amount': widget.amount,
          'currency': 'eur',
        });
        print('[DEBUG] Réponse FirebaseFunctions: ' + response.data.toString());
        final url = response.data['url'];
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir la page de paiement Stripe.')),
          );
        }
      } catch (e) {
        print('[DEBUG] Erreur lors de l\'appel FirebaseFunctions: ' + e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création du paiement : $e')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du paiement : $e')),
      );
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _startStripeCheckout,
      icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.payment),
      label: Text(_loading ? 'Paiement...' : 'Payer avec Stripe'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
