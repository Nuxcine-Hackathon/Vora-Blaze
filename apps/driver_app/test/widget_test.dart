import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_on_driver/core/utils/theme/project_color.dart';

void main() {
  test('la palette officielle VORA est respectée côté chauffeur', () {
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
}
