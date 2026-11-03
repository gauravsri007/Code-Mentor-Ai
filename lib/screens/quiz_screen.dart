import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';

/// Generic multiple-choice quiz. [onFinished] is called once with (correct, total).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.title, required this.questions, this.onFinished});
  final String title;
  final List<Mcq> questions;
  final void Function(int correct, int total)? onFinished;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _picked;
  late final List<int?> _answers = List.filled(widget.questions.length, null);
  bool _finished = false;

  int get _correct {
    var n = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      if (_answers[i] == widget.questions[i].answer) n++;
    }
    return n;
  }

  void _next() {
    if (_picked == null) return;
    _answers[_index] = _picked;
    if (_index == widget.questions.length - 1) {
      widget.onFinished?.call(_correct, widget.questions.length);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _picked = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: widget.questions.isEmpty
              ? Center(child: Text(s.t(const T('No questions yet.', 'अभी कोई प्रश्न नहीं।'))))
              : _finished
                  ? _results(context, s)
                  : _question(context, s),
        ),
      ),
    );
  }

  Widget _question(BuildContext context, AppState s) {
    final q = widget.questions[_index];
    final cs = Theme.of(context).colorScheme;
    final revealed = _picked != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: (_index + 1) / widget.questions.length, minHeight: 6),
        const SizedBox(height: 8),
        Text('${s.t(const T('Question', 'प्रश्न'))} ${_index + 1}/${widget.questions.length}',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(s.t(q.question), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              button: true,
              selected: _picked == i,
              label: q.options[i],
              excludeSemantics: true,
              child: Card(
                margin: EdgeInsets.zero,
                color: !revealed
                    ? null
                    : i == q.answer
                        ? Colors.green.withValues(alpha: 0.18)
                        : (i == _picked ? Colors.red.withValues(alpha: 0.18) : null),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: revealed ? null : () => setState(() => _picked = i),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 14, child: Text(String.fromCharCode(65 + i))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[i], style: const TextStyle(fontSize: 16))),
                        if (revealed && i == q.answer) const Icon(Icons.check_circle, color: Colors.green),
                        if (revealed && i == _picked && i != q.answer) const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (revealed) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
            child: Text(s.t(q.explanation)),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton(
          onPressed: revealed ? _next : null,
          child: Text(_index == widget.questions.length - 1
              ? s.t(const T('Finish', 'समाप्त'))
              : s.t(const T('Next', 'आगे'))),
        ),
      ],
    );
  }

  Widget _results(BuildContext context, AppState s) {
    final total = widget.questions.length;
    final pct = (_correct * 100 / total).round();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),
        Icon(pct >= AppState.passMark ? Icons.emoji_events : Icons.refresh,
            size: 72, color: pct >= AppState.passMark ? Colors.amber : Colors.grey),
        const SizedBox(height: 8),
        Center(child: Text('$_correct / $total  ($pct%)', style: Theme.of(context).textTheme.headlineMedium)),
        Center(
          child: Text(pct >= AppState.passMark
              ? s.t(const T('Well done!', 'शाबाश!'))
              : s.t(const T('Review the lesson and try again.', 'पाठ दोहराएँ और फिर कोशिश करें।'))),
        ),
        SectionTitle(s.t(const T('Review', 'समीक्षा'))),
        for (var i = 0; i < total; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                _answers[i] == widget.questions[i].answer ? Icons.check_circle : Icons.cancel,
                color: _answers[i] == widget.questions[i].answer ? Colors.green : Colors.red,
              ),
              title: Text(s.t(widget.questions[i].question)),
              subtitle: Text('${s.t(const T('Answer', 'उत्तर'))}: ${widget.questions[i].options[widget.questions[i].answer]}'),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(s.t(const T('Done', 'ठीक है')))),
      ],
    );
  }
}
