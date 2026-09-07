import 'package:flutter_tts/flutter_tts.dart';

/// Speaks ride-status updates out loud in French — hands-free convenience
/// during a ride, and an accessibility aid for visually impaired riders.
class VoiceAnnouncer {
  VoiceAnnouncer._internal();
  static final VoiceAnnouncer instance = VoiceAnnouncer._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String message) async {
    await _ensureInitialized();
    await _tts.stop();
    await _tts.speak(message);
  }

  /// Voix un peu plus lente pour le guide Vora (accueil, aide, accessibilité).
  Future<void> speakGuide(String message) async {
    await _ensureInitialized();
    await _tts.setSpeechRate(0.44);
    await _tts.stop();
    await _tts.speak(message);
  }

  static const Map<String, String> rideStatusAnnouncements = {
    "accepted": "Un chauffeur a accepté votre course. Il arrive.",
    "ongoing": "Votre course a commencé. Bon trajet !",
    "completed": "Vous êtes arrivé à destination.",
    "rejected": "Le chauffeur a annulé la course.",
  };

  Future<void> announceRideStatus(String status) async {
    final message = rideStatusAnnouncements[status];
    if (message != null) {
      await speak(message);
    }
  }
}
