import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_on/core/services/vora_guide_script.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';

void main() {
  test('la palette officielle VORA est respectée', () {
    expect(BrandColors.primary, const Color(0xFFFF6D00));
    expect(BrandColors.secondary, const Color(0xFFE91E63));
    expect(BrandColors.darkBg, const Color(0xFF14141F));
    expect(BrandColors.success, const Color(0xFF00C853));
    expect(BrandColors.sos, const Color(0xFFD50000));
    expect(BrandColors.lightBg, const Color(0xFFFFF8F3));
    expect(BrandColors.navy, BrandColors.ink);
    expect(BrandColors.blue, BrandColors.primary);
    expect(BrandColors.green, BrandColors.success);
    expect(themeColor, BrandColors.blue);
    expect(blackColor, BrandColors.navy);
  });

  test('chaque écran du guide a une réplique', () {
    for (final scene in VoraGuideScene.values) {
      final line = VoraGuideScript.of(scene);
      expect(line.spoken, isNotEmpty);
      expect(line.bubble, isNotEmpty);
    }
  });

  test('les clips VORA sont branchés sur le parcours passager', () {
    expect(
      VoraGuideScript.of(VoraGuideScene.splash).videoAsset,
      'assets/videos/vora_guide.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.onboarding).videoAsset,
      'assets/videos/vora_guide.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.signup).videoAsset,
      'assets/videos/vora_signup.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.home).videoAsset,
      'assets/videos/vora_home.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.estimate).videoAsset,
      'assets/videos/vora_estimate.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.searching).videoAsset,
      'assets/videos/vora_searching.mp4',
    );
    expect(
      VoraGuideScript.of(VoraGuideScene.ride).videoAsset,
      'assets/videos/vora_ride.mp4',
    );
    expect(VoraGuideScript.of(VoraGuideScene.login).videoAsset, isNull);
    expect(VoraGuideScript.of(VoraGuideScene.destination).videoAsset, isNull);
  });
}
