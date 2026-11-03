import 'dart:math';

import '../models.dart';

/// Offline fallback used when no AI backend is configured or reachable.
class OfflineBank {
  const OfflineBank._();

  static const Map<String, List<InterviewQ>> _bank = {
    'java': [
      InterviewQ(level: 0, question: 'What is the difference between JDK, JRE and JVM?', answer: 'The JVM runs Java bytecode, the JRE bundles the JVM with core libraries, and the JDK adds development tools such as the compiler (javac) on top of the JRE.', keywords: ['jvm', 'bytecode', 'jre', 'jdk', 'compiler']),
      InterviewQ(level: 0, question: 'What is the difference between == and equals() in Java?', answer: '== compares references (or primitive values), while equals() compares logical content when overridden, as String does. Override equals() together with hashCode().', keywords: ['reference', 'equals', 'content', 'hashcode']),
      InterviewQ(level: 1, question: 'Explain the difference between an abstract class and an interface.', answer: 'An abstract class can hold state and constructors and supports single inheritance; an interface defines a contract that a class can implement many of, and since Java 8 may have default methods.', keywords: ['abstract', 'interface', 'multiple', 'state', 'default']),
      InterviewQ(level: 1, question: 'How does HashMap work internally?', answer: 'It hashes the key to choose a bucket, stores entries in a table of buckets, resolves collisions with linked lists or trees, and resizes when the load factor is exceeded.', keywords: ['hash', 'bucket', 'collision', 'load factor', 'equals']),
      InterviewQ(level: 2, question: 'What causes memory leaks in Java despite garbage collection?', answer: 'Objects stay reachable through static fields, unclosed resources, listeners that are never removed, or growing caches, so the garbage collector cannot reclaim them.', keywords: ['reachable', 'static', 'listener', 'cache', 'garbage']),
    ],
    'python': [
      InterviewQ(level: 0, question: 'What is the difference between a list and a tuple?', answer: 'Lists are mutable; tuples are immutable and can be dictionary keys when their items are hashable. Tuples are slightly lighter.', keywords: ['mutable', 'immutable', 'tuple', 'list']),
      InterviewQ(level: 0, question: 'What does the self parameter mean in a method?', answer: 'self refers to the instance the method is called on, letting the method access that object\'s attributes and other methods.', keywords: ['instance', 'method', 'attribute']),
      InterviewQ(level: 1, question: 'Explain decorators in Python.', answer: 'A decorator is a function that takes another function and returns a wrapper around it, adding behaviour such as logging or caching without changing the original code.', keywords: ['function', 'wrapper', 'decorator', 'without']),
      InterviewQ(level: 1, question: 'What is the GIL?', answer: 'The Global Interpreter Lock lets only one thread run Python bytecode at a time in CPython, so CPU-bound work needs multiprocessing while I/O-bound work can still use threads or asyncio.', keywords: ['global interpreter lock', 'thread', 'cpu', 'multiprocessing', 'asyncio']),
      InterviewQ(level: 2, question: 'How do generators differ from lists and why use them?', answer: 'Generators yield values lazily, one at a time, so they use constant memory and suit large or infinite streams, whereas lists hold every item in memory.', keywords: ['lazy', 'yield', 'memory', 'iterator']),
    ],
    'flutter': [
      InterviewQ(level: 0, question: 'What is the difference between StatelessWidget and StatefulWidget?', answer: 'A StatelessWidget is immutable and its UI depends only on its configuration. A StatefulWidget has a State object whose setState call triggers a rebuild.', keywords: ['immutable', 'state', 'setstate', 'rebuild']),
      InterviewQ(level: 0, question: 'What is BuildContext?', answer: 'A handle to a widget\'s location in the widget tree, used to look up ancestors such as Theme, MediaQuery or Navigator.', keywords: ['location', 'tree', 'ancestor', 'theme']),
      InterviewQ(level: 1, question: 'Explain the difference between hot reload and hot restart.', answer: 'Hot reload injects updated code and keeps the current state; hot restart restarts the app and resets all state.', keywords: ['state', 'inject', 'restart', 'reset']),
      InterviewQ(level: 1, question: 'How do keys work in Flutter?', answer: 'Keys help Flutter match widgets to elements across rebuilds, preserving state when widgets move within a list. ValueKey and UniqueKey are common.', keywords: ['key', 'state', 'element', 'list', 'rebuild']),
      InterviewQ(level: 2, question: 'How would you avoid unnecessary widget rebuilds?', answer: 'Use const constructors, split large widgets into smaller ones, scope state with providers or selectors, use ValueListenableBuilder, and avoid heavy work inside build.', keywords: ['const', 'selector', 'split', 'build', 'provider']),
    ],
    'swift': [
      InterviewQ(level: 0, question: 'What is an optional in Swift?', answer: 'A type that holds either a value or nil, written with ?. It forces you to handle missing values explicitly using if let, guard let or ??.', keywords: ['nil', 'unwrap', 'value', 'guard']),
      InterviewQ(level: 0, question: 'Explain the difference between struct and class.', answer: 'Structs are value types that are copied on assignment; classes are reference types that share one instance and support inheritance.', keywords: ['value', 'reference', 'copy', 'inheritance']),
      InterviewQ(level: 1, question: 'What is ARC and what is a retain cycle?', answer: 'Automatic Reference Counting frees an object when its strong reference count reaches zero. A retain cycle occurs when objects hold strong references to each other, so neither is freed; break it with weak or unowned.', keywords: ['reference count', 'weak', 'strong', 'cycle', 'deinit']),
      InterviewQ(level: 1, question: 'What is the difference between weak and unowned?', answer: 'weak references are optional and become nil when the object is deallocated; unowned references are non-optional and crash if accessed after deallocation.', keywords: ['optional', 'nil', 'crash', 'deallocated']),
      InterviewQ(level: 2, question: 'Explain Swift concurrency with async/await and actors.', answer: 'async/await writes asynchronous code linearly with suspension points; actors protect mutable state by serialising access, preventing data races; @MainActor isolates UI work to the main thread.', keywords: ['async', 'await', 'actor', 'data race', 'mainactor']),
    ],
    'android': [
      InterviewQ(level: 0, question: 'Explain the Activity lifecycle.', answer: 'onCreate sets up the UI, onStart makes it visible, onResume gives it focus, onPause and onStop run as it leaves the foreground, and onDestroy cleans up.', keywords: ['oncreate', 'onstart', 'onresume', 'onpause', 'ondestroy']),
      InterviewQ(level: 0, question: 'What is the difference between an Activity and a Fragment?', answer: 'An Activity is a full-screen entry point; a Fragment is a reusable portion of UI with its own lifecycle, hosted inside an Activity.', keywords: ['fragment', 'reusable', 'lifecycle', 'host']),
      InterviewQ(level: 1, question: 'What is a ViewModel and why use it?', answer: 'A lifecycle-aware class that holds UI state and survives configuration changes such as rotation, keeping logic out of the Activity or Fragment.', keywords: ['configuration', 'rotation', 'state', 'lifecycle']),
      InterviewQ(level: 1, question: 'Explain coroutines in Kotlin.', answer: 'Coroutines are lightweight suspendable computations that let you write asynchronous code sequentially, launched in scopes such as viewModelScope and run on dispatchers like Dispatchers.IO.', keywords: ['suspend', 'dispatcher', 'scope', 'lightweight', 'async']),
      InterviewQ(level: 2, question: 'How do you prevent memory leaks in Android?', answer: 'Avoid holding an Activity context in long-lived objects, unregister listeners, cancel coroutines with lifecycle scopes, and use LeakCanary to detect leaks.', keywords: ['context', 'leakcanary', 'listener', 'lifecycle', 'static']),
    ],
  };

