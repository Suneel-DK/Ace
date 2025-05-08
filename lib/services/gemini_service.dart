import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final String botName;
  final Map<String, dynamic> knowledgeBase;

  GeminiService({
    required this.apiKey,
    required this.knowledgeBase,
    required this.botName,
  });

  Future<String> getAnswer(String question) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
    );

    final prompt = '''
You are an intelligent and friendly AI assistant named $botName. You are designed to have natural, human-like conversations. Be empathetic, calm, respectful, and informative. Adapt your tone based on the user's message:

- If they greet (e.g., "hi", "hello"), greet them back.
- If they sound upset or angry, respond kindly and try to calm them.
- If they ask a question, respond clearly and politely using the provided knowledge base.

Here is your knowledge base:
${jsonEncode(knowledgeBase)}

User: $question
Ace:
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['candidates'][0]['content']['parts'][0]['text'] ??
          'No answer';
    } else {
      return 'Error: ${res.statusCode}';
    }
  }
}
