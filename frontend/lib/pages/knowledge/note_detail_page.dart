import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNoteDetail(widget.noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('笔记详情')),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, _) {
          if (noteProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final note = noteProvider.currentNote;
          if (note == null) {
            if (noteProvider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(noteProvider.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () => noteProvider.loadNoteDetail(widget.noteId), child: const Text('重试')),
                    ],
                  ),
                ),
              );
            }
            return Center(child: Text('笔记不存在', style: TextStyle(color: AppTheme.textSecondary)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.category != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(note.category!, style: TextStyle(color: AppTheme.accentColor)),
                      ),
                      SizedBox(width: 8),
                      if (note.difficulty != null)
                        Text(note.difficulty!, style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                SizedBox(height: 16),
                if (note.summary != null) ...[
                  Text('AI 摘要', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  SizedBox(height: 8),
                  Text(note.summary!, style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.6)),
                  SizedBox(height: 16),
                ],
                Text('原始内容', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                SizedBox(height: 8),
                Text(note.content ?? '', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                if (note.interviewQuestions.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Text('关联面试题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  SizedBox(height: 8),
                  ...note.interviewQuestions.map((q) => _buildQuestionCard(q)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(InterviewQuestion q) {
    bool expanded = false;
    return StatefulBuilder(
      builder: (context, setLocalState) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => setLocalState(() => expanded = !expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (q.level == '初级' ? Colors.green : q.level == '中级' ? Colors.orange : Colors.red).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(q.level ?? '', style: const TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(q.question ?? '', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
                  ],
                ),
                if (expanded && q.answer != null) ...[
                  const Divider(height: 24),
                  Text(q.answer!, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}