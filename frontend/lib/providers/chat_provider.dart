import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<ChatMessage> _messages = [];
  String _sessionId = '';
  bool _isLoading = false;
  StreamSubscription<String>? _streamSub;
  String _streamingText = '';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get streamingText => _streamingText;
  String get sessionId => _sessionId;

  void initSession(String? existingSessionId) {
    _sessionId = existingSessionId ?? '';
    _streamingText = '';
  }

  Future<void> sendMessage(String content) async {
    _streamSub?.cancel();
    _messages.add(ChatMessage(role: 'user', content: content));
    _isLoading = true;
    _streamingText = '';
    notifyListeners();

    final assistantMsg = ChatMessage(role: 'assistant', content: '', isStreaming: true);
    _messages.add(assistantMsg);

    try {
      final stream = _aiService.chatStream(_sessionId, content);

      _streamSub = stream.listen(
        (chunk) {
          _streamingText += chunk;
          assistantMsg.content = _streamingText;
          notifyListeners();
        },
        onDone: () {
          assistantMsg.isStreaming = false;
          if (_sessionId.isEmpty) _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
          _isLoading = false;
          _streamingText = '';
          notifyListeners();
        },
        onError: (error) {
          assistantMsg.content = '抱歉，AI 响应出错，请重试';
          assistantMsg.isStreaming = false;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      assistantMsg.content = '抱歉，网络连接失败';
      assistantMsg.isStreaming = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<InterviewQuestion>> generateInterview(int noteId) async {
    try {
      return await _aiService.generateInterview(noteId);
    } catch (_) {
      return [];
    }
  }

  void clearChat() {
    _streamSub?.cancel();
    _messages.clear();
    _sessionId = '';
    _streamingText = '';
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}