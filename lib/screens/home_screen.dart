import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'challenge_screen.dart';
import 'course_detail_screen.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTab});
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final daily = s.dailyChallenge;
    final next = s.nextLesson;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeMentor AI'),
        actions: const [LangToggle()],
      ),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.name.isEmpty
                    ? s.t(const T('Hello, learner! 👋', 'नमस्ते, शिक्षार्थी! 👋'))
                    : '${s.t(const T('Hello', 'नमस्ते'))}, ${s.name}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(s.t(const T('Learn to code, practise MCQs and ace your interviews.',
                  'कोडिंग सीखें, MCQ का अभ्यास करें और इंटरव्यू में सफल हों।'))),
              const SizedBox(height: 16),
              Row(
                children: [
                  StatChip(icon: Icons.local_fire_department, color: Colors.orange, value: '${s.streak}', label: s.t(const T('Day streak', 'दिन की स्ट्रीक'))),
                  const SizedBox(width: 10),
                  StatChip(icon: Icons.bolt, color: Colors.amber.shade700, value: '${s.xp}', label: 'XP'),
                  const SizedBox(width: 10),
                  StatChip(icon: Icons.military_tech, color: cs.primary, value: '${s.level}', label: s.t(const T('Level', 'लेवल'))),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: s.dailyComplete ? cs.secondaryContainer : cs.primaryContainer,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChallengeScreen(challenge: daily, daily: true)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(s.dailyComplete ? Icons.check_circle : Icons.today, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.t(const T('Daily challenge', 'आज की चुनौती')),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text(s.dailyComplete
                                  ? s.t(const T('Completed - come back tomorrow!', 'पूरी हुई - कल फिर आइए!'))
                                  : '${s.t(daily.title)}  •  +20 XP'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              if (next != null) ...[
                SectionTitle(s.t(const T('Continue learning', 'सीखना जारी रखें'))),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: next.course.color.withValues(alpha: 0.15),
                      child: Icon(next.course.icon, color: next.course.color),
                    ),
                    title: Text(s.t(next.lesson.title)),
                    subtitle: Text(next.course.name),
                    trailing: const Icon(Icons.play_circle_fill),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LessonScreen(course: next.course, lesson: next.lesson)),
                    ),
                  ),
                ),
              ],
              SectionTitle(
                s.t(const T('Courses', 'कोर्स')),
                trailing: TextButton(onPressed: () => onTab(1), child: Text(s.t(const T('See all', 'सभी देखें')))),
              ),
              for (final c in courses) ...[
                CourseCard(
                  course: c,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SectionTitle(s.t(const T('Get interview ready', 'इंटरव्यू के लिए तैयार हों'))),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onTab(3),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(s.t(const T('AI interview', 'AI इंटरव्यू'))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onTab(2),
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(s.t(const T('Practice', 'अभ्यास'))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
