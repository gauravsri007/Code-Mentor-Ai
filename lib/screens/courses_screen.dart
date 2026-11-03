import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/courses_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('Courses', 'कोर्स'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => CourseCard(
              course: courses[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CourseDetailScreen(course: courses[i])),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
