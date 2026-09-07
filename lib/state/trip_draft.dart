/// Contient les infos de la course en cours de construction (avant confirmation)
/// puis de la course active (après confirmation). Singleton simple pour le MVP.
class TripDraft {
  static final TripDraft _instance = TripDraft._internal();
  factory TripDraft() => _instance;
  TripDraft._internal();

  // --- Choix départ/destination (F4) ---
  String? pickupZone;
  double? pickupLat;
  double? pickupLng;
  String? pickupLandmark;

  String? destinationZone;
  double? destinationLat;
  double? destinationLng;

  String vehicleCategory = 'eco';
  double? distanceKm;

  // --- Estimation (F5) ---
  double? estimatedPrice;
  int? durationMin;

  // --- Course active (F6-F8) ---
  String? activeTripId;
  double? lockedPrice;

  void resetDraft() {
    pickupZone = null; pickupLat = null; pickupLng = null; pickupLandmark = null;
    destinationZone = null; destinationLat = null; destinationLng = null;
    vehicleCategory = 'eco';
    distanceKm = null;
    estimatedPrice = null; durationMin = null;
  }

  void clearActiveTrip() {
    activeTripId = null;
    lockedPrice = null;
  }
}
