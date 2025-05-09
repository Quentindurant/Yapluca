import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    setState(() { _loading = true; });
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createStripeCheckoutSession');
      final response = await callable.call({
        'amount': widget.amount,
        'productName': widget.productName,
        // Utilise une URL temporaire valide Stripe (à remplacer par une page de redirection custom plus tard)
        'successUrl': 'https://yapluca-success.com',
        'cancelUrl': 'https://yapluca-cancel.com',
      });
      final url = response.data['url'];
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir la page de paiement Stripe.')),
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
