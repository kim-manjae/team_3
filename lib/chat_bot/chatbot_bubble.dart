import 'package:flutter/material.dart';
import 'chatbot_message.dart';

typedef ActionCallback = void Function(String action);

class ChatbotBubble extends StatelessWidget {
  final ChatbotMessage message;
  final ActionCallback? onAction;

  const ChatbotBubble({Key? key, required this.message, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[200] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );

    if (message.action != null && !isUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bubble,
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: ElevatedButton(
              onPressed: () => onAction?.call(message.action!),
              child: Text(_getActionButtonText(message.action!)),
            ),
          ),
        ],
      );
    }
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }

  String _getActionButtonText(String action) {
    switch (action) {
      case 'hospital':
        return '내 주변 병원 찾기';
      case 'pharmacy':
        return '내 주변 약국 찾기';
      case 'emergency':
        return '응급의료기관 찾기';
      case 'reservation':
        return '병원 예약하기';
      default:
        return '이동';
    }
  }
}