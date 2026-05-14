import 'api_service.dart';
import '../models/note.dart';

class NoteService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createNote(String content) async {
    final resp = await _api.dio.post('/api/note/create', data: {
      'content': content,
      'contentType': 'text',
    });
    return resp.data['data'];
  }

  Future<Map<String, dynamic>> getNoteList({
    int pageNum = 1,
    int pageSize = 10,
    String? category,
    String? keyword,
  }) async {
    final params = <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final resp = await _api.dio.get('/api/note/list', queryParameters: params);
    final data = resp.data['data'];
    return {
      'list': (data['list'] as List).map((e) => Note.fromJson(e)).toList(),
      'total': data['total'] ?? 0,
      'pageNum': data['pageNum'] ?? 1,
      'pageSize': data['pageSize'] ?? 10,
    };
  }

  Future<NoteDetail> getNoteDetail(int id) async {
    final resp = await _api.dio.get('/api/note/detail/$id');
    return NoteDetail.fromJson(resp.data['data']['noteInfo']);
  }

  Future<void> deleteNote(int id) async {
    await _api.dio.delete('/api/note/delete/$id');
  }

  Future<List<String>> getCategories() async {
    final resp = await _api.dio.get('/api/note/categories');
    return List<String>.from(resp.data['data'] ?? []);
  }

  Future<List<String>> getTags() async {
    final resp = await _api.dio.get('/api/note/tags');
    return List<String>.from(resp.data['data'] ?? []);
  }
}