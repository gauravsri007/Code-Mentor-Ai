import 'package:codementor_ai/app_state.dart';
import 'package:codementor_ai/main.dart';
import 'package:codementor_ai/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('navigates between tabs and switches to Hindi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        Provider<AiService>(create: (_) => AiService(baseUrl: '')),
      ],
      child: const CodeMentorApp(),
    ));

    expect(find.text('Daily challenge'), findsOneWidget);

    await tester.tap(find.text('Courses').last);
    await tester.pumpAndSettle();
    expect(find.text('Java'), findsWidgets);

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(find.text('कोर्स'), findsWidgets);
  });
}
