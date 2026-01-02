class Note {
  final String id;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  String note;
  final String language; // String olarak değiştirdik (Supabase uyumu için)
  final String level;    // String olarak değiştirdik

  Note({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    this.note = '',
    required this.language,
    required this.level,
  });

  // Supabase'den gelen veriyi modele çevir
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      question: json['question'],
      correctAnswer: json['correct_answer'],
      userAnswer: json['user_answer'],
      note: json['user_note'] ?? '', // Eğer not yoksa boş gelsin
      language: json['language'] ?? 'English',
      level: json['level'] ?? 'A1',
    );
  }
}