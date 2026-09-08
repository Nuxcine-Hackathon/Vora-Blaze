import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/vora_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _api = VoraApiService();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'client';
  bool _loading = false;
  String? _error;

  InputDecoration _darkField(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8888A0)),
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

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.register(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        telephone: _telephoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/otp',
        arguments: {
          'telephone': _telephoneCtrl.text.trim(),
          'otp_demo': result['otp_code_demo'],
        },
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoraColors.darkBg,
      appBar: AppBar(
        backgroundColor: VoraColors.darkBg,
        foregroundColor: Colors.white,
        title: const Text('Créer votre compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Quelques infos avant de commencer',
                style: TextStyle(fontSize: 13, color: VoraColors.muted),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected) ? Colors.white : VoraColors.darkMuted,
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected) ? VoraColors.secondary : const Color(0x14FFFFFF),
                  ),
                ),
                segments: const [
                  ButtonSegment(value: 'client', label: Text('Passager')),
                  ButtonSegment(value: 'chauffeur', label: Text('Chauffeur')),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _prenomCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Prénom', hint: 'Nom et prénom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nomCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Nom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telephoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Numéro de téléphone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _darkField('Mot de passe (6 caractères min.)'),
              ),
              const SizedBox(height: 24),
              if (_error != null) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: VoraColors.sos)),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Créer mon compte'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text.rich(
                  TextSpan(
                    text: 'Déjà un compte ? ',
                    style: TextStyle(color: VoraColors.darkMuted, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text: 'Se connecter',
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
