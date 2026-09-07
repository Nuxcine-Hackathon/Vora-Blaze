import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/trip_draft.dart';

class TripEndScreen extends StatefulWidget {
  const TripEndScreen({super.key});

  @override
  State<TripEndScreen> createState() => _TripEndScreenState();
}

class _TripEndScreenState extends State<TripEndScreen> {
  final _api = VoraApiService();
  String _paymentMethod = 'especes';
  bool _paid = false;
  bool _loading = false;
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  String? _error;

  final _methods = const [
    {'value': 'especes', 'label': 'Espèces'},
    {'value': 'mobile_money', 'label': 'Mobile Money'},
    {'value': 'carte', 'label': 'Carte bancaire'},
  ];

  Future<void> _pay() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tripId = TripDraft().activeTripId!;
      await _api.createPayment(tripId: tripId, method: _paymentMethod);
      setState(() => _paid = true);
    } catch (e) {
      setState(() => _error = 'Paiement échoué : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitRating() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tripId = TripDraft().activeTripId!;
      // Le driver_id n'est pas encore exposé côté frontend à ce stade du MVP :
      // idéalement, /trips/:id renvoie déjà driver_id, à réutiliser ici.
      // Pour simplifier l'exemple on suppose que l'écran précédent l'a stocké.
      await _api.createRating(
        tripId: tripId,
        ratedUser: TripDraft().activeTripId!, // TODO Socrate : remplacer par le vrai driver_id du trip
        score: _rating,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      );
      TripDraft().clearActiveTrip();
      TripDraft().resetDraft();
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.settings.name == '/passenger/home');
    } catch (e) {
      setState(() => _error = 'Notation échouée : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = TripDraft();
    return Scaffold(
      appBar: AppBar(title: const Text('Fin de course'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Total : ${draft.lockedPrice?.toInt() ?? '--'} FCFA',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (!_paid) ...[
              const Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._methods.map((m) => RadioListTile<String>(
                    title: Text(m['label']!),
                    value: m['value']!,
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  )),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _pay,
                child: _loading ? const CircularProgressIndicator() : const Text('Payer'),
              ),
            ] else ...[
              const Text('Paiement confirmé ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Évaluez votre chauffeur', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                      icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                      onPressed: () => setState(() => _rating = i + 1),
                    )),
              ),
              TextField(
                controller: _commentCtrl,
                decoration: const InputDecoration(labelText: 'Commentaire (optionnel)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _submitRating,
                child: _loading ? const CircularProgressIndicator() : const Text('Terminer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
