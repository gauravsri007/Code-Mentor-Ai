import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import 'courses_screen.dart';
import 'home_screen.dart';
import 'interview_hub_screen.dart';
import 'practice_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onTab: (i) => setState(() => _index = i)),
          const CoursesScreen(),
          const PracticeScreen(),
          const InterviewHubScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: s.t(const T('Home', 'होम'))),
          NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: s.t(const T('Courses', 'कोर्स'))),
          NavigationDestination(
              icon: const Icon(Icons.extension_outlined),
              selectedIcon: const Icon(Icons.extension),
              label: s.t(const T('Practice', 'अभ्यास'))),
          NavigationDestination(
              icon: const Icon(Icons.record_voice_over_outlined),
              selectedIcon: const Icon(Icons.record_voice_over),
              label: s.t(const T('Interview', 'इंटरव्यू'))),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: s.t(const T('Profile', 'प्रोफ़ाइल'))),
        ],
      ),
    );
  }
}
