import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';

class AiQuestionsScreen extends StatefulWidget {
  const AiQuestionsScreen({super.key});

  @override
  State<AiQuestionsScreen> createState() => _AiQuestionsScreenState();
}

class _AiQuestionsScreenState extends State<AiQuestionsScreen> {
  Course _course = courses.first;
  int _level = 0;
  bool _loading = false;
  QuestionSet? _result;

  Future<void> _generate() async {
    final ai = context.read<AiService>();
    final hindi = context.read<AppState>().hindi;
    setState(() => _loading = true);
    final r = await ai.generateQuestions(course: _course, level: _level, hindi: hindi);
    if (!mounted) return;
    setState(() {
      _result = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('AI interview questions', 'AI इंटरव्यू प्रश्न'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.t(const T('Topic', 'विषय')), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in courses)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.name),
                    selected: _course == c,
                    onSelected: (_) => setState(() => _course = c),
                  ),
              ]),
              const SizedBox(height: 14),
              Text(s.t(const T('Level', 'स्तर')), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                segments: [
                  for (var i = 0; i < levelNames.length; i++)
                    ButtonSegment(value: i, label: Text(s.t(levelNames[i]))),
                ],
                selected: {_level},
                onSelectionChanged: (v) => setState(() => _level = v.first),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(s.t(const T('Generate questions', 'प्रश्न बनाएँ'))),
              ),
              if (result != null) ...[
                if (result.offline)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      result.note ?? s.t(const T('Showing the built-in question bank (offline mode).', 'अंतर्निहित प्रश्न-बैंक दिखाया जा रहा है (ऑफ़लाइन मोड)।')),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                SectionTitle('${_course.name} • ${s.t(levelNames[_level])}'),
                for (var i = 0; i < result.items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text('${i + 1}. ${result.items[i].question}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Text(s.t(const T('Model answer', 'आदर्श उत्तर')), style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 4),
                          SelectableText(result.items[i].answer),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
