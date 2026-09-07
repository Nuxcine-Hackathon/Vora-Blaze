import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../state/trip_draft.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  LatLng _currentPosition = const LatLng(3.8480, 11.5021); // Yaoundé par défaut
  bool _locating = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          setState(() => _locating = false);
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locating = false;
      });
      _mapController.move(_currentPosition, 15);
    } catch (_) {
      // GPS imprécis ou refusé : le client pourra repositionner manuellement
      // le marqueur dans l'écran de destination (cf. cahier des charges §8.2).
      setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _currentPosition, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nuxcine.vora',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _currentPosition,
                  width: 40, height: 40,
                  child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
                ),
              ]),
            ],
          ),
          if (_locating) const Positioned(top: 60, left: 0, right: 0, child: Center(child: CircularProgressIndicator())),

          // Barre "Où allez-vous ?" (accueil, §6.1 du cahier des charges)
          Positioned(
            top: 50, left: 16, right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  TripDraft().pickupLat = _currentPosition.latitude;
                  TripDraft().pickupLng = _currentPosition.longitude;
                  Navigator.pushNamed(context, '/passenger/destination');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 12),
                      Text('Où allez-vous ?', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/passenger/history');
          if (i == 2) Navigator.pushNamed(context, '/passenger/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