  /// Returns [count] questions, preferring [level] and topping up from other levels.
  static List<InterviewQ> questions(String courseId, int level, int count, {Random? rng}) {
    final all = _bank[courseId] ?? const <InterviewQ>[];
    final random = rng ?? Random();
    final exact = all.where((q) => q.level == level).toList()..shuffle(random);
    final others = all.where((q) => q.level != level).toList()
      ..sort((a, b) => (a.level - level).abs().compareTo((b.level - level).abs()));
    return [...exact, ...others].take(count).toList();
  }

  /// Keyword-coverage score from 0 to 100.
  static int score(String answer, InterviewQ q) {
    final text = answer.toLowerCase();
    if (q.keywords.isEmpty) return text.trim().length > 40 ? 60 : 30;
    final found = q.keywords.where(text.contains).length;
    var s = min(100, (found / q.keywords.length * 125).round());
    if (answer.trim().length < 25) s = min(s, 30);
    return s;
  }

  static T feedback(int score) {
    if (score >= 70) return const T('Great answer!', 'बहुत बढ़िया उत्तर!');
    if (score >= 40) return const T('Good start, but you missed some key points.', 'अच्छी शुरुआत, पर कुछ मुख्य बिंदु छूट गए।');
    return const T('This needs more depth.', 'इसमें और गहराई की ज़रूरत है।');
  }
}
