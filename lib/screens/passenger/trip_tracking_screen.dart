import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/trip_draft.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/assistant_chat_bubble.dart';
import '../../theme/vora_theme.dart';

const _statusLabels = {
  'acceptee': 'Chauffeur trouvé',
  'chauffeur_en_route': 'Chauffeur en route',
  'chauffeur_arrive': 'Chauffeur arrivé',
  'en_cours': 'Course en cours',
  'terminee': 'Course terminée',
};

class TripTrackingScreen extends StatefulWidget {
  const TripTrackingScreen({super.key});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  final _api = VoraApiService();
  Timer? _pollTimer;
  Map<String, dynamic>? _trip;

  @override
  void initState() {
    super.initState();
    _refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final tripId = TripDraft().activeTripId;
    if (tripId == null) return;
    try {
      final trip = await _api.getTrip(tripId);
      if (!mounted) return;
      setState(() => _trip = trip);

      if (trip['status'] == 'terminee') {
        _pollTimer?.cancel();
        Navigator.pushReplacementNamed(context, '/passenger/trip-end');
      }
    } catch (_) {
      // on retente au prochain tick
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancel() async {
    final tripId = TripDraft().activeTripId;
    if (tripId == null) return;
    try {
      await _api.cancelTrip(tripId, reason: 'annulé par le client pendant la course');
      TripDraft().clearActiveTrip();
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.settings.name == '/passenger/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _trip?['status'] as String?;
    final label = _statusLabels[status] ?? 'Chargement...';

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de la course')),
      body: _trip == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VoraColors.ink)),
                          const SizedBox(height: 8),
                          Text('Destination : ${_trip!['destination_zone'] ?? ''}'),
                          Text('Prix verrouillé : ${_trip!['locked_price']} FCFA'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // L'annulation reste possible tant que la course n'est pas en cours
                  if (status == 'acceptee' || status == 'chauffeur_en_route')
                    TextButton(onPressed: _cancel, child: const Text('Annuler', style: TextStyle(color: VoraColors.sos))),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AssistantChatButton(tripId: TripDraft().activeTripId),
          const SizedBox(height: 12),
          SosButton(tripId: TripDraft().activeTripId),
        ],
      ),
    );
  }
}
