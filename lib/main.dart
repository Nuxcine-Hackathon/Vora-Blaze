import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/passenger/home_screen.dart';
import 'screens/passenger/destination_screen.dart';
import 'screens/passenger/estimation_screen.dart';
import 'screens/passenger/searching_screen.dart';
import 'screens/passenger/trip_tracking_screen.dart';
import 'screens/passenger/trip_end_screen.dart';
import 'screens/passenger/history_screen.dart';
import 'screens/passenger/profile_screen.dart';
import 'screens/driver/driver_home_screen.dart';
import 'screens/driver/driver_trip_screen.dart';

void main() {
  runApp(const VoraApp());
}

class VoraApp extends StatelessWidget {
  const VoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E3A8A), // à remplacer par le design system d'Elisabeth
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (context) => const OtpScreen(),
        '/passenger/home': (context) => const PassengerHomeScreen(),
        '/passenger/destination': (context) => const DestinationScreen(),
        '/passenger/estimation': (context) => const EstimationScreen(),
        '/passenger/searching': (context) => const SearchingScreen(),
        '/passenger/tracking': (context) => const TripTrackingScreen(),
        '/passenger/trip-end': (context) => const TripEndScreen(),
        '/passenger/history': (context) => const HistoryScreen(),
        '/passenger/profile': (context) => const ProfileScreen(),
        '/driver/home': (context) => const DriverHomeScreen(),
        '/driver/trip': (context) => const DriverTripScreen(),
      },
    );
  }
}
