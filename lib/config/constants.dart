/// Configuration centrale du frontend VORA.
///
/// En dev sur émulateur Android : localhost de ta machine = 10.0.2.2
/// En dev sur simulateur iOS   : localhost de ta machine = 127.0.0.1 ou localhost
/// En dev sur appareil physique : mets l'IP locale de ton PC (ex: 192.168.1.42)
///   et assure-toi que ton téléphone est sur le même Wi-Fi que le backend.
/// En prod (une fois déployé sur Render) : remplace par l'URL publique
///   (ex: https://vora-backend.onrender.com)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000', // par défaut : émulateur Android
  );
}

/// Astuce : pour changer l'URL sans recompiler le code, lance avec :
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.42:4000
