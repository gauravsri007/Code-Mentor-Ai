import 'package:flutter/material.dart';

import '../models.dart';

const List<Course> courses = [
  Course(
    id: 'java',
    name: 'Java',
    icon: Icons.coffee,
    color: Color(0xFFEA580C),
    tagline: T('Object-oriented programming from scratch', 'शुरू से ऑब्जेक्ट-ओरिएंटेड प्रोग्रामिंग'),
    lessons: [
      Lesson(
        'java-1',
        T('Variables and data types', 'वेरिएबल और डेटा टाइप'),
        T(
          'Java is statically typed: every variable has a type that is checked at compile time. Primitive types such as int, double and boolean store simple values, while String is a class that stores text.\n\nChoose the smallest type that fits your data and give variables meaningful names.',
          'Java एक स्टैटिकली टाइप्ड भाषा है: हर वेरिएबल का एक टाइप होता है जिसे कंपाइल के समय जाँचा जाता है। int, double और boolean जैसे प्रिमिटिव टाइप साधारण मान रखते हैं, जबकि String एक क्लास है जो टेक्स्ट रखती है।\n\nअपने डेटा के लिए सही टाइप चुनें और वेरिएबल को अर्थपूर्ण नाम दें।',
        ),
        'int age = 20;\ndouble gpa = 8.5;\nboolean active = true;\nString name = "Asha";\nSystem.out.println(name + " is " + age);',
        [
          Mcq(T('Which type stores whole numbers?', 'पूर्ण संख्याएँ किस टाइप में रखी जाती हैं?'),
              ['int', 'double', 'boolean', 'String'], 0,
              T('int holds whole numbers; double holds decimals.', 'int पूर्ण संख्याएँ रखता है; double दशमलव संख्याएँ।')),
          Mcq(T('Which of these is a class, not a primitive?', 'इनमें से कौन प्रिमिटिव नहीं बल्कि क्लास है?'),
              ['int', 'boolean', 'String', 'double'], 2,
              T('String is a class in java.lang.', 'String, java.lang की एक क्लास है।')),
        ],
      ),
      Lesson(
        'java-2',
        T('Classes and objects', 'क्लास और ऑब्जेक्ट'),
        T(
          'A class is a blueprint; an object is an instance created from it with the new keyword. Fields hold state and methods hold behaviour.\n\nMarking fields private and exposing them through methods is called encapsulation.',
          'क्लास एक ब्लूप्रिंट है; ऑब्जेक्ट उससे new कीवर्ड द्वारा बनाया गया उदाहरण है। फ़ील्ड स्टेट रखते हैं और मेथड व्यवहार।\n\nफ़ील्ड को private रखकर मेथड के ज़रिए उपलब्ध कराना एनकैप्सुलेशन कहलाता है।',
        ),
        'class Dog {\n  private String name;\n  Dog(String name) { this.name = name; }\n  void bark() { System.out.println(name + " says woof"); }\n}\n\nDog d = new Dog("Tommy");\nd.bark();',
        [
          Mcq(T('Which keyword creates an object?', 'ऑब्जेक्ट बनाने के लिए कौन सा कीवर्ड है?'),
              ['new', 'create', 'make', 'object'], 0,
              T('new allocates an object and calls its constructor.', 'new ऑब्जेक्ट बनाता है और उसका कंस्ट्रक्टर चलाता है।')),
          Mcq(T('Hiding fields behind private and exposing methods is called…', 'फ़ील्ड को private रखकर मेथड से एक्सेस देना क्या कहलाता है?'),
              ['Inheritance', 'Encapsulation', 'Polymorphism', 'Overloading'], 1,
              T('That is encapsulation.', 'इसे एनकैप्सुलेशन कहते हैं।')),
        ],
      ),
      Lesson(
        'java-3',
        T('ArrayList and collections', 'ArrayList और कलेक्शन'),
        T(
          'Arrays have a fixed size. ArrayList is a resizable list from java.util that grows as you add items. Use add, get, remove and size to work with it, and prefer generics such as ArrayList<String> for type safety.',
          'ऐरे का आकार तय होता है। ArrayList java.util की ऐसी लिस्ट है जो आइटम जोड़ने पर बढ़ती है। add, get, remove और size से इसे चलाएँ, और टाइप सुरक्षा के लिए ArrayList<String> जैसे जेनेरिक्स इस्तेमाल करें।',
        ),
        'ArrayList<String> names = new ArrayList<>();\nnames.add("Ravi");\nnames.add("Neha");\nSystem.out.println(names.size()); // 2',
        [
          Mcq(T('Which method adds an element to an ArrayList?', 'ArrayList में तत्व जोड़ने की मेथड कौन सी है?'),
              ['add', 'push', 'insert', 'append'], 0,
              T('ArrayList uses add().', 'ArrayList में add() इस्तेमाल होती है।')),
          Mcq(T('Main advantage of ArrayList over an array?', 'ऐरे की तुलना में ArrayList का मुख्य लाभ?'),
              ['Always faster', 'It is resizable', 'Uses no memory', 'Stores only primitives'], 1,
              T('It grows and shrinks dynamically.', 'यह ज़रूरत के अनुसार बढ़ती-घटती है।')),
        ],
      ),
    ],
  ),
  Course(
    id: 'python',
    name: 'Python',
    icon: Icons.code,
    color: Color(0xFF2563EB),
    tagline: T('Readable code for beginners and data work', 'शुरुआती और डेटा कार्य के लिए पठनीय कोड'),
    lessons: [
      Lesson(
        'py-1',
        T('Variables and types', 'वेरिएबल और टाइप'),
        T(
          'Python is dynamically typed: you do not declare types, and a variable can later hold a different type. Common types are int, float, str, bool, list and dict. Use type() to inspect a value.',
          'Python डायनामिकली टाइप्ड है: आप टाइप घोषित नहीं करते और एक वेरिएबल बाद में दूसरा टाइप रख सकता है। आम टाइप हैं int, float, str, bool, list और dict। किसी मान का टाइप देखने के लिए type() इस्तेमाल करें।',
        ),
        'x = 10\nx = "ten"        # allowed\npi = 3.14\nprint(type(pi))  # <class \'float\'>',
        [
          Mcq(T('What is the type of 3.14?', '3.14 का टाइप क्या है?'),
              ['int', 'float', 'str', 'bool'], 1,
              T('Numbers with a decimal point are float.', 'दशमलव वाली संख्याएँ float होती हैं।')),
          Mcq(T('Python is…', 'Python कैसी भाषा है?'),
              ['Statically typed', 'Dynamically typed', 'Untyped assembly', 'Only compiled'], 1,
              T('Types are checked at run time.', 'टाइप रनटाइम पर जाँचे जाते हैं।')),
        ],
      ),
      Lesson(
        'py-2',
        T('Lists and loops', 'लिस्ट और लूप'),
        T(
          'A list stores ordered, changeable items. Loop over it with for, and use range(n) to count from 0 to n-1. List comprehensions build new lists in one line.',
          'लिस्ट क्रम में रखे, बदले जा सकने वाले आइटम रखती है। for से उस पर लूप चलाएँ, और 0 से n-1 तक गिनने के लिए range(n) इस्तेमाल करें। लिस्ट कॉम्प्रिहेंशन एक पंक्ति में नई लिस्ट बनाते हैं।',
        ),
        'nums = [1, 2, 3]\nfor n in nums:\n    print(n * 2)\n\nsquares = [n * n for n in range(4)]\nprint(squares)  # [0, 1, 4, 9]',
        [
          Mcq(T('What does len([1, 2, 3]) return?', 'len([1, 2, 3]) क्या लौटाता है?'),
              ['2', '3', '4', 'Error'], 1,
              T('There are three items.', 'तीन आइटम हैं।')),
          Mcq(T('range(3) produces…', 'range(3) क्या देता है?'),
              ['1, 2, 3', '0, 1, 2', '0, 1, 2, 3', '1, 2'], 1,
              T('It starts at 0 and stops before 3.', 'यह 0 से शुरू होकर 3 से पहले रुकता है।')),
        ],
      ),
      Lesson(
        'py-3',
        T('Functions', 'फंक्शन'),
        T(
          'Functions group reusable code. Define one with def, pass parameters, and send a value back with return. A function without a return statement returns None.',
          'फंक्शन दोबारा इस्तेमाल होने वाले कोड को समेटते हैं। def से बनाएँ, पैरामीटर दें, और return से मान लौटाएँ। जिस फंक्शन में return नहीं होता वह None लौटाता है।',
        ),
        'def greet(name, greeting="Hello"):\n    return f"{greeting}, {name}!"\n\nprint(greet("Asha"))',
        [
          Mcq(T('Which keyword defines a function?', 'फंक्शन बनाने का कीवर्ड कौन सा है?'),
              ['func', 'def', 'function', 'define'], 1,
              T('Python uses def.', 'Python में def इस्तेमाल होता है।')),
          Mcq(T('A function with no return statement gives back…', 'return के बिना फंक्शन क्या लौटाता है?'),
              ['0', 'empty string', 'None', 'Error'], 2,
              T('The default return value is None.', 'डिफ़ॉल्ट रिटर्न मान None है।')),
        ],
      ),
    ],
  ),
  Course(
    id: 'flutter',
    name: 'Flutter',
    icon: Icons.flutter_dash,
    color: Color(0xFF0EA5E9),
    tagline: T('Build beautiful apps for any screen', 'हर स्क्रीन के लिए सुंदर ऐप बनाएँ'),
    lessons: [
      Lesson(
        'fl-1',
        T('Widgets and the widget tree', 'विजेट और विजेट ट्री'),
        T(
          'In Flutter, everything on screen is a widget. Widgets nest inside each other to form a tree. StatelessWidget describes UI that never changes by itself; StatefulWidget owns mutable state.',
          'Flutter में स्क्रीन की हर चीज़ एक विजेट है। विजेट एक-दूसरे के अंदर रखे जाकर ट्री बनाते हैं। StatelessWidget ऐसा UI बताता है जो अपने-आप नहीं बदलता; StatefulWidget बदलने वाली स्टेट रखता है।',
        ),
        'class Hello extends StatelessWidget {\n  const Hello({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return const Text(\'Hello, Flutter!\');\n  }\n}',
        [
          Mcq(T('Which method describes a widget\'s UI?', 'विजेट का UI कौन सी मेथड बताती है?'),
              ['render', 'build', 'draw', 'paint'], 1,
              T('build returns the widget subtree.', 'build विजेट का सबट्री लौटाती है।')),
          Mcq(T('Which widget type holds mutable state?', 'कौन सा विजेट बदलने वाली स्टेट रखता है?'),
              ['StatelessWidget', 'StatefulWidget', 'Text', 'Container'], 1,
              T('StatefulWidget pairs with a State object.', 'StatefulWidget एक State ऑब्जेक्ट के साथ आता है।')),
        ],
      ),
      Lesson(
        'fl-2',
        T('State and setState', 'स्टेट और setState'),
        T(
          'Call setState to tell Flutter that data changed so it rebuilds the widget. Keep state as local as possible, and move it up or into a state-management solution only when several widgets need it.',
          'डेटा बदलने पर Flutter को बताने के लिए setState कॉल करें ताकि विजेट दोबारा बने। स्टेट को जितना हो सके लोकल रखें, और जब कई विजेट को ज़रूरत हो तभी उसे ऊपर ले जाएँ या स्टेट-मैनेजमेंट इस्तेमाल करें।',
        ),
        'int count = 0;\n\nElevatedButton(\n  onPressed: () => setState(() => count++),\n  child: Text(\'Tapped \$count times\'),\n)',
        [
          Mcq(T('What does setState do?', 'setState क्या करती है?'),
              ['Saves to disk', 'Schedules a rebuild', 'Navigates', 'Closes the app'], 1,
              T('It marks the widget dirty so build runs again.', 'यह विजेट को अपडेट के लिए चिह्नित करती है ताकि build दोबारा चले।')),
          Mcq(T('Where is setState available?', 'setState कहाँ उपलब्ध है?'),
              ['StatelessWidget', 'State subclasses', 'Any function', 'Only main()'], 1,
              T('It is a method of the State class.', 'यह State क्लास की मेथड है।')),
        ],
      ),
      Lesson(
        'fl-3',
        T('Layouts: Row and Column', 'लेआउट: Row और Column'),
        T(
          'Row arranges children horizontally and Column vertically. Use mainAxisAlignment and crossAxisAlignment to position them, and Expanded to let a child fill the remaining space.',
          'Row बच्चों को क्षैतिज और Column ऊर्ध्वाधर सजाता है। उनकी स्थिति के लिए mainAxisAlignment और crossAxisAlignment इस्तेमाल करें, और बची हुई जगह भरने के लिए Expanded।',
        ),
        'Row(\n  children: [\n    const Icon(Icons.star),\n    const Expanded(child: Text(\'Rated 5 stars\')),\n    TextButton(onPressed: () {}, child: const Text(\'Rate\')),\n  ],\n)',
        [
          Mcq(T('Which widget arranges children vertically?', 'बच्चों को ऊर्ध्वाधर कौन सजाता है?'),
              ['Row', 'Column', 'Stack', 'Wrap'], 1,
              T('Column lays children top to bottom.', 'Column ऊपर से नीचे सजाता है।')),
          Mcq(T('Expanded is used to…', 'Expanded किसलिए है?'),
              ['Add padding', 'Fill remaining space in a Row/Column', 'Scroll content', 'Animate'], 1,
              T('It takes the leftover space along the main axis.', 'यह मुख्य अक्ष की बची जगह लेता है।')),
        ],
      ),
    ],
  ),
  Course(
    id: 'swift',
    name: 'Swift',
    icon: Icons.phone_iphone,
    color: Color(0xFFF43F5E),
    tagline: T('Modern, safe language for Apple platforms', 'Apple प्लेटफ़ॉर्म के लिए आधुनिक, सुरक्षित भाषा'),
    lessons: [
      Lesson(
        'sw-1',
        T('let, var and optionals', 'let, var और ऑप्शनल'),
        T(
          'Use let for constants and var for variables. An optional (Int?) may hold a value or nil. Unwrap it safely with if let, guard let or the ?? default operator instead of force-unwrapping with !.',
          'स्थिरांक के लिए let और वेरिएबल के लिए var इस्तेमाल करें। ऑप्शनल (Int?) में मान या nil हो सकता है। ! से ज़बरदस्ती खोलने के बजाय if let, guard let या ?? से सुरक्षित रूप से खोलें।',
        ),
        'let name = "Asha"\nvar age: Int? = nil\n\nif let a = age { print(a) } else { print("unknown") }\nprint(age ?? 18)',
        [
          Mcq(T('Which keyword declares a constant?', 'स्थिरांक घोषित करने का कीवर्ड?'),
              ['var', 'let', 'const', 'final'], 1,
              T('let creates an immutable binding.', 'let अपरिवर्तनीय बाइंडिंग बनाता है।')),
          Mcq(T('What is a safe way to unwrap an optional?', 'ऑप्शनल को सुरक्षित रूप से खोलने का तरीका?'),
              ['!', 'if let', 'as!', 'try!'], 1,
              T('if let only runs when a value exists.', 'if let तभी चलता है जब मान मौजूद हो।')),
        ],
      ),
      Lesson(
        'sw-2',
        T('Structs and classes', 'स्ट्रक्ट और क्लास'),
        T(
          'Structs are value types: assigning one copies it. Classes are reference types: assignments share the same instance. Prefer structs by default, and use classes when you need identity or inheritance.',
          'स्ट्रक्ट वैल्यू टाइप हैं: असाइन करने पर कॉपी बनती है। क्लास रेफरेंस टाइप हैं: असाइनमेंट एक ही इंस्टेंस साझा करता है। डिफ़ॉल्ट रूप से स्ट्रक्ट चुनें, और पहचान या इनहेरिटेंस चाहिए तब क्लास।',
        ),
        'struct Point { var x = 0 }\n\nvar a = Point()\nvar b = a      // copy\nb.x = 5\nprint(a.x)     // 0',
        [
          Mcq(T('Structs are…', 'स्ट्रक्ट क्या हैं?'),
              ['Reference types', 'Value types', 'Only for UI', 'Not copyable'], 1,
              T('Each assignment makes an independent copy.', 'हर असाइनमेंट स्वतंत्र कॉपी बनाता है।')),
          Mcq(T('Which supports inheritance?', 'इनहेरिटेंस किसमें है?'),
              ['struct', 'class', 'enum', 'All of them'], 1,
              T('Only classes can inherit.', 'सिर्फ़ क्लास इनहेरिट कर सकती हैं।')),
        ],
      ),
      Lesson(
        'sw-3',
        T('Protocols and extensions', 'प्रोटोकॉल और एक्सटेंशन'),
        T(
          'A protocol defines a set of requirements that types can adopt. Extensions add methods to existing types, and protocol extensions can provide default implementations.',
          'प्रोटोकॉल उन ज़रूरतों का समूह तय करता है जिन्हें टाइप अपना सकते हैं। एक्सटेंशन मौजूदा टाइप में मेथड जोड़ते हैं, और प्रोटोकॉल एक्सटेंशन डिफ़ॉल्ट इम्प्लीमेंटेशन दे सकते हैं।',
        ),
        'protocol Greeter { func greet() -> String }\n\nextension Greeter {\n  func shout() -> String { greet().uppercased() }\n}\n\nstruct English: Greeter {\n  func greet() -> String { "hello" }\n}',
        [
          Mcq(T('What does a protocol define?', 'प्रोटोकॉल क्या तय करता है?'),
              ['Stored data only', 'A blueprint of requirements', 'A database', 'A UI layout'], 1,
              T('It lists methods and properties a type must provide.', 'यह उन मेथड और प्रॉपर्टी की सूची है जो टाइप को देनी होती हैं।')),
          Mcq(T('What can an extension do?', 'एक्सटेंशन क्या कर सकता है?'),
              ['Add methods to an existing type', 'Delete a type', 'Compile faster', 'Change the language'], 0,
              T('Extensions add functionality to existing types.', 'एक्सटेंशन मौजूदा टाइप में सुविधाएँ जोड़ते हैं।')),
        ],
      ),
    ],
  ),
  Course(
    id: 'android',
    name: 'Android',
    icon: Icons.android,
    color: Color(0xFF16A34A),
    tagline: T('Kotlin and Jetpack Compose essentials', 'Kotlin और Jetpack Compose की मूल बातें'),
    lessons: [
      Lesson(
        'an-1',
        T('Activities and lifecycle', 'एक्टिविटी और लाइफसाइकल'),
        T(
          'An Activity is a single screen. The system calls lifecycle methods such as onCreate, onStart, onResume, onPause and onDestroy. Set up the UI in onCreate and release resources in onPause or onDestroy.',
          'Activity एक स्क्रीन होती है। सिस्टम onCreate, onStart, onResume, onPause और onDestroy जैसे लाइफसाइकल मेथड बुलाता है। UI onCreate में सेट करें और संसाधन onPause या onDestroy में छोड़ें।',
        ),
        'class MainActivity : AppCompatActivity() {\n  override fun onCreate(savedInstanceState: Bundle?) {\n    super.onCreate(savedInstanceState)\n    setContentView(R.layout.activity_main)\n  }\n}',
        [
          Mcq(T('Which callback runs first when an Activity is created?', 'Activity बनने पर सबसे पहले कौन सा कॉलबैक चलता है?'),
              ['onResume', 'onCreate', 'onDestroy', 'onPause'], 1,
              T('onCreate is the first lifecycle callback.', 'onCreate पहला लाइफसाइकल कॉलबैक है।')),
          Mcq(T('What is an Activity?', 'Activity क्या है?'),
              ['A background database', 'A single screen', 'A network protocol', 'A build tool'], 1,
              T('It hosts one screen of UI.', 'यह UI की एक स्क्रीन रखती है।')),
        ],
      ),
      Lesson(
        'an-2',
        T('Intents', 'इंटेंट'),
        T(
          'An Intent describes an action to perform. Explicit intents start a specific component such as another Activity; implicit intents ask the system to find an app that can handle an action, like sharing text.',
          'Intent किसी की जाने वाली क्रिया का वर्णन करता है। एक्सप्लिसिट इंटेंट किसी खास कंपोनेंट (जैसे दूसरी Activity) को शुरू करता है; इम्प्लिसिट इंटेंट सिस्टम से ऐसा ऐप ढूँढने को कहता है जो क्रिया संभाल सके, जैसे टेक्स्ट शेयर करना।',
        ),
        'val i = Intent(this, DetailActivity::class.java)\ni.putExtra("id", 42)\nstartActivity(i)',
        [
          Mcq(T('Which object describes the Activity to start?', 'शुरू की जाने वाली Activity का वर्णन कौन करता है?'),
              ['Bundle', 'Intent', 'Handler', 'Cursor'], 1,
              T('startActivity takes an Intent.', 'startActivity को Intent दिया जाता है।')),
          Mcq(T('An intent that names the exact target component is…', 'जो इंटेंट सटीक लक्ष्य कंपोनेंट बताए वह है…'),
              ['Implicit', 'Explicit', 'Broadcast', 'Pending'], 1,
              T('That is an explicit intent.', 'यह एक्सप्लिसिट इंटेंट है।')),
        ],
      ),
      Lesson(
        'an-3',
        T('Jetpack Compose basics', 'Jetpack Compose की बुनियाद'),
        T(
          'Jetpack Compose builds UI with Kotlin functions annotated with @Composable. When state changes, Compose recomposes only the affected parts. Hold state with remember and mutableStateOf.',
          'Jetpack Compose में UI @Composable से चिह्नित Kotlin फंक्शन से बनता है। स्टेट बदलने पर Compose सिर्फ़ प्रभावित हिस्सों को दोबारा बनाता है। स्टेट रखने के लिए remember और mutableStateOf इस्तेमाल करें।',
        ),
        '@Composable\nfun Counter() {\n  var n by remember { mutableStateOf(0) }\n  Button(onClick = { n++ }) { Text("Count \$n") }\n}',
        [
          Mcq(T('Which annotation marks a UI function in Compose?', 'Compose में UI फंक्शन को कौन सा एनोटेशन चिह्नित करता है?'),
              ['@UI', '@Composable', '@Widget', '@View'], 1,
              T('@Composable marks functions that emit UI.', '@Composable UI बनाने वाले फंक्शन को चिह्नित करता है।')),
          Mcq(T('Which API keeps state across recompositions?', 'रीकम्पोज़िशन के बीच स्टेट कौन रखता है?'),
              ['remember', 'static', 'final', 'lateinit'], 0,
              T('remember stores a value in the composition.', 'remember मान को कम्पोज़िशन में रखता है।')),
        ],
      ),
    ],
  ),
];

Course courseById(String id) => courses.firstWhere((c) => c.id == id);
