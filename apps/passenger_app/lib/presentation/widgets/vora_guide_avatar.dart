import 'package:flutter/material.dart';
import 'package:ride_on/core/services/vora_guide_script.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';
import 'package:ride_on/presentation/widgets/brand_companion.dart';
import 'package:ride_on/presentation/widgets/vora_guide_clip.dart';

/// Avatar VORA : clip vidéo si la scène en a un, sinon le personnage statique.
class VoraGuideAvatar extends StatelessWidget {
  const VoraGuideAvatar({
    super.key,
    required this.scene,
    this.size = 120,
    this.mood = BrandCompanionMood.welcome,
    this.speakOnAppear = true,
    this.onTap,
    this.onCompleted,
    this.showMessage = true,
  });

  final VoraGuideScene scene;
  final double size;
  final BrandCompanionMood mood;
  final bool speakOnAppear;
  final VoidCallback? onTap;
  final VoidCallback? onCompleted;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    final line = VoraGuideScript.of(scene);
    final video = line.videoAsset;

    if (video != null) {
      final clip = VoraGuideClip(
        asset: video,
        size: size,
        playOnAppear: speakOnAppear,
        onTap: onTap,
        onCompleted: onCompleted,
        semanticsLabel: line.spoken,
        mood: mood,
      );
      if (!showMessage || line.bubble.isEmpty) return clip;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoraBubble(text: line.bubble, maxWidth: size + 96),
          clip,
        ],
      );
    }

    return BrandCompanion.fromScene(
      scene: scene,
      size: size,
      mood: mood,
      speakOnAppear: speakOnAppear,
      onTap: onTap,
    );
  }
}

class _VoraBubble extends StatelessWidget {
  const _VoraBubble({required this.text, required this.maxWidth});

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
