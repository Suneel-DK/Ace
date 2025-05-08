import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/gemini_service.dart';

class AceChat extends StatefulWidget {
  final String apiKey;
  final Map<String, dynamic> knowledgeBase;
  final String botName;

  const AceChat({
    super.key,
    required this.apiKey,
    required this.knowledgeBase,
    required this.botName,
  });

  @override
  State<AceChat> createState() => _AceChatState();
}

class _AceChatState extends State<AceChat> with TickerProviderStateMixin {
  final List<Message> messages = [];
  final TextEditingController controller = TextEditingController();
  late GeminiService geminiService;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    geminiService = GeminiService(
      apiKey: widget.apiKey,
      knowledgeBase: widget.knowledgeBase,
      botName: widget.botName,
    );
  }

  void sendMessage() async {
    final userText = controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      messages.add(Message(text: userText, isUser: true));
    });

    controller.clear();
    _scrollToBottom();

    final botReply = await geminiService.getAnswer(userText);

    setState(() {
      messages.add(Message(text: botReply, isUser: false));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Message msg) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: msg.isUser ? Colors.black : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft:
              msg.isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.text,
        style: TextStyle(
          color: msg.isUser ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.botName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (_, i) {
                final msg = messages[i];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: _buildMessage(msg),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
