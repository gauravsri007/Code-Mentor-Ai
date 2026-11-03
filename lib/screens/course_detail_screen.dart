import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'certificate_screen.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final eligible = s.certificateEligible(course);
    final hasCert = s.certs.containsKey(course.id);
    return Scaffold(
      appBar: AppBar(title: Text(course.name), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: course.color.withValues(alpha: 0.15),
                  child: Icon(course.icon, color: course.color, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(s.t(course.tagline), style: Theme.of(context).textTheme.titleMedium)),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: s.progress(course), minHeight: 8, color: course.color),
              ),
              const SizedBox(height: 6),
              Text('${s.completedIn(course)}/${course.lessons.length} ${s.t(const T('lessons completed', 'पाठ पूरे'))}'),
              SectionTitle(s.t(const T('Lessons', 'पाठ'))),
              for (var i = 0; i < course.lessons.length; i++) ...[
                _LessonTile(course: course, lesson: course.lessons[i], index: i),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.quiz_outlined),
                label: Text(s.t(const T('Course quiz (random mix)', 'कोर्स क्विज़ (मिश्रित)'))),
                onPressed: () {
                  final qs = List.of(course.allQuestions)..shuffle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        title: '${course.name} quiz',
                        questions: qs.take(6).toList(),
                        onFinished: (c, t) => context.read<AppState>().recordPracticeQuiz(c),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.workspace_premium),
                label: Text(hasCert
                    ? s.t(const T('View certificate', 'सर्टिफ़िकेट देखें'))
                    : eligible
                        ? s.t(const T('Claim your certificate', 'अपना सर्टिफ़िकेट लें'))
                        : s.t(const T('Pass every lesson quiz to unlock certificate', 'सर्टिफ़िकेट के लिए हर पाठ का क्विज़ पास करें'))),
                onPressed: (hasCert || eligible)
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CertificateScreen(course: course)),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.course, required this.lesson, required this.index});
  final Course course;
  final Lesson lesson;
  final int index;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final done = s.lessons.contains(lesson.id);
    final best = s.quizBest[lesson.id];
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: done ? Colors.green : course.color.withValues(alpha: 0.15),
          child: done ? const Icon(Icons.check, color: Colors.white) : Text('${index + 1}'),
        ),
        title: Text(s.t(lesson.title)),
        subtitle: Text(best == null ? s.t(const T('Quiz not taken', 'क्विज़ नहीं दिया')) : '${s.t(const T('Best quiz score', 'सर्वश्रेष्ठ क्विज़ स्कोर'))}: $best%'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonScreen(course: course, lesson: lesson)),
        ),
      ),
    );
  }
}
