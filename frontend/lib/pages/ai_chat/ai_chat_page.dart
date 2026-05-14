import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../interview/mock_interview_page.dart';
import 'quiz_page.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initSession(null);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();
    context.read<ChatProvider>().sendMessage(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _quickNote() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('快速记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: '输入学习内容...'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final text = _noteCtrl.text.trim();
                  if (text.isEmpty) return;
                  final result = await context.read<NoteProvider>().createNote(text);
                  _noteCtrl.clear();
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('笔记已创建，AI 正在总结...')),
                    );
                  }
                },
                child: const Text('提交'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'AI 测验',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage())),
          ),
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: '模拟面试',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewPage())),
          ),
          IconButton(icon: const Icon(Icons.add_comment_outlined), tooltip: '快速记录', onPressed: _quickNote),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: '清空对话',
            onPressed: () => context.read<ChatProvider>().clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 64, color: AppTheme.textSecondary),
                        SizedBox(height: 16),
                        Text('开始 AI 对话', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('输入学习内容，AI 帮你总结、出题、解释代码',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: chat.messages[index]);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(top: BorderSide(color: AppTheme.cardColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(hintText: '输入消息...'),
                      maxLines: 3,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send_rounded, color: AppTheme.accentColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}