import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/trip_draft.dart';
import '../../widgets/sos_button.dart';
import '../../theme/vora_theme.dart';

const _driverStatusLabels = {
  'acceptee': 'Rejoignez le passager',
  'en_cours': 'Course en cours',
  'terminee': 'Course terminée',
};

class DriverTripScreen extends StatefulWidget {
  const DriverTripScreen({super.key});

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  final _api = VoraApiService();
  Map<String, dynamic>? _trip;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tripId = TripDraft().activeTripId;
    if (tripId == null) return;
    final trip = await _api.getTrip(tripId);
    if (mounted) setState(() => _trip = trip);
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final trip = await _api.startTrip(TripDraft().activeTripId!);
      setState(() => _trip = trip);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _end() async {
    setState(() => _loading = true);
    try {
      await _api.endTrip(TripDraft().activeTripId!);
      TripDraft().clearActiveTrip();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _trip?['status'] as String?;
    final label = _driverStatusLabels[status] ?? 'Chargement...';

    return Scaffold(
      appBar: AppBar(title: const Text('Course en cours')),
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
                          Text('Départ : ${_trip!['pickup_zone']}'),
                          Text('Destination : ${_trip!['destination_zone']}'),
                          Text('Prix : ${_trip!['locked_price']} FCFA'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (status == 'acceptee')
                    ElevatedButton(
                      onPressed: _loading ? null : _start,
                      child: _loading ? const CircularProgressIndicator() : const Text('Démarrer la course'),
                    ),
                  if (status == 'en_cours')
                    ElevatedButton(
                      onPressed: _loading ? null : _end,
                      child: _loading ? const CircularProgressIndicator() : const Text('Terminer la course'),
                    ),
                ],
              ),
            ),
      floatingActionButton: SosButton(tripId: TripDraft().activeTripId),
    );
  }
}
