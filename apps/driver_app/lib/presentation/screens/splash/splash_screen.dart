import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/utils/theme/project_color.dart';
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
    return Scaffold(
      backgroundColor: BrandColors.darkBg,
      body: Stack(
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
                    Image.asset(
                      'assets/images/vora_logo.png',
                      height: 96,
                    ),
                    const SizedBox(height: 12),
                    const VoraWordmark(fontSize: 30),
                    const SizedBox(height: 22),
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: BrandColors.primary,
                        backgroundColor: Color(0x26FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: SvgPicture.asset("assets/images/vector_bottom.svg",colorFilter: const ColorFilter.mode(BrandColors.primary, BlendMode.srcIn),),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SvgPicture.asset("assets/images/vector_top.svg",colorFilter: const ColorFilter.mode(BrandColors.secondary, BlendMode.srcIn)),
        )
      ],
    ),
    );
    // );
  }
}
