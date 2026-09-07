import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

/// Client HTTP central. Ajoute automatiquement le token JWT sur chaque
/// requête (une fois connecté), et transforme les erreurs backend
/// ({ "error": "..." }) en messages exploitables.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'vora_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) {
        final message = e.response?.data is Map
            ? (e.response?.data['error'] ?? 'Erreur inconnue')
            : 'Impossible de contacter le serveur. Vérifiez votre connexion.';
        handler.reject(DioException(
          requestOptions: e.requestOptions,
          error: message,
          response: e.response,
          type: e.type,
        ));
      },
    ));
  }

  Future<void> saveToken(String token) => _storage.write(key: 'vora_token', value: token);
  Future<void> clearToken() => _storage.delete(key: 'vora_token');
  Future<String?> getToken() => _storage.read(key: 'vora_token');
}
