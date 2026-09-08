import 'package:flutter/material.dart';
import 'package:ride_on/core/services/voice_announcer.dart';
import 'package:ride_on/core/services/vora_guide_script.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';

enum BrandCompanionMood { idle, welcome, trust }

/// Personnage de confiance local. Peut parler via TTS déjà présent dans l'app.
class BrandCompanion extends StatefulWidget {
  const BrandCompanion({
    super.key,
    this.size = 120,
    this.mood = BrandCompanionMood.idle,
    this.showGlow = true,
    this.message,
    this.speakText,
    this.speakOnAppear = false,
    this.onTap,
  });

  final double size;
  final BrandCompanionMood mood;
  final bool showGlow;
  final String? message;
  final String? speakText;
  final bool speakOnAppear;
  final VoidCallback? onTap;

  factory BrandCompanion.fromScene({
    Key? key,
    required VoraGuideScene scene,
    double size = 120,
    BrandCompanionMood mood = BrandCompanionMood.welcome,
    bool speakOnAppear = true,
    VoidCallback? onTap,
  }) {
    final line = VoraGuideScript.of(scene);
    return BrandCompanion(
      key: key,
      size: size,
      mood: mood,
      message: line.bubble,
      speakText: line.spoken,
      speakOnAppear: speakOnAppear,
      onTap: onTap,
    );
  }

  @override
  State<BrandCompanion> createState() => _BrandCompanionState();
}

class _BrandCompanionState extends State<BrandCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _breathe = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.speakOnAppear) {
      final text = widget.speakText ?? widget.message;
      if (text != null && text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          VoiceAnnouncer.instance.speakGuide(text);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    final text = widget.speakText ?? widget.message;
    if (text != null && text.isNotEmpty) {
      VoiceAnnouncer.instance.speakGuide(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.scale(scale: _breathe.value, child: child),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: DecoratedBox(
          decoration: widget.showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                      BoxShadow(
                        color: switch (widget.mood) {
                          BrandCompanionMood.welcome =>
                            BrandColors.blue.withValues(alpha: 0.22),
                          BrandCompanionMood.trust =>
                            BrandColors.green.withValues(alpha: 0.22),
                          BrandCompanionMood.idle =>
                            BrandColors.navy.withValues(alpha: 0.16),
                        },
                        blurRadius: widget.size * 0.22,
                        spreadRadius: 1,
                      ),
                  ],
                )
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
          child: Padding(
            padding: EdgeInsets.all(widget.size * 0.06),
            child: Image.asset(
              'assets/images/brand_companion.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) =>
                  _CompanionFallback(size: widget.size),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: widget.onTap != null,
      label: widget.message ?? "Guide Vora",
      child: GestureDetector(
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null && widget.message!.isNotEmpty)
              _SpeechBubble(text: widget.message!, maxWidth: widget.size + 96),
            avatar,
          ],
        ),
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
        shaderCallback: (bounds) => BrandColors.wordmark.createShader(bounds),
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

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.maxWidth});

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BrandColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CompanionFallback extends StatelessWidget {
  const _CompanionFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CompanionPainter(),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = BrandColors.blue;
    final navy = Paint()..color = BrandColors.navy;
    final green = Paint()..color = BrandColors.green;
    final skin = Paint()..color = const Color(0xFFC68642);
    final eye = Paint()..color = BrandColors.navy;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.72),
        width: w * 0.46,
        height: h * 0.38,
      ),
      body,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.22, skin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.18, w * 0.44, h * 0.14),
        Radius.circular(w * 0.08),
      ),
      navy,
    );
    canvas.drawCircle(Offset(w * 0.43, h * 0.38), w * 0.025, eye);
    canvas.drawCircle(Offset(w * 0.57, h * 0.38), w * 0.025, eye);
    canvas.drawCircle(Offset(w * 0.72, h * 0.62), w * 0.07, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
