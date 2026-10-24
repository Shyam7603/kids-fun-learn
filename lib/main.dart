import 'package:flutter/material.dart';

void main() => runApp(const KidsApp());

class KidsApp extends StatelessWidget {
  const KidsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kids Fun Learn',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFF8E1),
          colorSchemeSeed: Colors.orange,
        ),
        home: const HomeScreen(),
      );
}

class Question {
  final String prompt;
  final String emoji;
  final List<String> options;
  final int answer;

  Question(this.prompt, this.emoji, this.options, this.answer);
}

final alphabetQs = [
  Question('A is for ___', '🍎', ['Apple', 'Ball', 'Cat'], 0),
  Question('B is for ___', '⚽', ['Dog', 'Ball', 'Egg'], 1),
  Question('C is for ___', '🐱', ['Cat', 'Fish', 'Sun'], 0),
];

final countingQs = [
  Question('How many?', '🍎🍎🍎', ['2', '3', '4'], 1),
  Question('How many?', '⭐⭐⭐⭐⭐', ['5', '3', '6'], 0),
  Question('How many?', '🐶🐶', ['1', '2', '3'], 1),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <List<dynamic>>[
      ['🔤 Alphabet', Colors.pink, () => QuizScreen('Alphabet', alphabetQs)],
      ['🔢 Counting', Colors.blue, () => QuizScreen('Counting', countingQs)],
      ['🧠 Memory', Colors.green, () => const MemoryScreen()],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Kids Fun Learn')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: games
            .map((g) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => g[2]() as Widget),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: g[1] as Color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g[0] as String,
                      style: const TextStyle(fontSize: 26, color: Colors.white),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> qs;

  const QuizScreen(this.title, this.qs, {super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int i = 0;
  int score = 0;

  void pick(int choice) {
    final correct = choice == widget.qs[i].answer;
    if (correct) score++;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(correct ? '🎉 Great job!' : '😅 Oops!'),
      duration: const Duration(milliseconds: 700),
      backgroundColor: correct ? Colors.green : Colors.red,
    ));
    setState(() => i++);
  }

  @override
  Widget build(BuildContext context) {
    if (i >= widget.qs.length) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('⭐ Score: $score/${widget.qs.length}',
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back Home'),
            ),
          ]),
        ),
      );
    }
    final q = widget.qs[i];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(q.prompt, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 16),
          Text(q.emoji, style: const TextStyle(fontSize: 70)),
          const SizedBox(height: 24),
          ...List.generate(
            q.options.length,
            (n) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => pick(n),
                  child: Text(q.options[n],
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late List<String> cards;
  late List<bool> shown;
  late List<bool> matched;
  int? first;

  @override
  void initState() {
    super.initState();
    cards = ['🐶', '🐱', '🐵', '🐼', '🐶', '🐱', '🐵', '🐼']..shuffle();
    shown = List.filled(8, false);
    matched = List.filled(8, false);
  }

  void tap(int i) async {
    if (shown[i] || matched[i]) return;
    setState(() => shown[i] = true);
    if (first == null) {
      first = i;
      return;
    }
    final a = first!;
    first = null;
    if (cards[a] == cards[i]) {
      setState(() => matched[a] = matched[i] = true);
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => shown[a] = shown[i] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final won = matched.every((m) => m);
    return Scaffold(
      appBar: AppBar(title: Text(won ? '🎉 You won!' : 'Memory Match')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => tap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: shown[i] || matched[i] ? Colors.white : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(shown[i] || matched[i] ? cards[i] : '❓',
                style: const TextStyle(fontSize: 34)),
          ),
        ),
      ),
    );
  }
}
