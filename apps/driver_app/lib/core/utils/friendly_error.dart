import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ride_on_driver/core/utils/theme/project_color.dart';

const String kFriendlyError =
    "Oups, un petit souci. Réessaie dans un instant.";

/// Transforme une erreur technique en message court, calme et compréhensible.
String friendlyUserMessage(dynamic raw, {String? fallback}) {
  final fallbackText = fallback ?? kFriendlyError;
  final message = (raw ?? "").toString().trim();
  if (message.isEmpty) return fallbackText;

  if (kDebugMode) {
    debugPrint("Erreur brute (cachée à l'utilisateur) : $message");
  }

  final lower = message.toLowerCase();

  if (_looksLikeNetwork(lower)) {
    return "Pas de connexion pour le moment. Vérifie ton réseau, puis réessaie.";
  }
  if (lower.contains("timeout") || lower.contains("timed out")) {
    return "C'est un peu long. Réessaie dans quelques secondes.";
  }
  if (lower.contains("session expired") ||
      lower.contains("419") ||
      lower.contains("unauthorized") ||
      lower.contains("unauthenticated")) {
    return "Ta session a expiré. Reconnecte-toi pour continuer.";
  }
  if (lower.contains("location") ||
      lower.contains("permission") ||
      lower.contains("geolocator")) {
    return "On a besoin de ta position pour continuer.";
  }
  if (lower.contains("otp") || lower.contains("code") && lower.contains("invalid")) {
    return "Ce code n'est pas le bon. Vérifie et réessaie.";
  }

  if (_looksTechnical(message, lower)) {
    return fallbackText;
  }

  if (message.length > 120) return fallbackText;
  return message;
}

bool _looksLikeNetwork(String lower) {
  return lower.contains("socket") ||
      lower.contains("network") ||
      lower.contains("failed host lookup") ||
      lower.contains("connection refused") ||
      lower.contains("connection reset") ||
      lower.contains("no address") ||
      lower.contains("offline") ||
      lower.contains("internet");
}

bool _looksTechnical(String message, String lower) {
  return lower.contains("exception") ||
      lower.contains("error:") ||
      lower.contains("stack") ||
      lower.contains("instance of") ||
      lower.contains("firebase") ||
      lower.contains("firestore") ||
      lower.contains("dio") ||
      lower.contains("http") ||
      lower.contains("status code") ||
      lower.contains("token regeneration") ||
      lower.contains("something went wrong") ||
      lower.contains("null check") ||
      lower.contains("null is not") ||
      lower.contains("type '") ||
      lower.contains("formatexception") ||
      message.contains("{") ||
      message.contains(".dart") ||
      message.contains(" at ") ||
      RegExp(r"\n\s*#\d+").hasMatch(message) ||
      message.length > 140;
}

class FriendlyErrorScreen extends StatelessWidget {
  const FriendlyErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: BrandColors.lightBg,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            "Un petit souci d'affichage.\nReviens en arrière, tout va bien.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BrandColors.ink,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

void installFriendlyErrorHandlers() {
  ErrorWidget.builder = (details) {
    debugPrint("Widget error: ${details.exception}");
    return const FriendlyErrorScreen();
  };
  FlutterError.onError = (details) {
    debugPrint("Flutter error: ${details.exceptionAsString()}");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("Uncaught: $error");
    return true;
  };
}
