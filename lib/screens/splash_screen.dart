import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../state/session.dart';
import '../theme/vora_theme.dart';

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
    await Future.delayed(const Duration(milliseconds: 600));
    final token = await ApiClient().getToken();

    if (!mounted) return;

    if (token == null || !SessionState().isLoggedIn) {
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
      backgroundColor: VoraColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VoraWordmark(fontSize: 30),
            SizedBox(height: 22),
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: VoraColors.primary,
                backgroundColor: Color(0x26FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
