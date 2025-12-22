import 'language.dart';
import 'level.dart';

class Note {
  final String id;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  String note;
  final Language language;
  final Level level;

  Note({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    this.note = '',
    required this.language,
    required this.level,
  });
}