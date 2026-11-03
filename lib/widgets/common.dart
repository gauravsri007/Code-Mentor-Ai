import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';

/// Switches the whole app between English and Hindi.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Tooltip(
      message: s.t(const T('Switch language', 'भाषा बदलें')),
      child: TextButton.icon(
        onPressed: s.toggleLang,
        icon: const Icon(Icons.translate, size: 20),
        label: Text(s.hindi ? 'English' : 'हिन्दी'),
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 16, 48, 16),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              tooltip: 'Copy code',
              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Copied')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$value $label',
        excludeSemantics: true,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Row(children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});
  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.progress(course);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: course.color.withValues(alpha: 0.15),
                child: Icon(course.icon, color: course.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(s.t(course.tagline),
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: p, minHeight: 7, color: course.color),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('${(p * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a centred column on wide screens.
class Body extends StatelessWidget {
  const Body({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: child),
      );
}
