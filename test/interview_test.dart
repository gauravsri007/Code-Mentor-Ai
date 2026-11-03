import 'dart:math';

import 'package:codementor_ai/data/challenges_data.dart';
import 'package:codementor_ai/data/courses_data.dart';
import 'package:codementor_ai/data/interview_bank.dart';
import 'package:codementor_ai/models.dart';
import 'package:codementor_ai/services/ai_service.dart';
import 'package:codementor_ai/services/interview_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflineBank', () {
    test('returns the requested number, preferring the level', () {
      final qs = OfflineBank.questions('python', 1, 3, rng: Random(1));
      expect(qs, hasLength(3));
      expect(qs.first.level, 1);
    });

    test('scores by keyword coverage and caps very short answers', () {
      const q = InterviewQ(
          question: 'q', answer: 'a', keywords: ['mutable', 'immutable', 'tuple', 'list']);
      expect(OfflineBank.score('Lists are mutable, tuples are immutable, so a tuple is safer than a list.', q), greaterThanOrEqualTo(70));
      expect(OfflineBank.score('idk', q), lessThanOrEqualTo(30));
      expect(OfflineBank.score('Something unrelated but reasonably long to avoid the cap.', q), 0);
    });

    test('every course has questions', () {
      for (final c in courses) {
        expect(OfflineBank.questions(c.id, 0, 5), isNotEmpty, reason: c.id);
      }
    });
  });

  group('Challenge.accepts', () {
    test('ignores whitespace and case', () {
      final c = allChallenges.firstWhere((c) => c.id == 'c-py-2');
      expect(c.accepts('[0,2,4]'), isTrue);
      expect(c.accepts(' [0, 2,  4] '), isTrue);
      expect(c.accepts('[0, 2, 5]'), isFalse);
      expect(c.accepts(''), isFalse);
    });
  });

  test('offline mock interview runs end to end', () async {
    final session = InterviewSession(
      ai: AiService(baseUrl: ''),
      course: courseById('java'),
      level: 0,
      hindi: false,
      rng: Random(2),
    );
    await session.start();
    expect(session.offline, isTrue);
    expect(session.messages, hasLength(1));
    for (var i = 0; i < InterviewSession.totalQuestions; i++) {
      await session.send('A reasonably detailed answer about reference equals content hashcode jvm bytecode.');
    }
    expect(session.finished, isTrue);
    expect(session.scores, hasLength(InterviewSession.totalQuestions));
    expect(session.messages.last.text, contains('Average score'));
  });
}
