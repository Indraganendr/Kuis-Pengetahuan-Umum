import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart'; // Tambahkan ini di pubspec.yaml

class APIService {
  static Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final url = Uri.parse('https://opentdb.com/api.php?amount=5&type=multiple');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final unescape = HtmlUnescape(); // Untuk decode HTML special characters
      final data = jsonDecode(response.body);

      return (data['results'] as List).map<Map<String, dynamic>>((q) {
        return {
          'question': unescape.convert(q['question']),
          'correct_answer': unescape.convert(q['correct_answer']),
          'incorrect_answers': List<String>.from(q['incorrect_answers'].map((a) => unescape.convert(a))),
        };
      }).toList();
    } else {
      throw Exception('Gagal memuat soal dari API');
    }
  }
}
