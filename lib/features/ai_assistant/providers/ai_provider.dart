import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _service;
  bool isLoading = false;

  AiChatNotifier(this._service) : super([]);

  Future<void> sendMessage(String message, String subject) async {
    state = [
      ...state,
      ChatMessage(text: message, isUser: true, createdAt: DateTime.now()),
    ];
    isLoading = true;

    try {
      final response = await _service.askQuestion(message, subject);
      state = [
        ...state,
        ChatMessage(text: response, isUser: false, createdAt: DateTime.now()),
      ];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
            text: 'Erreur : ${e.toString()}',
            isUser: false,
            createdAt: DateTime.now()),
      ];
    }
    isLoading = false;
  }

  void clearChat() => state = [];
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, List<ChatMessage>>((ref) {
  return AiChatNotifier(ref.read(geminiServiceProvider));
});

final aiLoadingProvider = StateProvider<bool>((ref) => false);