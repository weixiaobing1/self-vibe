import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class MockInterviewProvider extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<ChatMessage> _messages = [];
  String _sessionId = '';
  bool _isLoading = false;
  StreamSubscription<String>? _streamSub;
  String _streamingText = '';
  String _topic = '';
  String _level = '中级';
  bool _hasStarted = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get streamingText => _streamingText;
  bool get hasStarted => _hasStarted;
  String get topic => _topic;
  String get level => _level;

  static const _systemPrompt = '''
你是一名专业的互联网技术面试官。你要进行一场模拟面试。

规则：
1. 首先简单介绍自己，告诉候选人面试的岗位方向，并询问候选人准备好了吗
2. 根据候选人的回答，逐题提问，一次只问一个问题
3. 候选人的每个回答后，先给出简短评估（做得好的地方和可以改进的地方），然后提出下一个问题
4. 问题应该覆盖基础概念、原理理解、实际应用场景，由浅入深
5. 难度：{{level}}
6. 当候选人说"结束面试"或"停止面试"时，给出整体评价（1-10分）+ 3条学习建议
面试方向：{{topic}}
''';

  String _buildInitialMessage() {
    return _systemPrompt
        .replaceAll('{{topic}}', _topic)
        .replaceAll('{{level}}', _level);
  }

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  void setLevel(String level) {
    _level = level;
    notifyListeners();
  }

  Future<void> startInterview() async {
    if (_topic.trim().isEmpty) return;

    _streamSub?.cancel();
    _sessionId = 'mock_interview_${DateTime.now().millisecondsSinceEpoch}';
    _hasStarted = true;
    _isLoading = true;
    _streamingText = '';
    notifyListeners();

    final assistantMsg = ChatMessage(role: 'assistant', content: '', isStreaming: true);
    _messages.add(assistantMsg);

    try {
      final stream = _aiService.chatStream(_sessionId, _buildInitialMessage());

      _streamSub = stream.listen(
        (chunk) {
          _streamingText += chunk;
          assistantMsg.content = _streamingText;
          notifyListeners();
        },
        onDone: () {
          assistantMsg.isStreaming = false;
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

  Future<void> sendAnswer(String answer) async {
    _streamSub?.cancel();
    _messages.add(ChatMessage(role: 'user', content: answer));
    _isLoading = true;
    _streamingText = '';
    notifyListeners();

    final assistantMsg = ChatMessage(role: 'assistant', content: '', isStreaming: true);
    _messages.add(assistantMsg);

    try {
      final stream = _aiService.chatStream(_sessionId, answer);

      _streamSub = stream.listen(
        (chunk) {
          _streamingText += chunk;
          assistantMsg.content = _streamingText;
          notifyListeners();
        },
        onDone: () {
          assistantMsg.isStreaming = false;
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

  Future<void> endInterview() async {
    await sendAnswer('结束面试');
  }

  void reset() {
    _streamSub?.cancel();
    _messages.clear();
    _sessionId = '';
    _streamingText = '';
    _isLoading = false;
    _hasStarted = false;
    _topic = '';
    _level = '中级';
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}