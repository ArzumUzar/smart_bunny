import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
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
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Language? selectedLanguage;
  Level? selectedLevel;
  
  int _currentIndex = 0; 
  
  String userName = "Yükleniyor...";
  int totalCarrots = 0;
  int savedNotesCount = 0; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); 
  }

  Future<void> _fetchDashboardData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final client = Supabase.instance.client;

      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final notesData = await client
          .from('notes')
          .select('id') 
          .eq('user_id', userId);
      
      final List<dynamic> notesList = notesData;

      if (mounted) {
        setState(() {
          userName = profileData['full_name'] ?? 'Öğrenci';
          totalCarrots = profileData['total_score'] ?? 0;
          savedNotesCount = notesList.length; 
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Veri çekme hatası: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _handleLanguageSelect(Language language) {
    setState(() {
      selectedLanguage = language;
      selectedLevel = null;
    });
    Navigator.pop(context); 
  }

  void _handleLevelSelect(Level level) {
    setState(() => selectedLevel = level);
    Navigator.pop(context);
  }

  void _startQuiz() {
    if (selectedLanguage != null && selectedLevel != null) {
      setState(() => _currentIndex = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce dil ve seviye seçin!')),
      );
    }
  }

  Future<void> _handleQuizFinish(int score, int totalQuestions) async {
    setState(() {
      totalCarrots += score;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      await Supabase.instance.client.from('profiles').update({
        'total_score': totalCarrots
      }).eq('id', userId);

      await _fetchDashboardData(); 

    } catch (e) {
      debugPrint('Puan güncelleme hatası: $e');
    }
  }

  void _onNoteAdded(Note note) {
    setState(() {
      savedNotesCount++; 
    });
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0 || index == 1) {
      _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isQuizMode = _currentIndex == 3;
    
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
      );
    }

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
                          color: Colors.orange.withValues(alpha: 0.2),
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
              Expanded(child: _buildBody()),
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
          notesCount: savedNotesCount, 
          onOpenDrawer: _openDrawer,
          onStartQuiz: _startQuiz,
        );
      case 1:
        return const NotesView(); 
      case 2:
        return ProfileView(
          userName: userName,
          totalScore: totalCarrots,
        );
      case 3:
        if (selectedLanguage != null && selectedLevel != null) {
          return QuizView(
            language: selectedLanguage!,
            level: selectedLevel!,
            onBack: () {
               setState(() => _currentIndex = 0);
               _fetchDashboardData(); 
            },
            onAddNote: _onNoteAdded, 
            onFinish: _handleQuizFinish,
          );
        }
        return const Center(child: Text("Hata: Dil seçilmedi"));
      default:
        return const SizedBox();
    }
  }
}