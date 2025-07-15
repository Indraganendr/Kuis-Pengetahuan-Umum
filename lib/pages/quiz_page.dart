import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _answered = false;
  String _selectedAnswer = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadQuestions();
  }

  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'guest';
    });
  }

  void _loadQuestions() async {
    final data = await APIService.fetchQuestions();
    final formatted = data.map<Map<String, dynamic>>((q) {
      final answers = List<String>.from(q['incorrect_answers']);
      answers.add(q['correct_answer']);
      answers.shuffle();
      return {
        'question': q['question'],
        'correct': q['correct_answer'],
        'answers': answers,
      };
    }).toList();

    setState(() {
      _questions = formatted;
      _isLoading = false;
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    final correct = _questions[_currentIndex]['correct'];
    if (answer == correct) _score++;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
    });

    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = '';
      });
    } else {
      await DBService.saveScore(username: _username, score: _score);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(score: _score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat soal. Silakan coba lagi.')),
      );
    }

    final current = _questions[_currentIndex];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF83a4d4), Color(0xFFb6fbff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Soal ${_currentIndex + 1} / ${_questions.length}'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    current['question'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...current['answers'].map<Widget>((answer) {
                final isCorrect = answer == current['correct'];
                final isSelected = answer == _selectedAnswer;

                Color color = Colors.white;
                if (_answered) {
                  if (isSelected) {
                    color = isCorrect ? Colors.green.shade300 : Colors.red.shade300;
                  } else if (isCorrect) {
                    color = Colors.green.shade100;
                  }
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _selectAnswer(answer),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          answer,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final int score;

  const QuizResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFf6d365), Color(0xFFfda085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Hasil Kuis'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'Skor Anda: $score',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Kembali ke Beranda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
