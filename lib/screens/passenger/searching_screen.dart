import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/trip_draft.dart';
import '../../theme/vora_theme.dart';

/// Écran d'attente animé pendant que le système cherche un chauffeur.
/// Poll léger de la course toutes les 3s pour détecter l'acceptation.
class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final _api = VoraApiService();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    final tripId = TripDraft().activeTripId;
    if (tripId == null) return;
    try {
      final trip = await _api.getTrip(tripId);
      if (trip['status'] == 'acceptee' || trip['status'] == 'chauffeur_en_route') {
        _pollTimer?.cancel();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/passenger/tracking');
      } else if (trip['status'] == 'aucun_chauffeur') {
        _pollTimer?.cancel();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun chauffeur disponible pour le moment.')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      // en cas d'erreur réseau ponctuelle, on retente au prochain tick
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancel() async {
    final tripId = TripDraft().activeTripId;
    if (tripId != null) {
      try {
        await _api.cancelTrip(tripId, reason: 'annulé par le client pendant la recherche');
      } catch (_) {}
    }
    TripDraft().clearActiveTrip();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.settings.name == '/passenger/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            const SizedBox(height: 24),
            const Text('Recherche en cours', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: VoraColors.ink)),
            const SizedBox(height: 8),
            const Text(
              'Nous recherchons un chauffeur\ndisponible près de vous',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: VoraColors.muted),
            ),
            const SizedBox(height: 8),
            Text('${TripDraft().lockedPrice?.toInt() ?? '--'} FCFA (prix verrouillé)', style: const TextStyle(color: VoraColors.muted)),
            const SizedBox(height: 32),
            OutlinedButton(onPressed: _cancel, child: const Text('Annuler')),
          ],
        ),
      ),
    );
  }
}
