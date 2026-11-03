import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.course, required this.lesson});
  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final done = s.lessons.contains(lesson.id);
    return Scaffold(
      appBar: AppBar(title: Text(course.name), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.t(lesson.title),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Chip(
                avatar: const Icon(Icons.translate, size: 16),
                label: Text(s.hindi ? 'हिन्दी ट्यूटोरियल' : 'English tutorial'),
              ),
              const SizedBox(height: 8),
              SelectableText(s.t(lesson.body), style: const TextStyle(fontSize: 16, height: 1.55)),
              SectionTitle(s.t(const T('Example code', 'उदाहरण कोड'))),
              CodeBlock(lesson.code),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.quiz),
                label: Text(s.t(const T('Take lesson quiz', 'पाठ का क्विज़ दें'))),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      title: s.t(lesson.title),
                      questions: lesson.quiz,
                      onFinished: (c, t) => context.read<AppState>().recordLessonQuiz(lesson.id, c, t),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(done ? Icons.check_circle : Icons.check_circle_outline),
                label: Text(done
                    ? s.t(const T('Completed', 'पूरा हुआ'))
                    : s.t(const T('Mark as read', 'पढ़ा हुआ चिह्नित करें'))),
                onPressed: done ? null : () => context.read<AppState>().completeLesson(lesson.id),
              ),
              const SizedBox(height: 6),
              Text(
                s.t(const T('Passing the quiz (60%+) also counts towards your certificate.',
                    'क्विज़ में 60%+ अंक आपके सर्टिफ़िकेट के लिए गिने जाते हैं।')),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
