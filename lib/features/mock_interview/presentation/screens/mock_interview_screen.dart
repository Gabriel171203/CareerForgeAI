import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/ai/gemini_service.dart';
import '../../../../../services/database/career_repository.dart';
import '../../../../../services/auth/firebase_auth_service.dart';
import '../../../../../core/models/career_profile.dart';


class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  ChatSession? _session;
  String _currentSessionId = '';

  @override
  void initState( ) {
    super.initState();
    Future.microtask(() => _initializeSessions());
  }

  Future<void> _initializeSessions() async {
    final sessions = await ref.read(interviewSessionsProvider.future);
    if (sessions.isNotEmpty) {
      _loadSession(sessions.first['id']);
    } else {
      _startNewSession();
    }
  }

  Future<void> _startNewSession() async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    final userProfile = ref.read(userProfileProvider).value;
    final role = userProfile?.interest ?? 'Professional';
    
    setState(() => _isLoading = true);

    final sessionId = await ref.read(careerRepositoryProvider).createNewSession(
      userId, 
      "Interview: $role"
    );
    
    final gemini = ref.read(geminiServiceProvider);
    _session = gemini.startInterviewChatWithHistory(role, [], 
      skills: userProfile?.skills, 
      experience: userProfile?.experienceLevel
    );

    final greeting = await gemini.sendInterviewMessage(_session!, "Introduce yourself and start the interview.");
    await ref.read(careerRepositoryProvider).saveMessage(userId, sessionId, text: greeting, isUser: false);

    if (mounted) {
      setState(() {
        _currentSessionId = sessionId;
        _isLoading = false;
      });
      ref.read(selectedSessionIdProvider.notifier).state = sessionId;
    }
  }

  Future<void> _loadSession(String sessionId) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    final userProfile = ref.read(userProfileProvider).value;
    final role = userProfile?.interest ?? 'Professional';
    
    final gemini = ref.read(geminiServiceProvider);
    
    // Fetch history context
    final historyData = await ref.read(careerRepositoryProvider).getMessagesStream(userId, sessionId).first;
    final List<Content> geminiHistory = historyData.reversed.map((m) => Content(
      m['isUser'] ? 'user' : 'model', 
      [TextPart(m['text'] as String)]
    )).toList();

    _session = gemini.startInterviewChatWithHistory(role, geminiHistory, 
      skills: userProfile?.skills, 
      experience: userProfile?.experienceLevel
    );

    setState(() {
      _currentSessionId = sessionId;
    });
    ref.read(selectedSessionIdProvider.notifier).state = sessionId;
  }

  Future<void> _deleteSession(String sessionId) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    await ref.read(careerRepositoryProvider).deleteSession(userId, sessionId);
    
    if (_currentSessionId == sessionId) {
      _initializeSessions();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentSessionId.isEmpty) return;

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    _controller.clear();
    await ref.read(careerRepositoryProvider).saveMessage(userId, _currentSessionId, text: text, isUser: true);
    
    setState(() => _isLoading = true);
    
    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.sendInterviewMessage(_session!, text);

    await ref.read(careerRepositoryProvider).saveMessage(userId, _currentSessionId, text: response, isUser: false);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _finishInterview() async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null || _currentSessionId.isEmpty) return;

    setState(() => _isLoading = true);
    
    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.sendInterviewMessage(_session!, "SELESAI. Berikan ringkasan performa saya selama sesi ini.");
    
    await ref.read(careerRepositoryProvider).saveMessage(userId, _currentSessionId, text: response, isUser: false);
    await ref.read(careerRepositoryProvider).markSessionAsFinished(userId, _currentSessionId);
    
    // Perform deep analysis for the analytics dashboard
    final history = await ref.read(careerRepositoryProvider).getMessagesStream(userId, _currentSessionId).first;
    final analysis = await gemini.analyzeInterviewPerformance(history);
    
    final currentProfile = ref.read(userProfileProvider).value;
    if (currentProfile != null) {
      final scores = Map<String, double>.from(analysis['scores'] ?? currentProfile.analytics);
      final recommendations = await gemini.getCareerRecommendations(scores, currentProfile.interest);

      final updatedProfile = CareerProfile(
        userId: currentProfile.userId,
        interest: currentProfile.interest,
        skills: currentProfile.skills,
        experienceLevel: currentProfile.experienceLevel,
        aiFeedback: analysis['feedback'] ?? response,
        readinessScore: analysis['readinessScore'] ?? currentProfile.readinessScore,
        analytics: scores,
        recommendations: recommendations,
        updatedAt: DateTime.now(),
      );
      await ref.read(careerRepositoryProvider).saveProfile(updatedProfile);
    }


    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interview analysis completed! Check your Dashboard.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedSessionId = ref.watch(selectedSessionIdProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(selectedSessionId));
    final sessionsAsync = ref.watch(interviewSessionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Forge AI Advisor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _currentSessionId.isEmpty ? null : _finishInterview,
            child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, size: 20),
            onPressed: _startNewSession,
          ),
          if (_currentSessionId.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
              onPressed: _showDeleteConfirm,
            ),
        ],
      ),
      drawer: _buildDrawer(sessionsAsync),
      body: Column(
        children: [
          Expanded(
            child: _currentSessionId.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : messagesAsync.when(
                  data: (messages) => ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      final showLoading = _isLoading && (messages.isEmpty || messages.first['isUser'] == true);
                      if (showLoading && index == 0) return _buildLoadingBubble();
                      final msgIndex = showLoading ? index - 1 : index;
                      final msg = messages[msgIndex];
                      return _buildChatBubble(msg['text'], msg['isUser']).animate().fadeIn();
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDrawer(AsyncValue<List<Map<String, dynamic>>> sessionsAsync) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            color: theme.colorScheme.primary.withOpacity(0.05),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(LucideIcons.history, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text('Interview History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final isSelected = session['id'] == _currentSessionId;
                  final isFinished = session['isFinished'] ?? false;
                  final date = (session['timestamp'] as Timestamp?)?.toDate();
                  final dateStr = date != null ? DateFormat('MMM d, HH:mm').format(date) : 'Just now';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        isFinished ? LucideIcons.checkCircle2 : LucideIcons.messageCircle,
                        color: isFinished ? Colors.green : (isSelected ? theme.colorScheme.primary : Colors.grey),
                        size: 20,
                      ),
                      title: Text(
                        session['title'], 
                        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14),
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                      subtitle: Text(dateStr, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      trailing: isFinished 
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Checked', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        : null,
                      onTap: () {
                        Navigator.pop(context);
                        _loadSession(session['id']);
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Failed to load history')),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('Are you sure you want to delete this interview history permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSession(_currentSessionId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
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
                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: isUser 
                ? Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary))
                : MarkdownBody(
                    data: text,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Forge is thinking...', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer();
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Talk to Forge...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            onPressed: _isLoading || _currentSessionId.isEmpty ? null : _sendMessage,
            icon: const Icon(LucideIcons.send),
          ),
        ],
      ),
    );
  }
}
