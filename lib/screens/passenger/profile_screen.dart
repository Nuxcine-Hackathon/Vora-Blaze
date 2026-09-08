import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/session.dart';
import '../../theme/vora_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await VoraApiService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionState();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(radius: 40, child: Text((session.prenom ?? '?')[0].toUpperCase())),
            const SizedBox(height: 16),
            Text('${session.prenom ?? ''} ${session.nom ?? ''}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(session.role ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: VoraColors.sos),
              onPressed: () => _logout(context),
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
