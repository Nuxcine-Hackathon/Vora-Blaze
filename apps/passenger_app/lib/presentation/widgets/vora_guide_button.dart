import 'package:flutter/material.dart';
import 'package:ride_on/core/services/voice_announcer.dart';
import 'package:ride_on/core/services/vora_guide_script.dart';
import 'package:ride_on/core/utils/theme/project_color.dart';
import 'package:ride_on/presentation/screens/assistant/assistant_chat_screen.dart';
import 'package:ride_on/presentation/widgets/brand_companion.dart';

/// Bouton flottant toujours trouvable. Un tap ouvre l'assistant, un second
/// contact fait parler Vora. Les répliques sont locales.
class VoraGuideButton extends StatefulWidget {
  const VoraGuideButton({
    super.key,
    required this.scene,
    this.speakOnAppear = true,
  });

  final VoraGuideScene scene;
  final bool speakOnAppear;

  @override
  State<VoraGuideButton> createState() => _VoraGuideButtonState();
}

class _VoraGuideButtonState extends State<VoraGuideButton> {
  static final Set<VoraGuideScene> _alreadySpoken = <VoraGuideScene>{};

  late final VoraGuideLine _line;

  @override
  void initState() {
    super.initState();
    _line = VoraGuideScript.of(widget.scene);
    if (widget.speakOnAppear && !_alreadySpoken.contains(widget.scene)) {
      _alreadySpoken.add(widget.scene);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        VoiceAnnouncer.instance.speakGuide(_line.spoken);
      });
    }
  }

  void _openAssistant() {
    VoiceAnnouncer.instance.speakGuide(_line.spoken);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssistantChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _openAssistant,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 188),
              margin: const EdgeInsets.only(bottom: 8, right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BrandColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _line.bubble,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          BrandCompanion(
            size: 68,
            mood: BrandCompanionMood.trust,
            speakText: _line.spoken,
            onTap: _openAssistant,
          ),
        ],
      ),
    );
  }
}
