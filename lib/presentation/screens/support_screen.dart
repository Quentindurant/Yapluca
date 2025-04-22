import 'package:flutter/material.dart';
import '../widgets/yapluca_logo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Contact Support YapluCa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18cb96),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Un problème ou une question ? Notre équipe est là pour vous aider :',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF18cb96)),
                title: const Text('support@yapluca.fr'),
                onTap: () async {
                  final mailUrl = Uri.parse('mailto:support@yapluca.fr?subject=Support%20YapluCa&body=Bonjour%20l%27%C3%A9quipe%20YapluCa%2C%0A');
                  if (await canLaunchUrl(mailUrl)) {
                    await launchUrl(mailUrl);
                    return;
                  }
                  try {
                    await launchUrl(mailUrl);
                    return;
                  } catch (_) {}
                  await Clipboard.setData(const ClipboardData(text: 'support@yapluca.fr'));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aucune app mail trouvée. Adresse copiée, collez-la dans votre client mail.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF18cb96)),
                title: const Text('06 46 49 86 66'),
                onTap: () async {
                  // Ouvre la messagerie SMS directement
                  final smsUrl = Uri.parse('sms:0646498666');
                  if (await canLaunchUrl(smsUrl)) {
                    await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
                    return;
                  }
                  final smstoUrl = Uri.parse('smsto:0646498666');
                  if (await canLaunchUrl(smstoUrl)) {
                    await launchUrl(smstoUrl, mode: LaunchMode.externalApplication);
                    return;
                  }
                  try {
                    await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
                    return;
                  } catch (_) {}
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir l\'app Messages.')), 
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF18cb96)),
                title: const Text('WhatsApp'),
                subtitle: const Text('06 46 49 86 66'),
                onTap: () async {
                  final whatsappUrl = Uri.parse('https://wa.me/33646498666');
                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18cb96),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Envoyer un message'),
                onPressed: () {
                  // TODO: Intégrer un formulaire de contact ou chat
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
