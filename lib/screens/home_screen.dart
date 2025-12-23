import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isInitialScreen = true;
  late GenerativeModel model;
  ChatSession? chat;
  // Initialize the Gemini Developer API backend service
  // Create a `GenerativeModel` instance with a model that supports your use case

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeModel();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite');
    chat = model.startChat();
    if (mounted) setState(() {});
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || chat == null) return;

    final userMessage = text.trim();
    _textController.clear();

    setState(() {
      _isInitialScreen = false;
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });

    // Safe scroll after user message (with post-frame callback)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    try {
      final prompt = Content.text(userMessage);
      final response = await chat!.sendMessage(prompt);
      final aiResponse = response.text ?? 'No response';

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUser: false));
        });

        // Safe scroll after AI response
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        title: const Text(
          'ChatGPT',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _isInitialScreen ? _buildInitialScreen() : _buildChatList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInitialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            'What can I help with?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip(icon: Icons.bar_chart, label: 'Analyze data', color: const Color(0xFF10A37F)),
              _buildSuggestionChip(icon: Icons.description_outlined, label: 'Summarize text', color: const Color(0xFFFF6B35)),
              _buildSuggestionChip(icon: Icons.code, label: 'Code', color: const Color(0xFF8B5CF6)),
              _buildSuggestionChip(icon: Icons.more_horiz, label: 'More', color: Colors.grey.shade400),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip({required IconData icon, required String label, required Color color}) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _messages[index];
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add, size: 28), onPressed: () {}, color: Colors.grey.shade700),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Ask ChatGPT',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.mic_none, size: 24), onPressed: () {}, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade700, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({Key? key, required this.text, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: .end,
        children: [
          if (isUser) const Spacer(),
          if (isUser)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFECECF1), borderRadius: BorderRadius.circular(18)),
                child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.5)),
                  const SizedBox(height: 12),
                  Row(children: [_buildActionButton(Icons.copy_outlined), const SizedBox(width: 12), _buildActionButton(Icons.refresh)]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade700),
    );
  }
}
