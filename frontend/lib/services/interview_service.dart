import 'api_service.dart';
import '../models/note.dart';

class InterviewService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getQuestions({
    int pageNum = 1,
    int pageSize = 10,
    String? level,
    int? isMastered,
  }) async {
    final params = <String, dynamic>{'pageNum': pageNum, 'pageSize': pageSize};
    if (level != null) params['level'] = level;
    if (isMastered != null) params['isMastered'] = isMastered;

    final resp = await _api.dio.get('/api/interview/questions', queryParameters: params);
    final data = resp.data['data'];
    return {
      'list': (data['list'] as List).map((e) => InterviewQuestion.fromJson(e)).toList(),
      'total': data['total'] ?? 0,
      'pageNum': data['pageNum'] ?? 1,
      'pageSize': data['pageSize'] ?? 10,
    };
  }

  Future<void> toggleMastered(int id) async {
    await _api.dio.put('/api/interview/questions/$id/toggle-mastered');
  }
}