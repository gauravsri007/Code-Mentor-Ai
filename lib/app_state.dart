import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/challenges_data.dart';
import 'data/courses_data.dart';
import 'models.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Single source of truth: language, progress, XP, streak and certificates.
/// Persisted to SharedPreferences as one JSON blob.
class AppState extends ChangeNotifier {
  AppState._(this._prefs, this._clock) {
    _load();
  }

  static Future<AppState> create({DateTime Function()? clock}) async =>
      AppState._(await SharedPreferences.getInstance(), clock ?? DateTime.now);

  static const passMark = 60;
  static const _key = 'state_v1';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  Lang lang = Lang.en;
  String name = '';
  int xp = 0;
  int streak = 0;
  String lastActive = '';
  String dailyDone = '';
  int interviews = 0;
  final Set<String> lessons = {};
  final Map<String, int> quizBest = {};
  final Set<String> solved = {};
  final Map<String, Certificate> certs = {};
  final List<int> interviewScores = [];

  String t(T x) => x.of(lang);
  bool get hindi => lang == Lang.hi;
  int get level => xp ~/ 100 + 1;

  // ---------------------------------------------------------------- persistence

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      lang = (m['lang'] as String?) == 'hi' ? Lang.hi : Lang.en;
      name = (m['name'] as String?) ?? '';
      xp = (m['xp'] as int?) ?? 0;
      streak = (m['streak'] as int?) ?? 0;
      lastActive = (m['lastActive'] as String?) ?? '';
      dailyDone = (m['dailyDone'] as String?) ?? '';
      interviews = (m['interviews'] as int?) ?? 0;
      lessons.addAll(((m['lessons'] as List?) ?? const []).cast<String>());
      solved.addAll(((m['solved'] as List?) ?? const []).cast<String>());
      quizBest.addAll(((m['quizBest'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', v as int)));
      interviewScores.addAll(((m['interviewScores'] as List?) ?? const []).cast<int>());
      ((m['certs'] as Map?) ?? const {}).forEach((k, v) {
        certs['$k'] = Certificate.fromJson(Map<String, dynamic>.from(v as Map));
      });
    } catch (_) {
      // Corrupt data: start fresh rather than crash.
    }
  }

  void _commit() {
    _prefs.setString(
      _key,
      jsonEncode({
        'lang': lang == Lang.hi ? 'hi' : 'en',
        'name': name,
        'xp': xp,
        'streak': streak,
        'lastActive': lastActive,
        'dailyDone': dailyDone,
        'interviews': interviews,
        'lessons': lessons.toList(),
        'solved': solved.toList(),
        'quizBest': quizBest,
        'interviewScores': interviewScores,
        'certs': certs.map((k, v) => MapEntry(k, v.toJson())),
      }),
    );
    notifyListeners();
  }

  Future<void> reset() async {
    lang = Lang.en;
    name = '';
    xp = streak = interviews = 0;
    lastActive = dailyDone = '';
    lessons.clear();
    quizBest.clear();
    solved.clear();
    certs.clear();
    interviewScores.clear();
    await _prefs.remove(_key);
    notifyListeners();
  }

  // ------------------------------------------------------------------- settings

  void toggleLang() {
    lang = hindi ? Lang.en : Lang.hi;
    _commit();
  }

  void setName(String v) {
    name = v.trim();
    _commit();
  }

  // --------------------------------------------------------------------- streak

  String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _touch() {
    final today = dayKey(_clock());
    if (lastActive == today) return;
    final yesterday = dayKey(_clock().subtract(const Duration(days: 1)));
    streak = lastActive == yesterday ? streak + 1 : 1;
    lastActive = today;
  }

  // ------------------------------------------------------------------- learning

  void completeLesson(String id) {
    if (lessons.add(id)) xp += 10;
    _touch();
    _commit();
  }

  /// Records a lesson quiz. Passing (>= [passMark]%) also completes the lesson.
  /// XP is only awarded for improving on the previous best, so retries can't be farmed.
  void recordLessonQuiz(String lessonId, int correct, int total) {
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final prev = quizBest[lessonId] ?? 0;
    if (pct > prev) {
      xp += (pct - prev) ~/ 5;
      quizBest[lessonId] = pct;
    }
    if (pct >= passMark && lessons.add(lessonId)) xp += 10;
    _touch();
    _commit();
  }

  void recordPracticeQuiz(int correct) {
    xp += correct * 2;
    _touch();
    _commit();
  }

  void solveChallenge(Challenge c) {
    if (solved.add(c.id)) xp += c.xp;
    _touch();
    _commit();
  }

  // ---------------------------------------------------------------------- daily

  Challenge get dailyChallenge {
    final n = _clock();
    final days = DateTime(n.year, n.month, n.day).difference(DateTime(2024)).inDays;
    return allChallenges[days % allChallenges.length];
  }

  bool get dailyComplete => dailyDone == dayKey(_clock());

  void completeDaily() {
    if (dailyComplete) return;
    dailyDone = dayKey(_clock());
    xp += 20;
    _touch();
    _commit();
  }

  // ------------------------------------------------------------------ interviews

  void recordInterview({int? score}) {
    interviews++;
    if (score != null) interviewScores.add(score);
    xp += 15;
    _touch();
    _commit();
  }

  // ------------------------------------------------------------------- progress

  int completedIn(Course c) => c.lessons.where((l) => lessons.contains(l.id)).length;
  double progress(Course c) => c.lessons.isEmpty ? 0 : completedIn(c) / c.lessons.length;

  bool certificateEligible(Course c) =>
      c.lessons.every((l) => lessons.contains(l.id) && (quizBest[l.id] ?? 0) >= passMark);

  /// First lesson not yet completed in the most advanced unfinished course.
  ({Course course, Lesson lesson})? get nextLesson {
    Course? best;
    for (final c in courses) {
      if (progress(c) < 1 && (best == null || progress(c) > progress(best))) best = c;
    }
    if (best == null) return null;
    return (course: best, lesson: best.lessons.firstWhere((l) => !lessons.contains(l.id)));
  }

  Certificate? issueCertificate(Course c, String holder) {
    if (!certificateEligible(c) || holder.trim().isEmpty) return null;
    final now = _clock();
    final cert = Certificate(
      id: 'CM-${c.id.toUpperCase()}-${now.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      name: holder.trim(),
      date: '${now.day} ${_months[now.month - 1]} ${now.year}',
    );
    certs[c.id] = cert;
    name = holder.trim();
    xp += 50;
    _commit();
    return cert;
  }

  List<Achievement> get badges => [
        Achievement(const T('First lesson', 'पहला पाठ'), Icons.flag, lessons.isNotEmpty),
        Achievement(const T('Perfect quiz', 'परफ़ेक्ट क्विज़'), Icons.emoji_events, quizBest.values.any((v) => v == 100)),
        Achievement(const T('3-day streak', '3 दिन की स्ट्रीक'), Icons.local_fire_department, streak >= 3),
        Achievement(const T('100 XP', '100 XP'), Icons.bolt, xp >= 100),
        Achievement(const T('Problem solver', 'समस्या-समाधानकर्ता'), Icons.extension, solved.length >= 3),
        Achievement(const T('Interview ready', 'इंटरव्यू के लिए तैयार'), Icons.record_voice_over, interviews > 0),
        Achievement(const T('Graduate', 'स्नातक'), Icons.school, certs.isNotEmpty),
      ];
}
