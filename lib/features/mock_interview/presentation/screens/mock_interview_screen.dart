import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../../services/ai/gemini_service.dart';
import '../../../../../services/database/career_repository.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  Message(this.text, this.isUser) : timestamp = DateTime.now();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  ChatSession? _session;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initInterview();
      _isInitialized = true;
    }
  }

  Future<void> _initInterview() async {
    final userProfile = ref.read(userProfileProvider).value;
    final role = userProfile?.interest ?? 'Professional';
    
    final gemini = ref.read(geminiServiceProvider);
    _session = gemini.startInterviewChat(role);
    
    setState(() {
      _isLoading = true;
    });

    final response = await gemini.sendInterviewMessage(_session!, "Introduce yourself and start the interview.");
    
    if (mounted) {
      setState(() {
        _messages.add(Message(response, false));
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(Message(text, true));
      _isLoading = true;
    });
    
    _scrollToBottom();

    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.sendInterviewMessage(_session!, text);

    if (mounted) {
      setState(() {
        _messages.add(Message(response, false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _finishInterview() async {
    setState(() => _isLoading = true);
    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.sendInterviewMessage(_session!, "DONE. Give me a summary of my performance.");
    
    if (mounted) {
      setState(() {
        _messages.add(Message(response, false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('AI Interviewer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              userProfile?.interest ?? 'Career Coach',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _finishInterview,
            child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingBubble();
                }
                final msg = _messages[index];
                return _buildChatBubble(msg).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.info, size: 14, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Practice makes perfect. Focus on your achievements.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blue[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Message msg) {
    final isMe = msg.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
              child: Icon(LucideIcons.userCircle, size: 16, color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                border: isMe ? null : Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: isMe 
                ? Text(
                    msg.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      height: 1.5,
                    ),
                  )
                : MarkdownBody(
                    data: msg.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
            ),
          ),
          if (isMe) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return _buildChatBubble(Message('AI is analyzing your answer...', false))
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1.5.seconds, color: Colors.white24);
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Type your response...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(LucideIcons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
