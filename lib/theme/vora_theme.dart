import 'package:flutter/material.dart';

/// Palette officielle — source : maquette vora_palette.html
class VoraColors {
  static const Color primary = Color(0xFFFF6D00);
  static const Color primaryPressed = Color(0xFFC85400);
  static const Color secondary = Color(0xFFE91E63);
  static const Color darkBg = Color(0xFF14141F);
  static const Color success = Color(0xFF00C853);
  static const Color sos = Color(0xFFD50000);
  static const Color lightBg = Color(0xFFFFF8F3);
  static const Color muted = Color(0xFF8A8A99);
  static const Color ink = Color(0xFF14141F);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDE3D8);
  static const Color disabledBg = Color(0xFFE2E2E6);
  static const Color disabledText = Color(0xFFA8A8B3);
  static const Color selectedBg = Color(0xFFFDEFF4);
  static const Color navActiveBg = Color(0xFFFFE3CC);
  static const Color navIdleBg = Color(0xFFF1EEE9);
  static const Color darkMuted = Color(0xFFB9B9C6);

  static const LinearGradient wordmark = LinearGradient(
    colors: [
      Color(0xFFE91E63),
      Color(0xFFFF3D3D),
      Color(0xFFFF6D00),
      Color(0xFFFFC400),
    ],
    stops: [0.0, 0.35, 0.68, 1.0],
  );
}

class VoraTheme {
  static ThemeData light() {
    const colors = ColorScheme.light(
      primary: VoraColors.primary,
      onPrimary: Colors.white,
      secondary: VoraColors.secondary,
      onSecondary: Colors.white,
      surface: VoraColors.card,
      onSurface: VoraColors.ink,
      error: VoraColors.sos,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: VoraColors.lightBg,
      canvasColor: VoraColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: VoraColors.lightBg,
        foregroundColor: VoraColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: VoraColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VoraColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: VoraColors.disabledBg,
          disabledForegroundColor: VoraColors.disabledText,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VoraColors.ink,
          side: const BorderSide(color: VoraColors.border, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VoraColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VoraColors.card,
        hintStyle: const TextStyle(color: VoraColors.muted),
        labelStyle: const TextStyle(color: VoraColors.muted, fontWeight: FontWeight.w700, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoraColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoraColors.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VoraColors.border, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: VoraColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VoraColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: VoraColors.selectedBg,
        backgroundColor: VoraColors.card,
        side: const BorderSide(color: VoraColors.border, width: 1.5),
        labelStyle: const TextStyle(color: VoraColors.ink, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? VoraColors.secondary
              : VoraColors.border,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VoraColors.card,
        selectedItemColor: VoraColors.primary,
        unselectedItemColor: VoraColors.muted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VoraColors.primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VoraColors.primary,
      ),
      dividerTheme: const DividerThemeData(color: VoraColors.border),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: VoraColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}

class VoraWordmark extends StatelessWidget {
  const VoraWordmark({super.key, this.fontSize = 30, this.opacity = 1});

  final double fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        shaderCallback: (bounds) => VoraColors.wordmark.createShader(bounds),
        child: Text(
          'VORA',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class VoraBadge extends StatelessWidget {
  const VoraBadge({
    super.key,
    required this.label,
    this.color = VoraColors.success,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
