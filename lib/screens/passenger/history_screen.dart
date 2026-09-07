import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = VoraApiService();
  List<dynamic> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final trips = await _api.listTrips();
      setState(() => _trips = trips);
    } catch (_) {
      // silencieux : liste vide affichée
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
              ? const Center(child: Text('Aucune course pour le moment.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _trips.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final t = _trips[i];
                      return ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('${t['pickup_zone'] ?? '?'} → ${t['destination_zone'] ?? '?'}'),
                        subtitle: Text('${t['status']} • ${t['locked_price'] ?? t['estimated_price'] ?? '--'} FCFA'),
                        trailing: Text((t['created_at'] as String? ?? '').split('T').first),
                      );
                    },
                  ),
                ),
    );
  }
}
