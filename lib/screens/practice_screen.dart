import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/challenges_data.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'challenge_screen.dart';
import 'quiz_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('Practice', 'अभ्यास'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionTitle(s.t(const T('MCQ quizzes', 'MCQ क्विज़'))),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in courses)
                    ActionChip(
                      avatar: Icon(c.icon, size: 18, color: c.color),
                      label: Text('${c.name} (${c.allQuestions.length})'),
                      onPressed: () {
                        final qs = List.of(c.allQuestions)..shuffle();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              title: '${c.name} quiz',
                              questions: qs.take(8).toList(),
                              onFinished: (correct, _) => context.read<AppState>().recordPracticeQuiz(correct),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              SectionTitle(s.t(const T('Coding challenges', 'कोडिंग चुनौतियाँ'))),
              for (final ch in allChallenges)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: courseById(ch.courseId).color.withValues(alpha: 0.15),
                        child: Icon(courseById(ch.courseId).icon, color: courseById(ch.courseId).color),
                      ),
                      title: Text(s.t(ch.title)),
                      subtitle: Text('${courseById(ch.courseId).name}  •  +${ch.xp} XP'),
                      trailing: s.solved.contains(ch.id)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChallengeScreen(challenge: ch)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
