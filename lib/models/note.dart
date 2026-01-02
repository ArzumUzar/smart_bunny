class Note {
  final String id;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  String note;
  final String language; 
  final String level;    

  Note({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    this.note = '',
    required this.language,
    required this.level,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      question: json['question'],
      correctAnswer: json['correct_answer'],
      userAnswer: json['user_answer'],
      note: json['user_note'] ?? '', 
      language: json['language'] ?? 'English',
      level: json['level'] ?? 'A1',
    );
  }
}