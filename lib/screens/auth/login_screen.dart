import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/session.dart';
import '../../theme/vora_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = VoraApiService();
  final _telephoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  InputDecoration _darkField(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: VoraColors.darkMuted, fontWeight: FontWeight.w700, fontSize: 12),
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
    );
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.login(telephone: _telephoneCtrl.text.trim(), password: _passwordCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        SessionState().isDriver ? '/driver/home' : '/passenger/home',
      );
    } catch (e) {
      setState(() => _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoraColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VoraWordmark(fontSize: 20, opacity: 0.35),
              const SizedBox(height: 18),
              const Text(
                'Bienvenue sur VORA',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Connectez-vous pour continuer',
                style: TextStyle(fontSize: 13, color: VoraColors.muted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _telephoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Numéro de téléphone'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Mot de passe'),
              ),
              const SizedBox(height: 24),
              if (_error != null) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: VoraColors.sos)),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text.rich(
                  TextSpan(
                    text: "Pas encore de compte ? ",
                    style: TextStyle(color: VoraColors.darkMuted, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text: "S'inscrire",
                        style: TextStyle(color: VoraColors.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
