import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/interview_service.dart';

class InterviewProvider extends ChangeNotifier {
  final InterviewService _service = InterviewService();

  List<InterviewQuestion> _questions = [];
  bool _isLoading = false;
  int _total = 0;
  int _pageNum = 1;
  String? _levelFilter;
  int? _masteredFilter;

  List<InterviewQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  int get total => _total;
  String? get levelFilter => _levelFilter;
  int? get masteredFilter => _masteredFilter;

  Future<void> loadQuestions({String? level, int? isMastered}) async {
    _isLoading = true;
    _pageNum = 1;
    _levelFilter = level;
    _masteredFilter = isMastered;
    notifyListeners();

    try {
      final result = await _service.getQuestions(
        level: level,
        isMastered: isMastered,
      );
      _questions = result['list'] as List<InterviewQuestion>;
      _total = result['total'] as int;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_questions.length >= _total) return;
    _pageNum++;
    try {
      final result = await _service.getQuestions(
        pageNum: _pageNum,
        level: _levelFilter,
        isMastered: _masteredFilter,
      );
      _questions.addAll(result['list'] as List<InterviewQuestion>);
      _total = result['total'] as int;
      notifyListeners();
    } catch (_) {
      _pageNum--;
    }
  }

  Future<void> toggleMastered(int id) async {
    try {
      await _service.toggleMastered(id);
      final idx = _questions.indexWhere((q) => q.id == id);
      if (idx != -1) {
        final q = _questions[idx];
        _questions[idx] = InterviewQuestion(
          id: q.id,
          question: q.question,
          answer: q.answer,
          level: q.level,
          isMastered: q.isMastered == 1 ? 0 : 1,
          createTime: q.createTime,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  InterviewQuestion? getRandomQuestion() {
    if (_questions.isEmpty) return null;
    _questions.shuffle();
    return _questions.first;
  }
}