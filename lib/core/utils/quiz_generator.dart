import '../../models/language.dart';
import '../../models/level.dart';
import '../../models/question.dart';

class QuizGenerator {
  static List<Question> generateQuestions(Language language, Level level) {
    // Almanca kaldırıldı, sadece İngilizce ve Fransızca şablonları kaldı.
    final Map<Language, List<Map<String, dynamic>>> templates = {
      Language.english: [
        {'question': 'What ___ your name?', 'options': ['is', 'are', 'am', 'be'], 'correct': 0},
        {'question': 'She ___ to school every day.', 'options': ['go', 'goes', 'going', 'gone'], 'correct': 1},
        {'question': 'I ___ a student.', 'options': ['is', 'are', 'am', 'be'], 'correct': 2},
        {'question': 'They ___ playing football.', 'options': ['is', 'am', 'are', 'be'], 'correct': 2},
        {'question': 'Where ___ you live?', 'options': ['does', 'do', 'is', 'are'], 'correct': 1},
      ],
      Language.french: [
        {'question': 'Je ___ français.', 'options': ['parle', 'parles', 'parlons', 'parlent'], 'correct': 0},
        {'question': 'Tu ___ étudiant.', 'options': ['suis', 'es', 'est', 'sont'], 'correct': 1},
        {'question': 'Nous ___ à Paris.', 'options': ['habite', 'habites', 'habitons', 'habitent'], 'correct': 2},
        {'question': 'Elle ___ un livre.', 'options': ['lis', 'lit', 'lisons', 'lisent'], 'correct': 1},
        {'question': 'Vous ___ français?', 'options': ['parle', 'parles', 'parlez', 'parlent'], 'correct': 2},
      ],
    };

    // Eğer belirtilen dil şablonda yoksa varsayılan olarak İngilizceyi al
    final baseQuestions = templates[language] ?? templates[Language.english]!;
    final List<Question> questions = [];

    // 20 soru oluştur (5 şablonu 4 kez tekrarla)
    for (int i = 0; i < 20; i++) {
      final template = baseQuestions[i % baseQuestions.length];
      questions.add(Question(
        id: 'q-$i',
        question: '${i + 1}. ${template['question']}',
        options: List<String>.from(template['options']),
        correctAnswer: template['options'][template['correct']],
      ));
    }

    return questions;
  }
}