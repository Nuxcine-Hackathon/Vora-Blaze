/// État de session très simple (pas de gestion d'état complexe pour le MVP).
/// Un singleton suffit pour un hackathon — pas besoin de Provider/Riverpod
/// pour ce niveau de complexité.
class SessionState {
  static final SessionState _instance = SessionState._internal();
  factory SessionState() => _instance;
  SessionState._internal();

  String? userId;
  String? role; // 'client' | 'chauffeur' | 'admin'
  String? nom;
  String? prenom;

  bool get isLoggedIn => userId != null;
  bool get isDriver => role == 'chauffeur';

  void setUser({required String id, required String role, String? nom, String? prenom}) {
    userId = id;
    this.role = role;
    this.nom = nom;
    this.prenom = prenom;
  }

  void clear() {
    userId = null;
    role = null;
    nom = null;
    prenom = null;
  }
}
