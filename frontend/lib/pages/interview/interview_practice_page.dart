import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/note.dart';
import '../../providers/interview_provider.dart';

class InterviewPracticePage extends StatefulWidget {
  final InterviewQuestion question;

  const InterviewPracticePage({super.key, required this.question});

  @override
  State<InterviewPracticePage> createState() => _InterviewPracticePageState();
}

class _InterviewPracticePageState extends State<InterviewPracticePage> {
  late InterviewQuestion _current;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _current = widget.question;
  }

  void _randomQuestion() {
    final ip = context.read<InterviewProvider>();
    if (ip.questions.isEmpty) return;
    final random = ip.questions.toList()..shuffle();
    setState(() {
      _current = random.first;
      _isFlipped = false;
    });
  }

  Future<void> _toggleMastered() async {
    final ip = context.read<InterviewProvider>();
    final wasMastered = _current.isMastered;
    setState(() {
      _current = InterviewQuestion(
        id: _current.id,
        question: _current.question,
        answer: _current.answer,
        level: _current.level,
        isMastered: wasMastered == 1 ? 0 : 1,
        createTime: _current.createTime,
      );
    });

    try {
      await ip.toggleMastered(_current.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _current = InterviewQuestion(
            id: _current.id,
            question: _current.question,
            answer: _current.answer,
            level: _current.level,
            isMastered: wasMastered,
            createTime: _current.createTime,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _current.level == '初级' ? AppTheme.success : _current.level == '中级' ? AppTheme.warning : AppTheme.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('面试练习'),
        actions: [
          IconButton(
            icon: Icon(
              _current.isMastered == 1 ? Icons.check_circle : Icons.check_circle_outline,
              color: _current.isMastered == 1 ? AppTheme.success : AppTheme.textSecondary,
            ),
            tooltip: '标记掌握',
            onPressed: _toggleMastered,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: '随机题目',
            onPressed: _randomQuestion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Level badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_current.level ?? '',
                      style: TextStyle(color: levelColor, fontWeight: FontWeight.bold)),
                ),
                if (_current.isMastered == 1) ...[
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                ],
              ],
            ),
            SizedBox(height: 20),

            // Flip card
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) {
                    return RotationYTransition(
                      animation: anim,
                      child: child,
                    );
                  },
                  child: _isFlipped ? _buildBack(levelColor) : _buildFront(levelColor),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              _isFlipped ? '点击卡片翻转查看题目' : '点击卡片翻转查看答案',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(Color levelColor) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: levelColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, size: 48, color: AppTheme.accentColor),
              SizedBox(height: 24),
              Text(
                _current.question ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppTheme.textPrimary, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(Color levelColor) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 28, color: AppTheme.warning),
                SizedBox(width: 8),
                Text('参考答案', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _current.answer ?? '',
              style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Animation<double> animation;
  final Widget child;

  const RotationYTransition({super.key, required this.animation, required this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = animation.value;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(value * 3.14159),
      alignment: Alignment.center,
      child: value <= 0.5 ? child : _flip(child),
    );
  }

  Widget _flip(Widget widget) {
    return Transform(
      transform: Matrix4.identity()..rotateY(3.14159),
      alignment: Alignment.center,
      child: widget,
    );
  }
}