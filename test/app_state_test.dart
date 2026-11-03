import 'package:codementor_ai/app_state.dart';
import 'package:codementor_ai/data/courses_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;

  Future<AppState> make() async {
    SharedPreferences.setMockInitialValues({});
    return AppState.create(clock: () => now);
  }

  setUp(() => now = DateTime(2026, 3, 10, 9));

  test('streak grows on consecutive days and resets after a gap', () async {
    final s = await make();
    s.completeLesson('a');
    expect(s.streak, 1);
    now = DateTime(2026, 3, 11, 9);
    s.completeLesson('b');
    expect(s.streak, 2);
    now = DateTime(2026, 3, 14, 9);
    s.completeLesson('c');
    expect(s.streak, 1);
  });

  test('quiz XP is only awarded for improving the best score', () async {
    final s = await make();
    s.recordLessonQuiz('java-1', 1, 2); // 50%
    expect(s.quizBest['java-1'], 50);
    expect(s.lessons.contains('java-1'), isFalse);
    expect(s.xp, 10);
    s.recordLessonQuiz('java-1', 2, 2); // 100%
    expect(s.lessons.contains('java-1'), isTrue);
    expect(s.xp, 30); // +10 improvement, +10 completion
    s.recordLessonQuiz('java-1', 2, 2);
    expect(s.xp, 30);
  });

  test('certificate requires every lesson quiz to be passed', () async {
    final s = await make();
    final java = courseById('java');
    expect(s.certificateEligible(java), isFalse);
    expect(s.issueCertificate(java, 'Asha'), isNull);
    for (final l in java.lessons) {
      s.recordLessonQuiz(l.id, 2, 2);
    }
    expect(s.certificateEligible(java), isTrue);
    final cert = s.issueCertificate(java, '  Asha  ');
    expect(cert, isNotNull);
    expect(cert!.name, 'Asha');
    expect(cert.id, startsWith('CM-JAVA-'));
  });

  test('daily challenge is stable within a day and completes once', () async {
    final s = await make();
    final first = s.dailyChallenge.id;
    now = DateTime(2026, 3, 10, 22);
    expect(s.dailyChallenge.id, first);
    s.completeDaily();
    final xp = s.xp;
    s.completeDaily();
    expect(s.xp, xp);
    expect(s.dailyComplete, isTrue);
  });

  test('state survives a restart', () async {
    final s = await make();
    s.setName('Ravi');
    s.toggleLang();
    s.completeLesson('py-1');
    final again = await AppState.create(clock: () => now);
    expect(again.name, 'Ravi');
    expect(again.hindi, isTrue);
    expect(again.lessons, contains('py-1'));
  });
}
