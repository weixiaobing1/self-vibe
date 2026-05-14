class ChatMessage {
  final String role; // 'user' or 'assistant'
  String content;
  bool isStreaming;

  ChatMessage({required this.role, required this.content, this.isStreaming = false});
}