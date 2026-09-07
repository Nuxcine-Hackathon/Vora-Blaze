import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/session.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _api = VoraApiService();
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _prefilled = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final telephone = args['telephone'] as String;
    final otpDemo = args['otp_demo'] as String?;

    // Pré-remplissage automatique en mode démo (OTP simulé par le backend,
    // cf. README §8 : aucun vrai SMS n'est envoyé pour le hackathon).
    if (!_prefilled && otpDemo != null) {
      _otpCtrl.text = otpDemo;
      _prefilled = true;
    }

    Future<void> verify() async {
      setState(() { _loading = true; _error = null; });
      try {
        await _api.verifyOtp(telephone: telephone, otpCode: _otpCtrl.text.trim());
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          SessionState().isDriver ? '/driver/home' : '/passenger/home',
        );
      } catch (e) {
        setState(() => _error = e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Un code a été envoyé au $telephone'),
              if (otpDemo != null) ...[
                const SizedBox(height: 8),
                Text('(Mode démo : code pré-rempli automatiquement — $otpDemo)',
                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Code OTP', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              if (_error != null) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: _loading ? null : verify,
                child: _loading ? const CircularProgressIndicator() : const Text('Vérifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
