// Dosya: lib/features/home/screens/main_screen.dart

import 'package:flutter/material.dart';
import '../../../models/language.dart';
import '../../../models/level.dart';
import '../../../models/note.dart';
import '../../../widgets/language_drawer.dart';
import '../../../core/utils/colors.dart';
import 'home_view.dart';
import '../../quiz/screens/quiz_view.dart';
import '../../notes/screens/notes_view.dart';
import '../../profile/screens/profile_view.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Language? selectedLanguage;
  Level? selectedLevel;
  
  // 0: Home, 1: Notes, 2: Profile, 3: Quiz
  int _currentIndex = 0; 
  
  List<Note> notes = [];

  // --- OYUNLAŞTIRMA PUANLARI ---
  int totalCarrots = 15; // Başlangıç puanı
  int totalCorrect = 5;
  int totalWrong = 2;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _handleLanguageSelect(Language language) {
    setState(() {
      selectedLanguage = language;
      selectedLevel = null;
    });
  }

  void _handleLevelSelect(Level level) {
    setState(() => selectedLevel = level);
    Navigator.pop(context); 
  }

  void _startQuiz() {
    if (selectedLanguage != null && selectedLevel != null) {
      setState(() => _currentIndex = 3); // Quiz modu
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce dil ve seviye seçin!')),
      );
    }
  }

  // Quiz Bittiğinde Puanları Güncelle
  void _handleQuizFinish(int score, int totalQuestions) {
    setState(() {
      totalCarrots += score;
      totalCorrect += score;
      totalWrong += (totalQuestions - score);
      
      _currentIndex = 0; // Ana sayfaya dön
    });
  }

  void _addNote(Note note) => setState(() => notes.add(note));
  void _deleteNote(String id) => setState(() => notes.removeWhere((n) => n.id == id));
  void _updateNote(String id, String noteText) {
    setState(() {
      final index = notes.indexWhere((n) => n.id == id);
      if (index != -1) notes[index].note = noteText;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isQuizMode = _currentIndex == 3;

    return Scaffold(
      key: _scaffoldKey,
      drawer: LanguageDrawer(
        selectedLanguage: selectedLanguage,
        selectedLevel: selectedLevel,
        onLanguageSelect: _handleLanguageSelect,
        onLevelSelect: _handleLevelSelect,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Bar (Sadece Home'da ve Quiz dışında göster)
              if (!isQuizMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      if (_currentIndex == 0)
                        InkWell(
                          onTap: _openDrawer,
                          child: const Icon(Icons.sort, color: AppColors.purple700, size: 28),
                        ),
                      const SizedBox(width: 12),
                      const Text('🐰 Smart Bunny', style: TextStyle(color: AppColors.purple700, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🥕', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text('$totalCarrots', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: isQuizMode ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Notlarım'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profilim'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeView(
          selectedLanguage: selectedLanguage,
          selectedLevel: selectedLevel,
          notesCount: notes.length,
          onOpenDrawer: _openDrawer,
          onStartQuiz: _startQuiz,
        );
      case 1:
        return NotesView(
          notes: notes,
          onDeleteNote: _deleteNote,
          onUpdateNote: _updateNote,
        );
      case 2:
        return ProfileView(
          totalScore: totalCarrots,
          correctCount: totalCorrect,
          wrongCount: totalWrong,
        );
      case 3:
        if (selectedLanguage != null && selectedLevel != null) {
          return QuizView(
            language: selectedLanguage!,
            level: selectedLevel!,
            onBack: () => setState(() => _currentIndex = 0),
            onAddNote: _addNote,
            onFinish: _handleQuizFinish, // Yeni parametre
          );
        }
        return const Center(child: Text("Hata: Dil seçilmedi"));
      default:
        return const SizedBox();
    }
  }
}