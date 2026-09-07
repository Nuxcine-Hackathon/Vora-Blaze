import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../state/session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 600)); // petit effet splash
    final token = await ApiClient().getToken();

    if (!mounted) return;

    if (token == null || !SessionState().isLoggedIn) {
      // Note MVP : le token peut exister sans que SessionState soit repeuplé
      // (ex: redémarrage de l'app). Pour le hackathon, on renvoie simplement
      // vers /login dans ce cas — en V2, ajouter un endpoint GET /auth/me.
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      SessionState().isDriver ? '/driver/home' : '/passenger/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('VORA', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
