# CodeMentor AI

AI-powered learning platform: Java, Python, Flutter, Swift and Android courses, MCQ quizzes,
coding challenges, AI interview questions, AI mock interviews, progress tracking, certificates,
Hindi + English tutorials and a daily challenge with streaks.

## Run it

```bash
flutter create --org com.example --project-name codementor_ai .   # generates android/ and ios/
# (keep this repo's lib/, test/, pubspec.yaml, backend/ when asked to overwrite)
flutter pub get
flutter run
```

**Android release builds** need the internet permission in `android/app/src/main/AndroidManifest.xml`
(inside `<manifest>`, above `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Without an AI server the app runs fully offline using its built-in question bank.

## Enable live AI (recommended)

The API key must never ship inside the app, so a tiny server holds it:

```bash
cd backend
ANTHROPIC_API_KEY=sk-ant-... node server.js          # Node 18+, no npm install needed
```

Deploy it somewhere with HTTPS (Cloud Run, Fly.io, Render, a VPS...), then:

```bash
flutter run --dart-define=AI_BASE_URL=https://your-server.example.com
```

For a quick test on the Android emulator use `http://10.0.2.2:8787` (add
`android:usesCleartextTraffic="true"` to `<application>` for debug builds only).
For a real emulator/device on your LAN use your machine's IP.

Set `ANTHROPIC_MODEL` to change the model (default `claude-sonnet-5-5`) and `ALLOWED_ORIGIN` to lock down CORS.
Before launch add real user authentication and per-user quotas; the built-in rate limit is per-IP and in-memory.

## Feature map

| Feature | Where |
|---|---|
| 5 courses, 15 bilingual lessons | `lib/data/courses_data.dart`, `screens/course_detail_screen.dart`, `lesson_screen.dart` |
| Hindi / English tutorials | `T` bilingual strings + `LangToggle` (top-right on every screen) |
| Lesson + practice MCQ quizzes | `screens/quiz_screen.dart`, `practice_screen.dart` |
| Coding challenges (predict output / complete code) | `data/challenges_data.dart`, `screens/challenge_screen.dart` |
| AI interview questions | `screens/ai_questions_screen.dart` -> `POST /api/questions` |
| AI mock interview | `services/interview_session.dart`, `screens/mock_interview_screen.dart` -> `POST /api/interview` |
| AI code feedback ("Ask AI") | `screens/challenge_screen.dart` -> `POST /api/review` |
| Progress, XP, levels, badges | `app_state.dart`, `screens/profile_screen.dart` |
| Daily challenge + streak | `AppState.dailyChallenge`, `completeDaily()`, `_touch()` |
| Certificates (shareable PNG) | `screens/certificate_screen.dart` |

## Design notes and limits

- **Challenges are checked locally** by comparing the answer (whitespace/case-insensitive), because running
  arbitrary user code safely needs a server-side sandbox. "Ask AI" gives feedback on free-form answers.
- **Offline mock interview** scores answers by keyword coverage - a rough guide, not a real evaluation.
- **Certificates** require passing every lesson quiz in a course (>= 60%). They are generated on the device
  and are not cryptographically verifiable; add a server-side registry if you need verification.
- Progress is stored on the device (SharedPreferences). Add Firebase/your backend for sync across devices.
- Add more lessons by appending to `courses` in `lib/data/courses_data.dart`; no other code changes needed.

## Tests

```bash
flutter test
```
