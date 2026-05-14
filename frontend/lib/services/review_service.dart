import 'api_service.dart';
import '../models/review_plan.dart';

class ReviewService {
  final ApiService _api = ApiService();

  Future<List<ReviewPlan>> getTodayTasks() async {
    final resp = await _api.dio.get('/api/review/today');
    final list = resp.data['data'] as List;
    return list.map((e) => ReviewPlan.fromJson(e)).toList();
  }

  Future<void> completeReview(int planId, int score) async {
    await _api.dio.post('/api/review/complete', data: {
      'planId': planId,
      'score': score,
    });
  }

  Future<Map<String, dynamic>> getHistory({int pageNum = 1, int pageSize = 10}) async {
    final resp = await _api.dio.get('/api/review/history', queryParameters: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    final data = resp.data['data'];
    return {
      'list': (data['list'] as List).map((e) => ReviewPlan.fromJson(e)).toList(),
      'total': data['total'] ?? 0,
    };
  }
}