import 'package:eng_card/widgets/open_ai_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final service = OpenAIService();
    setState(() => _isLoading = true);
    final reply = await service.sendMessage(_controller.text);
    setState(() {
      _response = reply;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('English AI Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  labelText: 'Ask something in English...'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              child: const Text('Send'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _response,
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
