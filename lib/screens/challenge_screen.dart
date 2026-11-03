import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.challenge, this.daily = false});
  final Challenge challenge;
  final bool daily;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _controller = TextEditingController();
  bool _showHint = false;
  bool? _correct;
  bool _reviewing = false;
  String? _review;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final state = context.read<AppState>();
    final ok = widget.challenge.accepts(_controller.text);
    setState(() => _correct = ok);
    if (ok) {
      state.solveChallenge(widget.challenge);
      if (widget.daily) state.completeDaily();
    }
  }

  Future<void> _askAi() async {
    final state = context.read<AppState>();
    final ai = context.read<AiService>();
    setState(() {
      _reviewing = true;
      _review = null;
    });
    String text;
    try {
      text = await ai.reviewCode(
        course: courseById(widget.challenge.courseId),
        task: widget.challenge.prompt.en,
        code: _controller.text,
        hindi: state.hindi,
      );
    } catch (_) {
      text = state.t(const T('Could not reach the AI server.', 'AI सर्वर तक नहीं पहुँच सके।'));
    }
    if (mounted) {
      setState(() {
        _reviewing = false;
        _review = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final ch = widget.challenge;
    final course = courseById(ch.courseId);
    final alreadySolved = s.solved.contains(ch.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.daily ? s.t(const T('Daily challenge', 'आज की चुनौती')) : s.t(ch.title)),
        actions: const [LangToggle()],
      ),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Icon(course.icon, color: course.color),
                const SizedBox(width: 8),
                Text(course.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Chip(label: Text('+${ch.xp} XP')),
              ]),
              const SizedBox(height: 8),
              Text(s.t(ch.prompt), style: const TextStyle(fontSize: 17, height: 1.5)),
              if (ch.starter.isNotEmpty) ...[
                const SizedBox(height: 12),
                CodeBlock(ch.starter),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 6,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: s.t(const T('Your answer', 'आपका उत्तर')),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _correct = null),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _controller.text.trim().isEmpty ? null : _check,
                icon: const Icon(Icons.check),
                label: Text(s.t(const T('Check answer', 'उत्तर जाँचें'))),
              ),
              if (_correct != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_correct! ? Colors.green : Colors.red).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(_correct! ? Icons.check_circle : Icons.cancel, color: _correct! ? Colors.green : Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_correct!
                          ? (alreadySolved
                              ? s.t(const T('Correct!', 'सही!'))
                              : s.t(const T('Correct! XP added.', 'सही! XP जुड़ गए।')))
                          : s.t(const T('Not quite - try again or use the hint.', 'सही नहीं - फिर कोशिश करें या संकेत देखें।'))),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showHint = true),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(s.t(const T('Hint', 'संकेत'))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reviewing ? null : _askAi,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(s.t(const T('Ask AI', 'AI से पूछें'))),
                  ),
                ),
              ]),
              if (_showHint) ...[
                const SizedBox(height: 12),
                Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(14), child: Text(s.t(ch.hint)))),
              ],
              if (_reviewing) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
              if (_review != null) ...[
                const SizedBox(height: 12),
                Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(14), child: SelectableText(_review!))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
