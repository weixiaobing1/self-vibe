import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/ai_service.dart';
import '../../services/api_service.dart';
import '../../providers/note_provider.dart';
import 'package:provider/provider.dart';

class NoteCreatePage extends StatefulWidget {
  const NoteCreatePage({super.key});

  @override
  State<NoteCreatePage> createState() => _NoteCreatePageState();
}

class _NoteCreatePageState extends State<NoteCreatePage> {
  final _topicCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _aiService = AIService();
  bool _aiLoading = false;
  bool _submitting = false;

  @override
  void dispose() {
    _topicCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _aiGenerate() async {
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入主题')),
      );
      return;
    }

    setState(() => _aiLoading = true);
    try {
      final note = await _aiService.generateNote(topic);
      _contentCtrl.text = note;
    } catch (e) {
      final msg = e is DioException ? ApiService.extractError(e) : 'AI 生成失败';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    setState(() => _aiLoading = false);
  }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入笔记内容')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<NoteProvider>().createNote(content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记创建成功，AI 正在总结...')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      final msg = e is DioException ? ApiService.extractError(e) : '创建失败，请重试';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建笔记'),
        actions: [
          _submitting
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _submit,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic input + AI button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicCtrl,
                    decoration: const InputDecoration(
                      hintText: '输入主题，如：Java 并发编程',
                      labelText: '主题',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                _aiLoading
                    ? const SizedBox(
                        height: 44, width: 44,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _aiGenerate,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('AI 帮写'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),

            // Content editor
            Text('笔记内容', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 20,
              minLines: 10,
              decoration: const InputDecoration(
                hintText: '输入笔记内容，或使用 AI 帮写自动生成...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}