import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatbotInput extends StatefulWidget {
  final void Function(String) onSend;
  final FocusNode? focusNode;

  const ChatbotInput({Key? key, required this.onSend, this.focusNode}) : super(key: key);

  @override
  State<ChatbotInput> createState() => _ChatbotInputState();
}

class _ChatbotInputState extends State<ChatbotInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
                hintText: 'chatbot.input_message'.tr()
            ),
            onSubmitted: (_) => _handleSend(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _handleSend,
        ),
      ],
    );
  }
}