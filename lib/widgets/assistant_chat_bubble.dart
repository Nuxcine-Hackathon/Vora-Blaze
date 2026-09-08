import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

/// Bulle de chat flottante pour l'assistant IA. Le personnage animé
/// (Dassi/Elisabeth) viendra remplacer l'icône par défaut une fois exporté
/// de Figma — voir U8 dans la fiche de suivi.
class AssistantChatButton extends StatelessWidget {
  final String? tripId;

  const AssistantChatButton({super.key, this.tripId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'assistant_button',
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _AssistantChatSheet(tripId: tripId),
      ),
      child: const Icon(Icons.chat_bubble_outline),
    );
  }
}

class _AssistantChatSheet extends StatefulWidget {
  final String? tripId;
  const _AssistantChatSheet({this.tripId});

  @override
  State<_AssistantChatSheet> createState() => _AssistantChatSheetState();
}

class _AssistantChatSheetState extends State<_AssistantChatSheet> {
  final _api = VoraApiService();
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage("Bonjour ! Je peux vous renseigner sur votre course, le prix, ou vous aider en cas de problème.", false),
  ];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, true));
      _sending = true;
    });
    _controller.clear();
    try {
      final result = await _api.askAssistant(message: text, tripId: widget.tripId);
      setState(() => _messages.add(ChatMessage(result['response'], false)));
    } catch (e) {
      setState(() => _messages.add(ChatMessage("Désolé, je n'ai pas pu traiter votre demande.", false)));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Assistant VORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: m.isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text),
                    ),
                  );
                },
              ),
            ),
            if (_sending) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Posez votre question...', border: OutlineInputBorder()),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sending ? null : _send),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
