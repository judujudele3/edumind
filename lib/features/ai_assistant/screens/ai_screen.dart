import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../../subjects/providers/subject_provider.dart';
import 'qcm_screen.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedSubject = 'Général';
  String _conceptController_text = '';
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    setState(() => _isThinking = true);
    await ref
        .read(aiChatProvider.notifier)
        .sendMessage(text, _selectedSubject);
    setState(() => _isThinking = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    final subjects = ['Général', ...subjectsAsync.maybeWhen<List<String>>(
      data: (list) => list.map<String>((s) => s.name).toList(),
      orElse: () => [],
    )];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF9800),
          labelColor: const Color(0xFFFF9800),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.chat_outlined), text: 'Chat'),
            Tab(icon: Icon(Icons.lightbulb_outlined), text: 'Expliquer'),
            Tab(icon: Icon(Icons.quiz_outlined), text: 'QCM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 — Chat
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Matière',
                    prefixIcon: Icon(Icons.book_outlined),
                    isDense: true,
                  ),
                  items: subjects
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSubject = v!),
                ),
              ),
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.psychology_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Pose une question !',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _ChatBubble(message: msg);
                        },
                      ),
              ),
              if (_isThinking)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('EduMind réfléchit...',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Pose ta question...',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9800),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tab 2 — Expliquer un concept
          _ExplainTab(subjects: subjects),

          // Tab 3 — QCM
          _QcmTab(subjects: subjects),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFF9800) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ExplainTab extends ConsumerStatefulWidget {
  final List<String> subjects;
  const _ExplainTab({required this.subjects});

  @override
  ConsumerState<_ExplainTab> createState() => _ExplainTabState();
}

class _ExplainTabState extends ConsumerState<_ExplainTab> {
  final _conceptController = TextEditingController();
  String _selectedSubject = 'Général';
  String _result = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _explain() async {
    if (_conceptController.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _result = '';
    });
    try {
      final response = await ref
          .read(geminiServiceProvider)
          .explainConcept(_conceptController.text.trim(), _selectedSubject);
      setState(() => _result = response);
    } catch (e) {
      setState(() => _result = 'Erreur : $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Matière',
              prefixIcon: Icon(Icons.book_outlined),
            ),
            items: widget.subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedSubject = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _conceptController,
            decoration: const InputDecoration(
              labelText: 'Concept à expliquer',
              prefixIcon: Icon(Icons.lightbulb_outlined),
              hintText: 'Ex: La dérivée, Les pointeurs, La photosynthèse...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _explain,
              icon: const Icon(Icons.auto_awesome),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Expliquer'),
            ),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _result,
                style: const TextStyle(height: 1.6, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QcmTab extends ConsumerStatefulWidget {
  final List<String> subjects;
  const _QcmTab({required this.subjects});

  @override
  ConsumerState<_QcmTab> createState() => _QcmTabState();
}

class _QcmTabState extends ConsumerState<_QcmTab> {
  final _topicController = TextEditingController();
  String _selectedSubject = 'Général';
  int _questionCount = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQCM() async {
    if (_topicController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final questions = await ref
          .read(geminiServiceProvider)
          .generateQCM(
            _selectedSubject,
            _topicController.text.trim(),
            _questionCount,
          );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QcmScreen(questions: questions),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Matière',
              prefixIcon: Icon(Icons.book_outlined),
            ),
            items: widget.subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedSubject = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'Sujet du QCM',
              prefixIcon: Icon(Icons.quiz_outlined),
              hintText: 'Ex: Les intégrales, La POO, Les réseaux...',
            ),
          ),
          const SizedBox(height: 24),
          Text('Nombre de questions : $_questionCount',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          Slider(
            value: _questionCount.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            activeColor: const Color(0xFFFF9800),
            label: _questionCount.toString(),
            onChanged: (v) =>
                setState(() => _questionCount = v.toInt()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateQCM,
              icon: const Icon(Icons.auto_awesome),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Générer le QCM'),
            ),
          ),
        ],
      ),
    );
  }
}