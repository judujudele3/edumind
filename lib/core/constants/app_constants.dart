class AppConstants {
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';
}