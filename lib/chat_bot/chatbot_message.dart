enum ChatSender { user, bot }

class ChatbotMessage {
  final String text;
  final ChatSender sender;
  final String? action; // 'hospital', 'pharmacy', 'emergency', 'reservation'
  final DateTime timestamp;

  ChatbotMessage({
    required this.text,
    required this.sender,
    this.action,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}