import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  String? userAnswer;
  bool? isCorrect;

  QuizQuestion({
    required this.id,
    required this.question,
    this.options = const [],
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
  });

  bool get isMCQ => options.isNotEmpty;
}

class QuizProvider extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isGenerating = false;
  String _rawResponse = '';
  StreamSubscription<String>? _streamSub;
  String? _error;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isGenerating => _isGenerating;
  String get rawResponse => _rawResponse;
  String? get error => _error;
  bool get isFinished => _questions.isNotEmpty && _currentIndex >= _questions.length;

  QuizQuestion? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  int get correctCount => _questions.where((q) => q.isCorrect == true).length;
  int get totalCount => _questions.length;
  int get answeredCount =>
      _questions.where((q) => q.userAnswer != null).length;

  String _buildPrompt(String content) {
    return '''
你是一个出题老师。根据以下学习内容生成 5 道测验题来检验学习效果。

输出格式要求（严格遵守 JSON，不要额外文字）：
{
  "questions": [
    {
      "id": "1",
      "type": "mcq",
      "question": "题目",
      "options": ["A. 选项1", "B. 选项2", "C. 选项3", "D. 选项4"],
      "answer": "A"
    },
    {
      "id": "2",
      "type": "fill",
      "question": "填空题：______是...",
      "answer": "正确答案"
    }
  ]
}

学习内容：
$content''';
  }

  Future<void> generateQuiz(String content) async {
    _isGenerating = true;
    _rawResponse = '';
    _questions = [];
    _currentIndex = 0;
    _error = null;
    notifyListeners();

    final sessionId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final stream = _aiService.chatStream(sessionId, _buildPrompt(content));
      _streamSub = stream.listen(
        (chunk) {
          _rawResponse += chunk;
          notifyListeners();
        },
        onDone: () {
          _parseQuestions();
          _isGenerating = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'AI 生成失败，请重试';
          _isGenerating = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = '网络连接失败';
      _isGenerating = false;
      notifyListeners();
    }
  }

  void _parseQuestions() {
    try {
      String jsonStr = _rawResponse;
      final match = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(_rawResponse);
      if (match != null) jsonStr = match.group(1)!;

      final data = jsonDecode(jsonStr);
      final list = data['questions'] as List;
      _questions = list.map((q) => QuizQuestion(
        id: q['id']?.toString() ?? '',
        question: q['question'] ?? '',
        options: q['type'] == 'mcq'
            ? List<String>.from(q['options'] ?? [])
            : [],
        correctAnswer: q['answer']?.toString() ?? '',
      )).toList();

      if (_questions.isEmpty) {
        _error = '未能解析题目，请重试';
      }
    } catch (_) {
      _error = '题目解析失败，请重试';
    }
  }

  void answerQuestion(String answer) {
    if (_currentIndex >= _questions.length) return;
    final q = _questions[_currentIndex];
    q.userAnswer = answer;
    q.isCorrect = answer.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void skipQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void reset() {
    _streamSub?.cancel();
    _questions = [];
    _currentIndex = 0;
    _rawResponse = '';
    _isGenerating = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
