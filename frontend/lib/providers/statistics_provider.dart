import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/statistics.dart';
import '../services/statistics_service.dart';
import '../services/api_service.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();

  DailyStats? _dailyStats;
  WeeklyStats? _weeklyStats;
  Trend? _trend;
  List<DailyStats> _heatmapData = [];
  int _currentStreak = 0;
  SummaryData? _summary;
  List<CategoryRetention> _retention = [];
  bool _isLoading = false;
  String? _error;

  DailyStats? get dailyStats => _dailyStats;
  WeeklyStats? get weeklyStats => _weeklyStats;
  Trend? get trend => _trend;
  List<DailyStats> get heatmapData => _heatmapData;
  int get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SummaryData? get summary => _summary;
  List<CategoryRetention> get retention => _retention;

  Future<void> loadDailyStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dailyStats = await _statisticsService.getDailyStats();
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载统计数据失败';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeeklyStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weeklyStats = await _statisticsService.getWeeklyStats();
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载周统计失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTrend(int days) async {
    _error = null;
    try {
      _trend = await _statisticsService.getTrend(days);
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载趋势数据失败';
    }
    notifyListeners();
  }

  Future<void> loadHeatmap(int year, {int? month}) async {
    try {
      _heatmapData = await _statisticsService.getHeatmap(year: year, month: month);
      if (_heatmapData.isNotEmpty && _heatmapData.last.streak > 0) {
        _currentStreak = _heatmapData.last.streak;
      }
    } catch (_) {
      _error = '加载热力图失败';
    }
    notifyListeners();
  }

  Future<void> reportDuration(int seconds) async {
    try {
      await _statisticsService.reportDuration(seconds);
    } catch (_) {}
  }

  Future<void> loadSummary() async {
    try {
      _summary = await _statisticsService.getSummary();
    } catch (_) {
      _error = '加载成就数据失败';
    }
    notifyListeners();
  }

  Future<void> loadRetention() async {
    try {
      _retention = await _statisticsService.getRetention();
    } catch (_) {
      _error = '加载知识保留数据失败';
    }
    notifyListeners();
  }
}