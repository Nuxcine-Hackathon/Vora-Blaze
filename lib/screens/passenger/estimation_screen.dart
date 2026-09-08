import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/trip_draft.dart';
import '../../theme/vora_theme.dart';

class EstimationScreen extends StatefulWidget {
  const EstimationScreen({super.key});

  @override
  State<EstimationScreen> createState() => _EstimationScreenState();
}

class _EstimationScreenState extends State<EstimationScreen> {
  final _api = VoraApiService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEstimation();
  }

  Future<void> _loadEstimation() async {
    setState(() { _loading = true; _error = null; });
    try {
      final draft = TripDraft();
      final result = await _api.estimateTrip(
        distanceKm: draft.distanceKm ?? 5,
        vehicleCategory: draft.vehicleCategory,
      );
      draft.estimatedPrice = (result['estimated_price'] as num).toDouble();
      draft.durationMin = result['duration_min'] as int;
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      final draft = TripDraft();
      final trip = await _api.createTrip(
        pickupZone: draft.pickupZone ?? '',
        pickupLat: draft.pickupLat ?? 0,
        pickupLng: draft.pickupLng ?? 0,
        pickupLandmark: draft.pickupLandmark,
        destinationZone: draft.destinationZone ?? '',
        destinationLat: draft.destinationLat ?? 0,
        destinationLng: draft.destinationLng ?? 0,
        distanceKm: draft.distanceKm ?? 5,
        vehicleCategory: draft.vehicleCategory,
      );
      draft.activeTripId = trip['id'];
      draft.lockedPrice = (trip['locked_price'] as num).toDouble();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/passenger/searching');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = TripDraft();
    return Scaffold(
      appBar: AppBar(title: const Text('Estimation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading && draft.estimatedPrice == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.circle, size: 10, color: VoraColors.ink),
                            const SizedBox(width: 8),
                            Expanded(child: Text(draft.pickupZone ?? '')),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.location_on, size: 14, color: VoraColors.sos),
                            const SizedBox(width: 8),
                            Expanded(child: Text(draft.destinationZone ?? '')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (draft.estimatedPrice != null) ...[
                    Text('${draft.estimatedPrice!.toInt()} FCFA',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('Durée estimée : ${draft.durationMin} min • ${draft.vehicleCategory}'),
                  ],
                  if (_error != null) Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_error!, style: const TextStyle(color: VoraColors.sos)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _loading ? null : _confirm,
                    child: _loading ? const CircularProgressIndicator() : const Text('Confirmer la course'),
                  ),
                ],
              ),
      ),
    );
  }
}
