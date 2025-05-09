import 'package:flutter/material.dart';
import '../widgets/stripe_payment_button.dart';

class AddBalanceScreen extends StatefulWidget {
  final double currentBalance;
  const AddBalanceScreen({Key? key, required this.currentBalance}) : super(key: key);

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final TextEditingController _amountController = TextEditingController();
  double? _amountToAdd;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter du crédit'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solde actuel : ${widget.currentBalance.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant à ajouter (€)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _amountToAdd = double.tryParse(value.replaceAll(',', '.'));
                });
              },
            ),
            const SizedBox(height: 24),
            if (_amountToAdd != null && _amountToAdd! > 0)
              StripePaymentButton(
                amount: (_amountToAdd! * 100).round(),
                productName: 'Crédit YapluCa',
                successUrl: 'https://yapluca-success.com',
                cancelUrl: 'https://yapluca-cancel.com',
              ),
            if (_amountToAdd == null || _amountToAdd! <= 0)
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Entrer un montant valide'),
              ),
          ],
        ),
      ),
    );
  }
}
