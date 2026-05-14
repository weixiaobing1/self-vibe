import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/theme.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.accentColor.withValues(alpha: 0.3) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: _buildContent(isUser),
      ),
    );
  }

  Widget _buildContent(bool isUser) {
    if (message.isStreaming && message.content.isEmpty) {
      return SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor));
    }

    if (isUser) {
      return Text(
        message.content,
        style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.5),
      );
    }

    return MarkdownBody(
      data: message.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.6),
        code: TextStyle(
          fontSize: 13,
          color: AppTheme.textPrimary,
          backgroundColor: AppTheme.accentColor.withValues(alpha: 0.15),
        ),
        codeblockDecoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.08),
          border: Border(left: BorderSide(color: AppTheme.accentColor, width: 3)),
        ),
      ),
    );
  }
}