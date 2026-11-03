import 'package:flutter/material.dart';

enum Lang { en, hi }

/// A bilingual string.
class T {
  const T(this.en, this.hi);
  final String en;
  final String hi;
  String of(Lang l) => l == Lang.hi ? hi : en;
}

const levelNames = [
  T('Beginner', 'शुरुआती'),
  T('Intermediate', 'मध्यम'),
  T('Advanced', 'उन्नत'),
];

class Mcq {
  const Mcq(this.question, this.options, this.answer, this.explanation);
  final T question;
  final List<String> options;
  final int answer;
  final T explanation;
}

class Lesson {
  const Lesson(this.id, this.title, this.body, this.code, this.quiz);
  final String id;
  final T title;
  final T body;
  final String code;
  final List<Mcq> quiz;
}

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.tagline,
    required this.lessons,
  });
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final T tagline;
  final List<Lesson> lessons;

  List<Mcq> get allQuestions => [for (final l in lessons) ...l.quiz];
}

class Challenge {
  const Challenge({
    required this.id,
    required this.courseId,
    required this.title,
    required this.prompt,
    required this.answers,
    required this.hint,
    this.starter = '',
    this.xp = 15,
  });
  final String id;
  final String courseId;
  final T title;
  final T prompt;
  final String starter;
  final List<String> answers;
  final T hint;
  final int xp;

  static String normalize(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  bool accepts(String input) {
    final n = normalize(input);
    return n.isNotEmpty && answers.any((a) => normalize(a) == n);
  }
}

class InterviewQ {
  const InterviewQ({
    required this.question,
    required this.answer,
    this.keywords = const [],
    this.level = 0,
  });
  final String question;
  final String answer;
  final List<String> keywords;
  final int level;
}

class ChatMsg {
  const ChatMsg(this.fromUser, this.text);
  final bool fromUser;
  final String text;
}

class Certificate {
  const Certificate({required this.id, required this.name, required this.date});
  final String id;
  final String name;
  final String date;

  Map<String, String> toJson() => {'id': id, 'name': name, 'date': date};
  factory Certificate.fromJson(Map<String, dynamic> j) =>
      Certificate(id: j['id'] as String, name: j['name'] as String, date: j['date'] as String);
}

class Achievement {
  const Achievement(this.title, this.icon, this.earned);
  final T title;
  final IconData icon;
  final bool earned;
}
