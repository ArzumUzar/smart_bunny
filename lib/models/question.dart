class Question {
  final String id; 
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'].toString(),
      question: json['question_text'], 
      options: List<String>.from(json['options']), 
      correctAnswer: json['correct_answer'],
    );
  }
}