class Question {
  final String id; // Veritabanındaki ID (int8) string olarak tutulabilir
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  // Supabase'den gelen veriyi modele çeviren sihirli fonksiyon 🪄
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'].toString(),
      question: json['question_text'], // Tablodaki sütun adı: question_text
      // Veritabanından gelen listeyi String listesine çeviriyoruz
      options: List<String>.from(json['options']), 
      correctAnswer: json['correct_answer'],
    );
  }
}