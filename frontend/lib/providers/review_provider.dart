import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/review_plan.dart';
import '../services/review_service.dart';
import '../services/api_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<ReviewPlan> _todayTasks = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewPlan> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodayTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayTasks = await _reviewService.getTodayTasks();
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载复习任务失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> completeReview(int planId, int score) async {
    try {
      await _reviewService.completeReview(planId, score);
      _todayTasks.removeWhere((t) => t.planId == planId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}