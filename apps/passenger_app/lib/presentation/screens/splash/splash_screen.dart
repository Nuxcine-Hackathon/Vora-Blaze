import 'package:ride_on/core/extensions/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ride_on/core/services/vora_guide_script.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';
import 'package:ride_on/core/utils/theme/theme_style.dart';
import '../../../core/utils/common_widget.dart';
import '../../widgets/brand_companion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double opacity = 0.0;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    getUserDataLocallyToHandleTheState(context);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    controller?.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: controller!,
                    reverseCurve: Curves.bounceInOut,
                    curve: Curves.easeInCubic,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BrandCompanion.fromScene(
                      scene: VoraGuideScene.splash,
                      size: 150,
                    ),
                    const SizedBox(height: 16),
                    commonlyUserLogo(),
                    Text(
                      "OnTravel",
                      style: heading1(context).copyWith(
                        color: BrandColors.navy,
                        fontSize: 25,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: SvgPicture.asset(
            "assets/images/vector_bottom.svg",
            colorFilter: const ColorFilter.mode(
              BrandColors.blue,
              BlendMode.srcIn,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SvgPicture.asset(
            "assets/images/vector_top.svg",
            colorFilter: const ColorFilter.mode(
              BrandColors.green,
              BlendMode.srcIn,
            ),
          ),
        )
      ],
    );
    // );
  }
}
