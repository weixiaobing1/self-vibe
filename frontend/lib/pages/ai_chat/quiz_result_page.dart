import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/quiz_provider.dart';
import 'quiz_page.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final qp = context.read<QuizProvider>();

    if (qp.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('测验结果')),
        body: const Center(child: Text('没有数据')),
      );
    }

    final score = qp.correctCount;
    final total = qp.totalCount;
    final percentage = total > 0 ? (score / total * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      appBar: AppBar(title: const Text('测验结果')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('$percentage%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,
                      color: score == total ? AppTheme.success : AppTheme.accentColor)),
                  SizedBox(height: 8),
                  Text('$score / $total 正确',
                      style: TextStyle(fontSize: 18, color: AppTheme.textPrimary)),
                  SizedBox(height: 4),
                  Text(
                    score == total ? '完美！全部答对' :
                    score >= total * 0.6 ? '表现不错，继续加油' : '需要加强复习哦',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Per-question review
          Text('题目回顾', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          ...qp.questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('第 ${idx + 1} 题', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Icon(
                          q.isCorrect == true ? Icons.check_circle : Icons.cancel,
                          color: q.isCorrect == true ? AppTheme.success : AppTheme.error,
                          size: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(q.question, style: TextStyle(color: AppTheme.textPrimary, height: 1.5)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('你的答案: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          q.userAnswer ?? '未作答',
                          style: TextStyle(
                            color: q.isCorrect == true ? AppTheme.success : AppTheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (q.isCorrect != true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text('正确答案: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            Text(q.correctAnswer,
                                style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    qp.reset();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizPage()),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新测验'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    qp.reset();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
