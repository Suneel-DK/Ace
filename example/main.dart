import 'package:ace_chat/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the JSON knowledge base
  final jsonString = await rootBundle.loadString('assets/data.json');
  final knowledgeBase = jsonDecode(jsonString);

  runApp(
    MaterialApp(
      home: AceChat(
        apiKey: 'YOUR_GEMINI_API_KEY',
        knowledgeBase: knowledgeBase,
        botName: "Helper Bot",
      ),
    ),
  );
}
