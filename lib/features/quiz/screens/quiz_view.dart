import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Not kaydı için gerekli
import '../../../models/language.dart';
import '../../../models/level.dart';
import '../../../models/question.dart';
import '../../../models/note.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/quiz_generator.dart';

class QuizView extends StatefulWidget {
  final Language language;
  final Level level;
  final VoidCallback onBack;
  final Function(Note) onAddNote;
  final Function(int score, int totalQuestions) onFinish;

  const QuizView({
    Key? key, 
    required this.language, 
    required this.level, 
    required this.onBack, 
    required this.onAddNote,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<Question> questions = []; // Sorular listesi
  bool isLoading = true;         // Yükleniyor mu?
  
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  int score = 0;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Ekran açılınca soruları çek
  }

  // SORULARI İNTERNETTEN ÇEKME FONKSİYONU
  Future<void> _loadQuestions() async {
    final fetchedQuestions = await QuizGenerator.generateQuestions(widget.language, widget.level);
    
    if (mounted) {
      setState(() {
        questions = fetchedQuestions;
        isLoading = false; // Yükleme bitti
      });
    }
  }

  Question get currentQuestion => questions[currentQuestionIndex];
  double get progress => (currentQuestionIndex + 1) / questions.length;

  void _selectAnswer(String answer) {
    if (isAnswered) return;
    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      if (answer == currentQuestion.correctAnswer) score++;
    });
  }

  void _handleNext() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
      });
    } else {
      setState(() {
        showResult = true;
      });
      widget.onFinish(score, questions.length);
    }
  }

  // NOTLARI SUPABASE'E KAYDETME (GÜNCELLENDİ)
  Future<void> _saveToNotes() async {
    if (selectedAnswer != null && selectedAnswer != currentQuestion.correctAnswer) {
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        
        // 1. Veritabanına Kaydet
        await Supabase.instance.client.from('notes').insert({
          'user_id': userId,
          'question': currentQuestion.question,
          'correct_answer': currentQuestion.correctAnswer,
          'user_answer': selectedAnswer,
          'language': widget.language.name,
          'level': widget.level.code,
        });

        // 2. RAM'deki listeye de ekle (Anlık görüntülemek için)
        final note = Note(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          question: currentQuestion.question,
          correctAnswer: currentQuestion.correctAnswer,
          userAnswer: selectedAnswer!,
         language: widget.language.name,  // .name ekledik (Enum -> String oldu)
          level: widget.level.code,        // .code ekledik (Enum -> String oldu)
        );
        widget.onAddNote(note);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not veritabanına kaydedildi!'), backgroundColor: AppColors.purple600));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not kaydedilemedi!'), backgroundColor: Colors.red));
        }
      }
    }
  }

  String _getResultEmoji() {
    if (questions.isEmpty) return '😐';
    final percentage = (score / questions.length) * 100;
    if (percentage >= 80) return '🎉';
    if (percentage >= 60) return '🐰';
    return '🥕';
  }

  @override
  Widget build(BuildContext context) {
    // 1. YÜKLENİYORSA
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryPurple),
              SizedBox(height: 16),
              Text("Sorular Hazırlanıyor... 🥕"),
            ],
          ),
        ),
      );
    }

    // 2. SORU YOKSA
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🤷‍♂️', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('${widget.language.name} - ${widget.level.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Bu seviye için henüz soru eklenmemiş.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 3. SONUÇ EKRANI
    if (showResult) return _buildResultScreen();

    // 4. NORMAL QUIZ EKRANI (Senin eski tasarımın korundu)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back, color: AppColors.purple600)),
              const Spacer(),
              Text('${widget.language.name} - ${widget.level.code}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Soru ${currentQuestionIndex + 1} / ${questions.length}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              Text('🥕 $score puan', style: const TextStyle(fontSize: 14, color: AppColors.purple600, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.purple600)),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentQuestion.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 20),
                ...currentQuestion.options.map((option) {
                  final isCorrect = option == currentQuestion.correctAnswer;
                  final isSelected = option == selectedAnswer;
                  Color backgroundColor = Colors.white;
                  Color borderColor = Colors.grey.shade200;
                  Color textColor = Colors.black87;
                  Widget? trailing;

                  if (isAnswered) {
                    if (isCorrect) {
                      backgroundColor = Colors.green.shade50;
                      borderColor = Colors.green;
                      textColor = Colors.green.shade700;
                      trailing = const Icon(Icons.check, color: Colors.green);
                    } else if (isSelected) {
                      backgroundColor = Colors.red.shade50;
                      borderColor = Colors.red;
                      textColor = Colors.red.shade700;
                      trailing = const Icon(Icons.close, color: Colors.red);
                    } else {
                      textColor = Colors.grey.shade500;
                    }
                  } else if (isSelected) {
                    backgroundColor = AppColors.purple50;
                    borderColor = AppColors.primaryPurple;
                    textColor = AppColors.purple700;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isAnswered ? null : () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 2)),
                        child: Row(
                          children: [
                            Expanded(child: Text(option, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))),
                            if (trailing != null) trailing,
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (isAnswered)
            Row(
              children: [
                if (selectedAnswer != currentQuestion.correctAnswer)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveToNotes,
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.purple600, side: const BorderSide(color: AppColors.purple100), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('📝 Notlara Ekle'),
                    ),
                  ),
                if (selectedAnswer != currentQuestion.correctAnswer) const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(8)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleNext,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentQuestionIndex < questions.length - 1 ? 'Sonraki Soru' : 'Sonuçları Gör', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Text('🥕', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (score / questions.length) * 100;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple50, Color(0xFFE0F2FE)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(_getResultEmoji(), style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text('Quiz Tamamlandı!', style: TextStyle(color: AppColors.purple700, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${widget.language.name} - ${widget.level.code}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('$score / ${questions.length}', style: const TextStyle(color: AppColors.primaryPurple, fontSize: 40, fontWeight: FontWeight.bold)),
                      const Text('Doğru Cevap', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: score / questions.length, minHeight: 12, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.purple600)),
                      ),
                      const SizedBox(height: 8),
                      Text('%${percentage.toStringAsFixed(0)} Başarı', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(8)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🥕', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 12),
                          Text('Ana Sayfaya Dön', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}