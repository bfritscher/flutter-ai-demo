import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final FirebaseProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FirebaseProvider(
      model: FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clearHistory,
            tooltip: 'Clear History',
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: LlmChatView(
        provider: _provider,
        welcomeMessage:
            'Hello! I\'m Gemini, your AI assistant. Feel free to ask me anything or challenge me to a game of Tic Tac Toe!',
        suggestions: [
          'Tell me about yourself',
          'How do you play Tic Tac Toe?',
          'What are some good game strategies?',
          'Can you write me a joke?',
        ],
      ),
    );
  }

  void _clearHistory() {
    setState(() {
      _provider.history = [];
    });
  }
}
