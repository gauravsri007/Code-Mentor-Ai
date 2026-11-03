import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../services/interview_session.dart';
import '../widgets/common.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  Course _course = courses.first;
  int _level = 0;
  InterviewSession? _session;
  bool _recorded = false;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _session?.removeListener(_onUpdate);
    _session?.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onUpdate() {
    final s = _session;
    if (s != null && s.finished && !_recorded) {
      _recorded = true;
      context.read<AppState>().recordInterview(score: s.offline && s.scores.isNotEmpty ? s.average : null);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _begin() {
    final session = InterviewSession(
      ai: context.read<AiService>(),
      course: _course,
      level: _level,
      hindi: context.read<AppState>().hindi,
    )..addListener(_onUpdate);
    setState(() => _session = session);
    session.start();
  }

  void _send() {
    final text = _input.text;
    _input.clear();
    _session?.send(text);
  }

  Future<void> _confirmEnd() async {
    final s = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t(const T('End interview?', 'इंटरव्यू समाप्त करें?'))),
        content: Text(s.t(const T('You will get your feedback now.', 'आपको अभी फ़ीडबैक मिलेगा।'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.t(const T('Cancel', 'रद्द करें')))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.t(const T('End', 'समाप्त')))),
        ],
      ),
    );
    if (ok == true) _session?.endNow();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t(const T('AI mock interview', 'AI मॉक इंटरव्यू'))),
        actions: [
          if (session != null && !session.finished)
            TextButton(onPressed: _confirmEnd, child: Text(s.t(const T('End', 'समाप्त')))),
        ],
      ),
      body: SafeArea(
        child: Body(child: session == null ? _setup(context, s) : _chat(context, s, session)),
      ),
    );
  }

  Widget _setup(BuildContext context, AppState s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.t(const T('Choose a topic', 'विषय चुनें')), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in courses)
            ChoiceChip(
              avatar: Icon(c.icon, size: 18, color: c.color),
              label: Text(c.name),
              selected: _course == c,
              onSelected: (_) => setState(() => _course = c),
            ),
        ]),
        const SizedBox(height: 16),
        Text(s.t(const T('Difficulty', 'कठिनाई')), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [for (var i = 0; i < levelNames.length; i++) ButtonSegment(value: i, label: Text(s.t(levelNames[i])))],
          selected: {_level},
          onSelectionChanged: (v) => setState(() => _level = v.first),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _begin,
          icon: const Icon(Icons.play_arrow),
          label: Text(s.t(const T('Start interview', 'इंटरव्यू शुरू करें'))),
        ),
      ],
    );
  }

  Widget _chat(BuildContext context, AppState s, InterviewSession session) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: session.messages.length + (session.busy ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == session.messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final m = session.messages[i];
                return Align(
                  alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
                    decoration: BoxDecoration(
                      color: m.fromUser ? cs.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(
                      m.text,
                      style: TextStyle(color: m.fromUser ? cs.onPrimary : cs.onSurface, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          if (session.finished)
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(s.t(const T('Finish', 'समाप्त'))),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: s.t(const T('Type your answer…', 'अपना उत्तर लिखें…')),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: s.t(const T('Send', 'भेजें')),
                  onPressed: session.busy ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
