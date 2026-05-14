import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../config/theme.dart';
import '../../providers/mock_interview_provider.dart';

class MockInterviewPage extends StatefulWidget {
  const MockInterviewPage({super.key});

  @override
  State<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends State<MockInterviewPage> {
  final _topicCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _levels = ['初级', '中级', '高级'];

  @override
  void dispose() {
    _topicCtrl.dispose();
    _answerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MockInterviewProvider>(
      builder: (context, mi, _) {
        if (!mi.hasStarted) {
          return _buildSetupScreen(mi);
        }
        return _buildInterviewScreen(mi);
      },
    );
  }

  Widget _buildSetupScreen(MockInterviewProvider mi) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 模拟面试')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.school_outlined, size: 40, color: AppTheme.accentColor),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text('AI 模拟面试', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ),
            SizedBox(height: 8),
            Center(
              child: Text('AI 扮演专业面试官，模拟真实面试场景\n涵盖基础概念、原理理解和实际应用',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
            ),
            SizedBox(height: 32),

            Text('面试方向', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 8),
            TextField(
              controller: _topicCtrl,
              decoration: const InputDecoration(
                hintText: '如：Java 后端开发、React 前端、Python 数据分析',
              ),
              onChanged: (v) => mi.setTopic(v),
            ),
            const SizedBox(height: 20),

            Text('难度等级', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 8),
            Row(
              children: _levels.map((lvl) {
                final isSelected = mi.level == lvl;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(lvl),
                    selected: isSelected,
                    onSelected: (_) => mi.setLevel(lvl),
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: mi.topic.trim().isEmpty ? null : () => mi.startInterview().then((_) => _scrollToBottom()),
                icon: const Icon(Icons.play_arrow, size: 22),
                label: const Text('开始面试', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewScreen(MockInterviewProvider mi) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${mi.topic} · ${mi.level}'),
        actions: [
          TextButton.icon(
            onPressed: mi.isLoading ? null : () => mi.endInterview().then((_) => _scrollToBottom()),
            icon: Icon(Icons.stop_circle_outlined, color: AppTheme.error),
            label: Text('结束面试', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: mi.messages.length,
              itemBuilder: (context, index) {
                final msg = mi.messages[index];
                final isUser = msg.role == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8, top: 4),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                            child: Icon(Icons.school, size: 16, color: AppTheme.accentColor),
                          ),
                        ),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.accentColor.withValues(alpha: 0.3) : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: isUser
                              ? Text(msg.content, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14))
                              : MarkdownBody(
                                  data: msg.content.isEmpty ? '...' : msg.content,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
                                    strong: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                                    code: TextStyle(color: AppTheme.accentColor, backgroundColor: AppTheme.surfaceColor, fontSize: 13),
                                    codeblockDecoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    h2: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (mi.isLoading)
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor)),
                  SizedBox(width: 8),
                  Text('AI 思考中...', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          _buildInputBar(mi),
        ],
      ),
    );
  }

  Widget _buildInputBar(MockInterviewProvider mi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.cardColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerCtrl,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: '输入你的回答...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              enabled: !mi.isLoading,
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: mi.isLoading
                ? null
                : () {
                    final text = _answerCtrl.text.trim();
                    if (text.isEmpty) return;
                    _answerCtrl.clear();
                    mi.sendAnswer(text).then((_) => _scrollToBottom());
                  },
            icon: Icon(Icons.send, color: AppTheme.accentColor),
          ),
        ],
      ),
    );
  }
}