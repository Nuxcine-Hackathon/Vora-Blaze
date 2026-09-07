import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/assistant_repository.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  List<Object?> get props => [text, isUser];
}

class AssistantState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;

  const AssistantState({this.messages = const [], this.isLoading = false});

  AssistantState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading];
}

class AssistantCubit extends Cubit<AssistantState> {
  final AssistantRepository assistantRepository;
  AssistantCubit(this.assistantRepository) : super(const AssistantState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final updatedMessages = [
      ...state.messages,
      ChatMessage(text: text, isUser: true),
    ];
    emit(state.copyWith(messages: updatedMessages, isLoading: true));

    final history = state.messages
        .map((m) => {"role": m.isUser ? "user" : "model", "text": m.text})
        .toList();

    try {
      final response = await assistantRepository.sendMessage(
        message: text,
        history: history,
      );

      final reply = response["status"] == 200
          ? (response["data"]?["reply"]?.toString() ??
              "Désolé, je n'ai pas de réponse pour le moment.")
          : "Désolé, l'assistant est momentanément indisponible.";

      emit(state.copyWith(
        messages: [...updatedMessages, ChatMessage(text: reply, isUser: false)],
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        messages: [
          ...updatedMessages,
          const ChatMessage(
            text: "Désolé, l'assistant est momentanément indisponible.",
            isUser: false,
          ),
        ],
        isLoading: false,
      ));
    }
  }
}
