import 'package:dio/dio.dart';
import 'api_client.dart';
import '../state/session.dart';

/// Service unique regroupant tous les appels au backend VORA.
/// Chaque méthode correspond à un module de la fiche de suivi (F1-F14).
class VoraApiService {
  final Dio _dio = ApiClient().dio;

  // ---------------------------------------------------------------
  // F2 — Auth (connexion / inscription / OTP)
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String password,
    String role = 'client',
    String? email,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'nom': nom, 'prenom': prenom, 'telephone': telephone,
      'password': password, 'role': role, 'email': email,
    });
    return res.data;
  }

  Future<String> verifyOtp({required String telephone, required String otpCode}) async {
    final res = await _dio.post('/auth/verify-otp', data: {
      'telephone': telephone, 'otp_code': otpCode,
    });
    final token = res.data['token'] as String;
    final user = res.data['user'];
    await ApiClient().saveToken(token);
    SessionState().setUser(
      id: user['id'], role: user['role'], nom: user['nom'], prenom: user['prenom'],
    );
    return token;
  }

  Future<String> login({required String telephone, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'telephone': telephone, 'password': password,
    });
    final token = res.data['token'] as String;
    final user = res.data['user'];
    await ApiClient().saveToken(token);
    SessionState().setUser(
      id: user['id'], role: user['role'], nom: user['nom'], prenom: user['prenom'],
    );
    return token;
  }

  Future<void> logout() async {
    await ApiClient().clearToken();
    SessionState().clear();
  }

  // ---------------------------------------------------------------
  // F5 — Estimation de prix (avant confirmation)
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> estimateTrip({
    required double distanceKm,
    String vehicleCategory = 'eco',
    String trafficLevel = 'normal',
  }) async {
    final res = await _dio.post('/trips/estimate', data: {
      'distance_km': distanceKm,
      'vehicle_category': vehicleCategory,
      'traffic_level': trafficLevel,
    });
    return res.data; // { estimated_price, locked_price: null, duration_min, vehicle_category }
  }

  // ---------------------------------------------------------------
  // F6 — Confirmation + recherche de chauffeur (crée la course, prix verrouillé)
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> createTrip({
    required String pickupZone,
    required double pickupLat,
    required double pickupLng,
    String? pickupLandmark,
    required String destinationZone,
    required double destinationLat,
    required double destinationLng,
    required double distanceKm,
    String vehicleCategory = 'eco',
    String trafficLevel = 'normal',
  }) async {
    final res = await _dio.post('/trips', data: {
      'pickup_zone': pickupZone, 'pickup_lat': pickupLat, 'pickup_lng': pickupLng,
      'pickup_landmark': pickupLandmark,
      'destination_zone': destinationZone, 'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'distance_km': distanceKm, 'vehicle_category': vehicleCategory,
      'traffic_level': trafficLevel,
    });
    return res.data['trip'];
  }

  // ---------------------------------------------------------------
  // F7 — Suivi de course (statuts en direct → à appeler en polling, ex: toutes les 5s)
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> getTrip(String tripId) async {
    final res = await _dio.get('/trips/$tripId');
    return res.data['trip'];
  }

  Future<Map<String, dynamic>> checkDeviation({
    required String tripId,
    required double currentLat,
    required double currentLng,
    required double expectedLat,
    required double expectedLng,
  }) async {
    final res = await _dio.post('/trips/$tripId/check-deviation', data: {
      'current_lat': currentLat, 'current_lng': currentLng,
      'expected_lat': expectedLat, 'expected_lng': expectedLng,
    });
    return res.data; // { deviation_detected, distance_km }
  }

  // ---------------------------------------------------------------
  // F13 — Historique des courses
  // ---------------------------------------------------------------

  Future<List<dynamic>> listTrips() async {
    final res = await _dio.get('/trips');
    return res.data['trips'];
  }

  // ---------------------------------------------------------------
  // F8 — Fin de course : annulation, paiement, notation
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> cancelTrip(String tripId, {String? reason}) async {
    final res = await _dio.patch('/trips/$tripId/cancel', data: {'reason': reason});
    return res.data['trip'];
  }

  Future<Map<String, dynamic>> createPayment({
    required String tripId,
    String method = 'especes',
  }) async {
    final res = await _dio.post('/payments', data: {'trip_id': tripId, 'method': method});
    return res.data['payment'];
  }

  Future<Map<String, dynamic>> createRating({
    required String tripId,
    required String ratedUser,
    required int score,
    String? comment,
  }) async {
    final res = await _dio.post('/ratings', data: {
      'trip_id': tripId, 'rated_user': ratedUser, 'score': score, 'comment': comment,
    });
    return res.data['rating'];
  }

  // ---------------------------------------------------------------
  // F9/F10 — Côté chauffeur : disponibilité, position, cycle de course
  // ---------------------------------------------------------------

  Future<void> setDriverStatus(bool isOnline) async {
    await _dio.put('/drivers/status', data: {'is_online': isOnline});
  }

  Future<void> updateDriverPosition({required double lat, required double lng}) async {
    await _dio.put('/drivers/position', data: {'lat': lat, 'lng': lng});
  }

  Future<List<dynamic>> listPendingTrips() async {
    final res = await _dio.get('/trips/pending');
    return res.data['trips'];
  }

  Future<Map<String, dynamic>> acceptTrip(String tripId) async {
    final res = await _dio.patch('/trips/$tripId/accept');
    return res.data['trip'];
  }

  Future<Map<String, dynamic>> startTrip(String tripId) async {
    final res = await _dio.patch('/trips/$tripId/start');
    return res.data['trip'];
  }

  Future<Map<String, dynamic>> endTrip(String tripId) async {
    final res = await _dio.patch('/trips/$tripId/end');
    return res.data['trip'];
  }

  // Utilisé côté passager (F4/F6) pour trouver les chauffeurs proches
  Future<List<dynamic>> nearbyDrivers({
    required double lat,
    required double lng,
    double radiusKm = 5,
    String? category,
  }) async {
    final res = await _dio.get('/drivers/nearby', queryParameters: {
      'lat': lat, 'lng': lng, 'radius_km': radiusKm,
      if (category != null) 'category': category,
    });
    return res.data['drivers'];
  }

  // ---------------------------------------------------------------
  // F11 — Bouton SOS
  // ---------------------------------------------------------------

  Future<void> triggerSos({String? tripId, double? lat, double? lng, String? details}) async {
    await _dio.post('/alerts/sos', data: {
      'trip_id': tripId, 'lat': lat, 'lng': lng, 'details': details,
    });
  }

  // ---------------------------------------------------------------
  // F12 — Assistant IA
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> askAssistant({required String message, String? tripId}) async {
    final res = await _dio.post('/assistant', data: {'message': message, 'trip_id': tripId});
    return res.data; // { intent, response }
  }
}
