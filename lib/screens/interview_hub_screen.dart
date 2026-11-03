import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'ai_questions_screen.dart';
import 'mock_interview_screen.dart';

class InterviewHubScreen extends StatelessWidget {
  const InterviewHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final ai = context.read<AiService>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('Interview prep', 'इंटरव्यू तैयारी'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ai.online ? Colors.green.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(ai.online ? Icons.cloud_done : Icons.cloud_off),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(ai.online
                        ? s.t(const T('AI server connected: questions are generated live.', 'AI सर्वर जुड़ा है: प्रश्न लाइव बनते हैं।'))
                        : s.t(const T('Offline mode: using the built-in question bank. Connect an AI server for unlimited AI questions.',
                            'ऑफ़लाइन मोड: अंतर्निहित प्रश्न-बैंक इस्तेमाल हो रहा है। असीमित AI प्रश्नों के लिए AI सर्वर जोड़ें।'))),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              _HubCard(
                icon: Icons.auto_awesome,
                title: s.t(const T('AI interview questions', 'AI इंटरव्यू प्रश्न')),
                subtitle: s.t(const T('Generate questions with model answers by topic and level.',
                    'विषय और स्तर के अनुसार आदर्श उत्तरों सहित प्रश्न बनाएँ।')),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiQuestionsScreen())),
              ),
              const SizedBox(height: 12),
              _HubCard(
                icon: Icons.record_voice_over,
                title: s.t(const T('AI mock interview', 'AI मॉक इंटरव्यू')),
                subtitle: s.t(const T('A 5-question interview with feedback and a score.',
                    'फ़ीडबैक और स्कोर के साथ 5 प्रश्नों का इंटरव्यू।')),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewScreen())),
              ),
              if (s.interviewScores.isNotEmpty) ...[
                SectionTitle(s.t(const T('Recent scores', 'हाल के स्कोर'))),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final sc in s.interviewScores.reversed.take(8)) Chip(label: Text('$sc/100')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: cs.primaryContainer, child: Icon(icon, color: cs.primary, size: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
