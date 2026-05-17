import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';
import '../../providers/quiz_provider.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Set<int> _selectedIds = {};
  String? _selectedCategory;
  bool _quizStarted = false;
  final _fillCtrl = TextEditingController();

  @override
  void dispose() {
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
      context.read<NoteProvider>().loadCategories();
    });
  }

  void _startQuiz() {
    final np = context.read<NoteProvider>();
    List<Note> selected;
    if (_selectedCategory != null) {
      selected = np.notes.where((n) => n.category == _selectedCategory).toList();
    } else {
      selected = np.notes.where((n) => _selectedIds.contains(n.id)).toList();
    }

    if (selected.isEmpty) return;

    final content = selected.map((n) => n.content ?? '').join('\n\n');
    final qp = context.read<QuizProvider>();
    qp.generateQuiz(content);
    setState(() => _quizStarted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 测验'),
        actions: [
          if (_quizStarted)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '退出测验',
              onPressed: () {
                context.read<QuizProvider>().reset();
                setState(() => _quizStarted = false);
              },
            ),
        ],
      ),
      body: _quizStarted ? _buildQuizPhase() : _buildSelectionPhase(),
    );
  }

  Widget _buildSelectionPhase() {
    return Consumer<NoteProvider>(
      builder: (context, np, _) {
        if (np.isLoading && np.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasSelection = _selectedIds.isNotEmpty || _selectedCategory != null;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('选择测验范围', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 8),
            Text('选择笔记或分类，AI 将根据内容生成测验题',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            SizedBox(height: 16),

            // Category quick-select
            if (np.categories.isNotEmpty) ...[
              Text('按分类选择', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: np.categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        _selectedCategory = v ? cat : null;
                        _selectedIds.clear();
                      });
                    },
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.accentColor : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              const Divider(),
              SizedBox(height: 8),
            ],

            // Note list with checkboxes
            Text('按笔记选择', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 8),
            if (np.notes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('还没有笔记', style: TextStyle(color: AppTheme.textSecondary))),
              )
            else
              ...np.notes.map((note) => CheckboxListTile(
                    title: Text(note.summary ?? '无标题', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                    subtitle: note.category != null
                        ? Text(note.category!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))
                        : null,
                    value: _selectedIds.contains(note.id),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedIds.add(note.id);
                          _selectedCategory = null;
                        } else {
                          _selectedIds.remove(note.id);
                        }
                      });
                    },
                    activeColor: AppTheme.accentColor,
                    dense: true,
                  )),

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasSelection ? _startQuiz : null,
                icon: const Icon(Icons.auto_awesome),
                label: Text(hasSelection
                    ? '开始生成测验 (${_selectedCategory != null ? "分类: $_selectedCategory" : "${_selectedIds.length}篇笔记"})'
                    : '请选择笔记或分类'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection ? AppTheme.accentColor : AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizPhase() {
    return Consumer<QuizProvider>(
      builder: (context, qp, _) {
        if (qp.isGenerating) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text('AI 正在生成测验题...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                ],
              ),
            ),
          );
        }

        if (qp.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                SizedBox(height: 16),
                Text(qp.error!, style: TextStyle(color: AppTheme.error)),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () {
                    context.read<QuizProvider>().reset();
                    setState(() => _quizStarted = false);
                  },
                    child: const Text('返回')),
              ],
            ),
          );
        }

        if (qp.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final q = qp.currentQuestion;
        if (q == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              Row(
                children: [
                  Text('第 ${qp.currentIndex + 1}/${qp.totalCount} 题',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const Spacer(),
                  Text('已答 ${qp.answeredCount} 题',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (qp.currentIndex + 1) / qp.totalCount,
                  backgroundColor: AppTheme.surfaceColor,
                  color: AppTheme.accentColor,
                  minHeight: 4,
                ),
              ),
              SizedBox(height: 24),

              // Question card
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: q.isMCQ ? AppTheme.accentColor.withValues(alpha: 0.15) : AppTheme.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              q.isMCQ ? '选择题' : '填空题',
                              style: TextStyle(
                                fontSize: 12,
                                color: q.isMCQ ? AppTheme.accentColor : AppTheme.warning,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(q.question, style: TextStyle(fontSize: 16, color: AppTheme.textPrimary, height: 1.6)),
                          SizedBox(height: 24),

                          // Options for MCQ
                          if (q.isMCQ) ...q.options.map((opt) {
                            final isSelected = q.userAnswer == opt.substring(0, 1);
                            final showResult = q.userAnswer != null;
                            final isCorrectOpt = opt.substring(0, 1) == q.correctAnswer;

                            Color? bgColor;
                            if (showResult) {
                              if (isCorrectOpt) {
                                bgColor = AppTheme.success.withValues(alpha: 0.15);
                              } else if (isSelected && !q.isCorrect!) {
                                bgColor = AppTheme.error.withValues(alpha: 0.15);
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: q.userAnswer != null
                                    ? null
                                    : () {
                                        qp.answerQuestion(opt.substring(0, 1));
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: bgColor ?? AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected && !showResult
                                          ? AppTheme.accentColor
                                          : isCorrectOpt && showResult
                                              ? AppTheme.success
                                              : AppTheme.cardColor,
                                      width: isSelected || (showResult && isCorrectOpt) ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? (showResult
                                                  ? (q.isCorrect! ? AppTheme.success : AppTheme.error)
                                                  : AppTheme.accentColor)
                                              : AppTheme.cardColor,
                                        ),
                                        child: Center(
                                          child: Text(opt.substring(0, 1),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                                              )),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(opt.substring(3),
                                            style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                                      ),
                                      if (showResult && isCorrectOpt)
                                        Icon(Icons.check_circle, size: 20, color: AppTheme.success),
                                      if (showResult && isSelected && !q.isCorrect!)
                                        Icon(Icons.cancel, size: 20, color: AppTheme.error),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Fill-in-blank
                          if (!q.isMCQ) ...[
                            TextField(
                              controller: _fillCtrl,
                              decoration: InputDecoration(
                                hintText: '输入你的答案...',
                                enabled: q.userAnswer == null,
                                suffixIcon: q.userAnswer != null
                                    ? Icon(
                                        q.isCorrect! ? Icons.check_circle : Icons.cancel,
                                        color: q.isCorrect! ? AppTheme.success : AppTheme.error,
                                      )
                                    : null,
                              ),
                              onSubmitted: q.userAnswer != null ? null : (v) => qp.answerQuestion(v.trim()),
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            if (q.userAnswer != null) ...[
                              if (!q.isCorrect!) ...[
                                SizedBox(height: 8),
                                Text('正确答案: ${q.correctAnswer}',
                                    style: TextStyle(color: AppTheme.success, fontSize: 13)),
                              ],
                            ] else ...[
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final v = _fillCtrl.text.trim();
                                    if (v.isNotEmpty) {
                                      qp.answerQuestion(v);
                                      _fillCtrl.clear();
                                    }
                                  },
                                  child: const Text('提交'),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              // Nav buttons
              Row(
                children: [
                  if (qp.currentIndex > 0)
                    TextButton.icon(
                      onPressed: () {
                        qp.prevQuestion();
                        _fillCtrl.text = qp.currentQuestion?.userAnswer ?? '';
                      },
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('上一题'),
                    )
                  else
                    const Spacer(),
                  const Spacer(),
                  if (qp.currentIndex < qp.totalCount - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        qp.nextQuestion();
                        _fillCtrl.text = qp.currentQuestion?.userAnswer ?? '';
                      },
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('下一题'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizResultPage()),
                        );
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text('查看结果'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
