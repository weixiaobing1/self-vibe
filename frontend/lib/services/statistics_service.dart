import 'api_service.dart';
import '../models/achievement.dart';
import '../models/statistics.dart';

class StatisticsService {
  final ApiService _api = ApiService();

  Future<DailyStats> getDailyStats() async {
    final resp = await _api.dio.get('/api/statistics/daily');
    return DailyStats.fromJson(resp.data['data']);
  }

  Future<WeeklyStats> getWeeklyStats() async {
    final resp = await _api.dio.get('/api/statistics/weekly');
    return WeeklyStats.fromJson(resp.data['data']);
  }

  Future<Trend> getTrend(int days) async {
    final resp = await _api.dio.get('/api/statistics/trend', queryParameters: {'days': days});
    return Trend.fromJson(resp.data['data']);
  }

  Future<void> reportDuration(int seconds) async {
    await _api.dio.post('/api/statistics/duration', data: {'seconds': seconds});
  }

  Future<List<DailyStats>> getHeatmap({int year = 2026, int? month}) async {
    final params = <String, dynamic>{'year': year};
    if (month != null) params['month'] = month;
    final resp = await _api.dio.get('/api/statistics/heatmap', queryParameters: params);
    return (resp.data['data'] as List).map((e) => DailyStats.fromJson(e)).toList();
  }

  Future<SummaryData> getSummary() async {
    final resp = await _api.dio.get('/api/statistics/summary');
    return SummaryData.fromJson(resp.data['data']);
  }

  Future<List<CategoryRetention>> getRetention() async {
    final resp = await _api.dio.get('/api/statistics/retention');
    return (resp.data['data'] as List)
        .map((e) => CategoryRetention.fromJson(e))
        .toList();
  }
}