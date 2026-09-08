import 'package:flutter/material.dart';
import '../../state/trip_draft.dart';
import '../../theme/vora_theme.dart';

/// MVP simplifié : saisie texte pour la zone de départ/destination + un champ
/// "repère" libre (portail, boutique, carrefour...) comme demandé au §8.3 du
/// cahier des charges. La sélection précise sur carte (glisser le marqueur)
/// sera ajoutée par Elisabeth/Dassi une fois le design finalisé — la logique
/// de correction manuelle du point GPS est déjà prévue côté backend.
class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final _pickupZoneCtrl = TextEditingController(text: '');
  final _pickupLandmarkCtrl = TextEditingController();
  final _destinationZoneCtrl = TextEditingController();
  String _category = 'eco';

  final _categories = const [
    {'value': 'eco', 'label': 'Éco'},
    {'value': 'confort', 'label': 'Confort'},
    {'value': 'xl', 'label': 'XL / Groupe'},
    {'value': 'pmr', 'label': 'PMR'},
  ];

  void _continue() {
    if (_pickupZoneCtrl.text.trim().isEmpty || _destinationZoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez le départ et la destination.')),
      );
      return;
    }

    final draft = TripDraft();
    draft.pickupZone = _pickupZoneCtrl.text.trim();
    draft.pickupLandmark = _pickupLandmarkCtrl.text.trim().isEmpty ? null : _pickupLandmarkCtrl.text.trim();
    draft.destinationZone = _destinationZoneCtrl.text.trim();
    draft.vehicleCategory = _category;

    // MVP : distance simulée tant que le calcul d'itinéraire réel (OSRM/Mapbox)
    // n'est pas branché. À remplacer par un vrai calcul dès que possible.
    draft.distanceKm = 8.5;
    // Coordonnées destination simulées (Yaoundé) — à remplacer par un vrai
    // géocodage/sélection sur carte.
    draft.destinationLat = 3.8480;
    draft.destinationLng = 11.5021;

    Navigator.pushNamed(context, '/passenger/estimation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votre trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pickupZoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Point de départ (quartier, lieu...)',
                prefixIcon: Icon(Icons.circle, size: 12, color: VoraColors.ink),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pickupLandmarkCtrl,
              decoration: const InputDecoration(
                labelText: 'Repère (portail, boutique, carrefour...) — optionnel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationZoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on, color: VoraColors.sos),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Catégorie de véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                final selected = _category == c['value'];
                return ChoiceChip(
                  label: Text(c['label']!),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c['value']!),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(onPressed: _continue, child: const Text('Voir le prix estimé')),
          ],
        ),
      ),
    );
  }
}
