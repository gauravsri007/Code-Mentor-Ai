import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/interview_bank.dart';
import '../models.dart';

class QuestionSet {
  const QuestionSet(this.items, {this.offline = false, this.note});
  final List<InterviewQ> items;
  final bool offline;
  final String? note;
}

class InterviewReply {
  const InterviewReply(this.text, {this.done = false});
  final String text;
  final bool done;
}

/// Talks to your AI backend (see backend/server.js). The API key lives on the
/// server, never in the app. With no backend configured the app falls back to the
/// built-in question bank so every feature still works offline.
///
/// Configure with: flutter run --dart-define=AI_BASE_URL=https://your-server.example.com
class AiService {
  AiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? const String.fromEnvironment('AI_BASE_URL'),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  bool get online => baseUrl.isNotEmpty;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));
    if (res.statusCode != 200) throw Exception('Server returned ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<QuestionSet> generateQuestions({
    required Course course,
    required int level,
    int count = 5,
    required bool hindi,
  }) async {
    if (online) {
      try {
        final j = await _post('/api/questions', {
          'topic': course.name,
          'level': levelNames[level].en,
          'count': count,
          'language': hindi ? 'Hindi' : 'English',
        });
        final items = [
          for (final e in (j['questions'] as List))
            InterviewQ(
              question: (e as Map)['question'] as String,
              answer: e['answer'] as String,
              level: level,
            ),
        ];
        if (items.isNotEmpty) return QuestionSet(items);
      } catch (_) {
        return QuestionSet(
          OfflineBank.questions(course.id, level, count),
          offline: true,
          note: 'AI server unreachable - showing the built-in question bank.',
        );
      }
    }
    return QuestionSet(OfflineBank.questions(course.id, level, count), offline: true);
  }

  Future<InterviewReply> interviewTurn({
    required Course course,
    required int level,
    required bool hindi,
    required List<ChatMsg> history,
    required bool end,
  }) async {
    final j = await _post('/api/interview', {
      'topic': course.name,
      'level': levelNames[level].en,
      'language': hindi ? 'Hindi' : 'English',
      'end': end,
      'history': [
        for (final m in history) {'role': m.fromUser ? 'user' : 'assistant', 'content': m.text},
      ],
    });
    return InterviewReply(j['text'] as String, done: j['done'] == true);
  }

  Future<String> reviewCode({
    required Course course,
    required String task,
    required String code,
    required bool hindi,
  }) async {
    if (!online) {
      return hindi
          ? 'AI समीक्षा के लिए AI सर्वर चाहिए (README देखें)। अभी संकेत (Hint) इस्तेमाल करें।'
          : 'AI review needs the AI server (see README). Use the hint for now.';
    }
    final j = await _post('/api/review', {
      'topic': course.name,
      'task': task,
      'code': code,
      'language': hindi ? 'Hindi' : 'English',
    });
    return j['text'] as String;
  }
}
