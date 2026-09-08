import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../state/session.dart';
import '../../state/trip_draft.dart';
import '../../theme/vora_theme.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _api = VoraApiService();
  bool _online = false;
  List<dynamic> _pendingTrips = [];
  Timer? _pollTimer;
  Timer? _positionTimer;
  bool _loading = false;

  Future<void> _toggleOnline(bool value) async {
    setState(() => _loading = true);
    try {
      await _api.setDriverStatus(value);
      setState(() => _online = value);
      if (value) {
        _startPolling();
        _startPositionUpdates();
      } else {
        _pollTimer?.cancel();
        _positionTimer?.cancel();
        setState(() => _pendingTrips = []);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshPending());
    _refreshPending();
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updatePosition());
    _updatePosition();
  }

  Future<void> _updatePosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      await _api.updateDriverPosition(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      // GPS indisponible : on retentera au prochain tick
    }
  }

  Future<void> _refreshPending() async {
    try {
      final trips = await _api.listPendingTrips();
      if (mounted) setState(() => _pendingTrips = trips);
    } catch (_) {}
  }

  Future<void> _accept(String tripId) async {
    try {
      await _api.acceptTrip(tripId);
      TripDraft().activeTripId = tripId;
      _pollTimer?.cancel();
      if (!mounted) return;
      Navigator.pushNamed(context, '/driver/trip');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _positionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour ${SessionState().prenom ?? ''}'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, '/passenger/profile')),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(_online ? 'En ligne' : 'Hors ligne'),
            subtitle: Text(_online ? 'Vous recevez des demandes de course' : 'Passez en ligne pour recevoir des courses'),
            activeThumbColor: VoraColors.success,
            value: _online,
            onChanged: _loading ? null : _toggleOnline,
          ),
          const Divider(),
          Expanded(
            child: !_online
                ? const Center(child: Text('Passez en ligne pour voir les courses disponibles.'))
                : _pendingTrips.isEmpty
                    ? const Center(child: Text('Aucune demande pour le moment...'))
                    : ListView.builder(
                        itemCount: _pendingTrips.length,
                        itemBuilder: (ctx, i) {
                          final t = _pendingTrips[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text('${t['pickup_zone']} → ${t['destination_zone']}'),
                              subtitle: Text('${t['distance_km']} km • ${t['locked_price']} FCFA'),
                              trailing: ElevatedButton(
                                onPressed: () => _accept(t['id']),
                                child: const Text('Accepter'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
