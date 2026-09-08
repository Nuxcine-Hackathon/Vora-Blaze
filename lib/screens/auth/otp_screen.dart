import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/session.dart';
import '../../theme/vora_theme.dart';

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
      backgroundColor: VoraColors.darkBg,
      appBar: AppBar(
        backgroundColor: VoraColors.darkBg,
        foregroundColor: Colors.white,
        title: const Text('Vérification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Un code a été envoyé au $telephone',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              if (otpDemo != null) ...[
                const SizedBox(height: 8),
                Text('(Mode démo : code pré-rempli automatiquement — $otpDemo)',
                    style: const TextStyle(color: VoraColors.muted, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, letterSpacing: 8, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'Code OTP',
                  labelStyle: const TextStyle(color: VoraColors.darkMuted, fontWeight: FontWeight.w700),
                  filled: true,
                  fillColor: const Color(0x0FFFFFFF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x2EFFFFFF), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: VoraColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: VoraColors.sos)),
              ),
              ElevatedButton(
                onPressed: _loading ? null : verify,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Vérifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
