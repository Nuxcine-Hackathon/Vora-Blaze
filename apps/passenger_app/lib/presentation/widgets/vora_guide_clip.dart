import 'package:flutter/material.dart';
import 'package:ride_on/core/services/voice_announcer.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';
import 'package:ride_on/presentation/widgets/brand_companion.dart';
import 'package:video_player/video_player.dart';

/// Clip local de l'assistante VORA. En cas d'échec, on retombe sur l'avatar.
class VoraGuideClip extends StatefulWidget {
  const VoraGuideClip({
    super.key,
    required this.asset,
    required this.size,
    this.playOnAppear = true,
    this.onTap,
    this.onCompleted,
    this.semanticsLabel,
    this.mood = BrandCompanionMood.welcome,
  });

  final String asset;
  final double size;
  final bool playOnAppear;
  final VoidCallback? onTap;
  final VoidCallback? onCompleted;
  final String? semanticsLabel;
  final BrandCompanionMood mood;

  @override
  State<VoraGuideClip> createState() => _VoraGuideClipState();
}

class _VoraGuideClipState extends State<VoraGuideClip> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final controller = VideoPlayerController.asset(widget.asset);
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.setLooping(false);
      controller.setVolume(1);
      controller.addListener(_onTick);
      _controller = controller;
      setState(() => _ready = true);
      if (widget.playOnAppear) {
        await _play();
      }
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() => _failed = true);
      widget.onCompleted?.call();
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final ended = controller.value.position >= controller.value.duration &&
        controller.value.duration > Duration.zero &&
        !controller.value.isPlaying;
    if (ended && !_finished && mounted) {
      setState(() => _finished = true);
      widget.onCompleted?.call();
    }
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await VoiceAnnouncer.instance.stop();
    await controller.seekTo(Duration.zero);
    if (!mounted) return;
    setState(() => _finished = false);
    await controller.play();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    _play();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return BrandCompanion(
        size: widget.size,
        mood: widget.mood,
        speakOnAppear: widget.playOnAppear,
        onTap: widget.onTap,
      );
    }

    final glow = switch (widget.mood) {
      BrandCompanionMood.welcome => BrandColors.primary.withValues(alpha: 0.22),
      BrandCompanionMood.trust => BrandColors.success.withValues(alpha: 0.22),
      BrandCompanionMood.idle => BrandColors.ink.withValues(alpha: 0.16),
    };

    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? "Guide Vora",
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: glow,
                  blurRadius: widget.size * 0.22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.size * 0.04),
              child: ClipOval(
                child: ColoredBox(
                  color: BrandColors.navIdleBg,
                  child: _ready && _controller != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.size.width,
                                height: _controller!.value.size.height,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                            if (_finished)
                              ColoredBox(
                                color: Colors.black26,
                                child: Icon(
                                  Icons.replay_rounded,
                                  color: Colors.white,
                                  size: widget.size * 0.28,
                                ),
                              ),
                          ],
                        )
                      : const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
