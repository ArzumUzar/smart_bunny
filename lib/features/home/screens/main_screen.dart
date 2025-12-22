import 'package:flutter/material.dart';
import '../../../models/language.dart';
import '../../../models/level.dart';
import '../../../models/note.dart';
import '../../../widgets/language_drawer.dart';
import '../../../core/utils/colors.dart';
import 'home_view.dart';
import '../../quiz/screens/quiz_view.dart';
import '../../notes/screens/notes_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Language? selectedLanguage;
  Level? selectedLevel;
  int currentViewIndex = 0; // 0: home, 1: quiz, 2: notes
  List<Note> notes = [];

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
      setState(() => currentViewIndex = 1);
    }
  }

  void _addNote(Note note) => setState(() => notes.add(note));
  void _deleteNote(String id) => setState(() => notes.removeWhere((n) => n.id == id));
  
  void _updateNote(String id, String noteText) {
    setState(() {
      final index = notes.indexWhere((n) => n.id == id);
      if (index != -1) notes[index].note = noteText;
    });
  }

  void _goToHome() => setState(() => currentViewIndex = 0);
  void _goToNotes() => setState(() => currentViewIndex = 2);

  @override
  Widget build(BuildContext context) {
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _openDrawer,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.language, color: AppColors.primaryPurple, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('🐰', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Text('Smart Bunny', style: TextStyle(color: AppColors.purple700, fontSize: 20, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    InkWell(
                      onTap: _goToHome,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: currentViewIndex == 0 ? AppColors.purple100 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.book_outlined, color: AppColors.primaryPurple, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _goToNotes,
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: currentViewIndex == 2 ? AppColors.purple100 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.sticky_note_2_outlined, color: AppColors.primaryPurple, size: 20),
                          ),
                          if (notes.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.purple600, shape: BoxShape.circle),
                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                child: Text('${notes.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildCurrentView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (currentViewIndex == 0) {
      return HomeView(
        selectedLanguage: selectedLanguage,
        selectedLevel: selectedLevel,
        notesCount: notes.length,
        onOpenDrawer: _openDrawer,
        onStartQuiz: _startQuiz,
      );
    } else if (currentViewIndex == 1 && selectedLanguage != null && selectedLevel != null) {
      return QuizView(
        language: selectedLanguage!,
        level: selectedLevel!,
        onBack: _goToHome,
        onAddNote: _addNote,
      );
    } else if (currentViewIndex == 2) {
      return NotesView(
        notes: notes,
        onDeleteNote: _deleteNote,
        onUpdateNote: _updateNote,
      );
    }
    return HomeView(
      selectedLanguage: selectedLanguage,
      selectedLevel: selectedLevel,
      notesCount: notes.length,
      onOpenDrawer: _openDrawer,
      onStartQuiz: _startQuiz,
    );
  }
}