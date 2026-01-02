import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase
import '../../../models/language.dart';
import '../../../models/level.dart';
import '../../../models/note.dart'; // Note modelini import ettik
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
  
  int _currentIndex = 0; 
  
  // --- KULLANICI VERİLERİ ---
  String userName = "Yükleniyor...";
  int totalCarrots = 0;
  int savedNotesCount = 0; // Veritabanındaki not sayısı
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Ekran açılınca tüm verileri çek
  }

  // TÜM DASHBOARD VERİLERİNİ ÇEKME (PROFİL + NOT SAYISI)
  Future<void> _fetchDashboardData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final client = Supabase.instance.client;

      // 1. Profil Verisini Çek
      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // 2. Notların Sayısını Çek (Hepsini indirip sayısını alıyoruz)
      final notesData = await client
          .from('notes')
          .select('id') // Sadece ID'leri çekmek yeterli (performans için)
          .eq('user_id', userId);
      
      final List<dynamic> notesList = notesData;

      if (mounted) {
        setState(() {
          userName = profileData['full_name'] ?? 'Öğrenci';
          totalCarrots = profileData['total_score'] ?? 0;
          savedNotesCount = notesList.length; // Gerçek sayı burada!
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

  // Quiz bitince puanı güncelle ve ana sayfaya dön
  Future<void> _handleQuizFinish(int score, int totalQuestions) async {
    // Önce puanı güncelle
    setState(() {
      totalCarrots += score;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // 1. Puanı veritabanına yaz
      await Supabase.instance.client.from('profiles').update({
        'total_score': totalCarrots
      }).eq('id', userId);

      // 2. Not sayısını güncelle (Belki quizde yeni not ekledi)
      await _fetchDashboardData(); 

    } catch (e) {
      debugPrint('Puan güncelleme hatası: $e');
    }
  }

  // Quiz içinde not ekleyince bu çalışır (Anlık güncelleme için)
  void _onNoteAdded(Note note) {
    setState(() {
      savedNotesCount++; // Sayıyı manuel artır ki tekrar çekmeye gerek kalmasın
    });
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    // Notlar sayfasına (index 1) veya Ana sayfaya (index 0) basınca verileri tazele
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
          notesCount: savedNotesCount, // ARTIK VERİTABANINDAN GELEN DOĞRU SAYI!
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
               _fetchDashboardData(); // Quizden dönünce verileri tazele
            },
            onAddNote: _onNoteAdded, // Not eklenince sayıyı artır
            onFinish: _handleQuizFinish,
          );
        }
        return const Center(child: Text("Hata: Dil seçilmedi"));
      default:
        return const SizedBox();
    }
  }
}