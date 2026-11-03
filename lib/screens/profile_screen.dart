import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'certificate_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: context.read<AppState>().name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final s = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t(const T('Reset all progress?', 'सारी प्रगति रीसेट करें?'))),
        content: Text(s.t(const T('XP, streak, quiz scores and certificates will be deleted.', 'XP, स्ट्रीक, क्विज़ स्कोर और सर्टिफ़िकेट हट जाएँगे।'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.t(const T('Cancel', 'रद्द करें')))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t(const T('Reset', 'रीसेट'))),
          ),
        ],
      ),
    );
    if (ok == true) {
      await s.reset();
      _name.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final ai = context.read<AiService>();
    final cs = Theme.of(context).colorScheme;
    final totalLessons = courses.fold<int>(0, (a, c) => a + c.lessons.length);
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('Profile & progress', 'प्रोफ़ाइल और प्रगति'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: s.t(const T('Your name (used on certificates)', 'आपका नाम (सर्टिफ़िकेट पर)')),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: s.t(const T('Save', 'सहेजें')),
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      s.setName(_name.text);
                    },
                  ),
                ),
                onSubmitted: s.setName,
              ),
              const SizedBox(height: 14),
              Row(children: [
                StatChip(icon: Icons.bolt, color: Colors.amber.shade700, value: '${s.xp}', label: 'XP'),
                const SizedBox(width: 10),
                StatChip(icon: Icons.local_fire_department, color: Colors.orange, value: '${s.streak}', label: s.t(const T('Day streak', 'दिन की स्ट्रीक'))),
                const SizedBox(width: 10),
                StatChip(icon: Icons.menu_book, color: cs.primary, value: '${s.lessons.length}/$totalLessons', label: s.t(const T('Lessons', 'पाठ'))),
              ]),
              SectionTitle(s.t(const T('Course progress', 'कोर्स प्रगति'))),
              for (final c in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Icon(c.icon, color: c.color),
                    const SizedBox(width: 10),
                    SizedBox(width: 72, child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: s.progress(c), minHeight: 9, color: c.color),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(s.progress(c) * 100).round()}%'),
                  ]),
                ),
              SectionTitle(s.t(const T('Badges', 'बैज'))),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in s.badges)
                    Opacity(
                      opacity: b.earned ? 1 : 0.4,
                      child: Chip(
                        avatar: Icon(b.icon, size: 18, color: b.earned ? Colors.amber.shade800 : null),
                        label: Text(s.t(b.title)),
                      ),
                    ),
                ],
              ),
              SectionTitle(s.t(const T('Certificates', 'सर्टिफ़िकेट'))),
              for (final c in courses)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.workspace_premium,
                        color: s.certs.containsKey(c.id) ? Colors.amber.shade800 : cs.outline),
                    title: Text('${c.name} ${s.t(const T('certificate', 'सर्टिफ़िकेट'))}'),
                    subtitle: Text(s.certs.containsKey(c.id)
                        ? '${s.t(const T('Issued', 'जारी'))}: ${s.certs[c.id]!.date}'
                        : s.certificateEligible(c)
                            ? s.t(const T('Ready to claim', 'पाने के लिए तैयार'))
                            : s.t(const T('Locked', 'लॉक'))),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: s.certs.containsKey(c.id) || s.certificateEligible(c),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(course: c))),
                  ),
                ),
              SectionTitle(s.t(const T('About', 'जानकारी'))),
              ListTile(
                leading: Icon(ai.online ? Icons.cloud_done : Icons.cloud_off),
                title: Text(s.t(const T('AI server', 'AI सर्वर'))),
                subtitle: Text(ai.online ? ai.baseUrl : s.t(const T('Not configured (offline mode)', 'कॉन्फ़िगर नहीं (ऑफ़लाइन मोड)'))),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                onPressed: _confirmReset,
                icon: const Icon(Icons.delete_outline),
                label: Text(s.t(const T('Reset progress', 'प्रगति रीसेट करें'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
