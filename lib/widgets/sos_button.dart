import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/vora_theme.dart';

/// Bouton d'urgence réutilisable sur les écrans de course (passager et chauffeur).
class SosButton extends StatelessWidget {
  final String? tripId;
  final double? lat;
  final double? lng;

  const SosButton({super.key, this.tripId, this.lat, this.lng});

  Future<void> _confirmAndTrigger(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alerte SOS'),
        content: const Text('Déclencher une alerte d\'urgence ? L\'assistance sera prévenue.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VoraColors.sos),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await VoraApiService().triggerSos(tripId: tripId, lat: lat, lng: lng, details: 'Déclenché depuis l\'app');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerte envoyée. Restez en sécurité.'), backgroundColor: VoraColors.sos),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'sos_button',
      backgroundColor: VoraColors.sos,
      onPressed: () => _confirmAndTrigger(context),
      child: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}
