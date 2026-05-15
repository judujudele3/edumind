import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class GeminiService {
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  Future<String> askQuestion(String question, String subject) async {
    final prompt = '''
Tu es un assistant académique expert en $subject.
Réponds à cette question de manière claire, pédagogique et structurée.
Utilise des exemples concrets si nécessaire.

Question : $question

Réponds en français.
''';
    return generateResponse(prompt);
  }

  Future<String> explainConcept(String concept, String subject) async {
    final prompt = '''
Tu es un professeur expert en $subject.
Explique le concept suivant de manière simple et progressive, 
comme si tu l'expliquais à un étudiant.
Inclus des exemples concrets et une analogie si possible.

Concept à expliquer : $concept

Structure ta réponse avec :
1. Définition simple
2. Explication détaillée
3. Exemple concret
4. Points clés à retenir

Réponds en français.
''';
    return generateResponse(prompt);
  }

  Future<List<Map<String, dynamic>>> generateQCM(
      String subject, String topic, int count) async {
    final prompt = '''
Génère $count questions QCM sur le sujet "$topic" en $subject.
Réponds UNIQUEMENT avec un JSON valide, sans texte avant ou après, sans markdown.
Format exact :
[
  {
    "question": "Question ici ?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct": 0,
    "explanation": "Explication de la bonne réponse"
  }
]
''';

    final response = await generateResponse(prompt);
    try {
      final cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> parsed = jsonDecode(cleaned);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur parsing QCM : $e');
    }
  }
}