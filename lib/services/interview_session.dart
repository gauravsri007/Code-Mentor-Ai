import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/interview_bank.dart';
import '../models.dart';
import 'ai_service.dart';

/// Drives a mock interview. Uses the AI backend when available and falls back to a
/// scripted interview with keyword-based scoring when it is not.
class InterviewSession extends ChangeNotifier {
  InterviewSession({
    required this.ai,
    required this.course,
    required this.level,
    required this.hindi,
    Random? rng,
  }) : _rng = rng;

  static const totalQuestions = 5;

  final AiService ai;
  final Course course;
  final int level;
  final bool hindi;
  final Random? _rng;

  final List<ChatMsg> messages = [];
  final List<int> scores = [];
  bool busy = false;
  bool finished = false;
  bool _fellBack = false;
  List<InterviewQ> _qs = const [];
  int _asked = 0;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Async replies can land after the screen is closed.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get offline => !ai.online || _fellBack;
  int get average => scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) ~/ scores.length;
  String _t(T t) => t.of(hindi ? Lang.hi : Lang.en);

  Future<void> start() async {
    busy = true;
    notifyListeners();
    if (ai.online) {
      try {
        final r = await ai.interviewTurn(
            course: course, level: level, hindi: hindi, history: const [], end: false);
        messages.add(ChatMsg(false, r.text));
        busy = false;
        notifyListeners();
        return;
      } catch (_) {
        _fellBack = true;
        messages.add(ChatMsg(
            false,
            _t(const T('The AI server is unreachable, so I will use the built-in question bank.',
                'AI सर्वर उपलब्ध नहीं है, इसलिए मैं अंतर्निहित प्रश्न-बैंक इस्तेमाल करूँगा।'))));
      }
    }
    _qs = OfflineBank.questions(course.id, level, totalQuestions, rng: _rng);
    messages.add(ChatMsg(
        false,
        '${_t(const T('Welcome to your mock interview. Answer in your own words.', 'मॉक इंटरव्यू में स्वागत है। अपने शब्दों में उत्तर दें।'))}\n\n'
        '${_t(const T('Question', 'प्रश्न'))} 1/${_qs.length}:\n${_qs.first.question}'));
    busy = false;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final answer = text.trim();
    if (busy || finished || answer.isEmpty) return;
    messages.add(ChatMsg(true, answer));
    busy = true;
    notifyListeners();
    if (offline) {
      _offlineStep(answer);
    } else {
      await _onlineStep(end: false);
    }
  }

  Future<void> endNow() async {
    if (busy || finished) return;
    busy = true;
    notifyListeners();
    if (offline) {
      finished = true;
      messages.add(ChatMsg(false, _summary()));
      busy = false;
      notifyListeners();
    } else {
      await _onlineStep(end: true);
    }
  }

  void _offlineStep(String answer) {
    final q = _qs[_asked];
    final s = OfflineBank.score(answer, q);
    scores.add(s);
    _asked++;
    final fb = '${_t(OfflineBank.feedback(s))} ($s/100)\n'
        '${_t(const T('Model answer', 'आदर्श उत्तर'))}: ${q.answer}';
    if (_asked >= _qs.length) {
      finished = true;
      messages.add(ChatMsg(false, '$fb\n\n${_summary()}'));
    } else {
      messages.add(ChatMsg(
          false,
          '$fb\n\n${_t(const T('Question', 'प्रश्न'))} ${_asked + 1}/${_qs.length}:\n${_qs[_asked].question}'));
    }
    busy = false;
    notifyListeners();
  }

  String _summary() {
    if (scores.isEmpty) {
      return _t(const T('Interview ended before any question was answered.', 'कोई प्रश्न हल करने से पहले इंटरव्यू समाप्त हो गया।'));
    }
    final avg = average;
    final verdict = avg >= 70
        ? const T('You are interview-ready on this topic.', 'आप इस विषय में इंटरव्यू के लिए तैयार हैं।')
        : avg >= 40
            ? const T('Revise the missed points and try again.', 'छूटे हुए बिंदु दोहराएँ और फिर कोशिश करें।')
            : const T('Study the lessons first, then retry.', 'पहले पाठ पढ़ें, फिर दोबारा कोशिश करें।');
    return '${_t(const T('Interview complete', 'इंटरव्यू पूरा'))}\n'
        '${_t(const T('Average score', 'औसत स्कोर'))}: $avg/100\n${_t(verdict)}';
  }

  Future<void> _onlineStep({required bool end}) async {
    try {
      final r = await ai.interviewTurn(
          course: course, level: level, hindi: hindi, history: List.of(messages), end: end);
      messages.add(ChatMsg(false, r.text));
      if (r.done || end) finished = true;
    } catch (_) {
      messages.add(ChatMsg(
          false,
          _t(const T('Connection problem. Please send your answer again.',
              'कनेक्शन में समस्या। कृपया अपना उत्तर फिर भेजें।'))));
    }
    busy = false;
    notifyListeners();
  }
}
