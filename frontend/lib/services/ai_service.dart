import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import '../models/note.dart';

class AIService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> summarize(String content) async {
    final resp = await _api.dio.post('/api/ai/summarize', data: {'content': content});
    return resp.data['data'];
  }

  Future<List<InterviewQuestion>> generateInterview(int noteId) async {
    final resp = await _api.dio.post('/api/ai/generate-interview', data: {'noteId': noteId});
    final questions = resp.data['data']['questions'] as List;
    return questions.map((e) => InterviewQuestion.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> explainCode(String code) async {
    final resp = await _api.dio.post('/api/ai/explain-code', data: {'code': code});
    return resp.data['data'];
  }

  Stream<String> chatStream(String sessionId, String content) {
    final controller = StreamController<String>();

    _startSSEStream(controller, sessionId, content);

    return controller.stream;
  }

  Future<String> generateNote(String topic) async {
    final resp = await _api.dio.post('/api/ai/generate-note', data: {'topic': topic});
    return resp.data['data'];
  }

  Future<void> _startSSEStream(
      StreamController<String> controller, String sessionId, String content) async {
    try {
      final token = await _api.getToken();
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: const Duration(minutes: 5),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ));

      final response = await dio.post(
        '/api/ai/chat/stream',
        data: {'sessionId': sessionId, 'content': content},
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String leftover = '';

      await for (final chunk in stream) {
        leftover += utf8.decode(chunk);

        // SSE events are separated by \n\n
        while (leftover.contains('\n\n')) {
          final eventEnd = leftover.indexOf('\n\n');
          final event = leftover.substring(0, eventEnd);
          leftover = leftover.substring(eventEnd + 2);

          // Extract content from data: lines
          for (final line in event.split('\n')) {
            if (line.startsWith('data:')) {
              controller.add(line.substring(5));
            }
          }
        }
      }

      await controller.close();
    } catch (e) {
      controller.addError(e);
      await controller.close();
    }
  }

  Future<Map<String, dynamic>> chat(String sessionId, String content) async {
    final resp = await _api.dio.post('/api/ai/chat', data: {
      'sessionId': sessionId,
      'content': content,
    });
    return resp.data['data'];
  }
}