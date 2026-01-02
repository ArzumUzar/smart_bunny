import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ekle
import 'core/utils/colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_screen.dart'; // MainScreen'i import et

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Başlatma
  await Supabase.initialize(
    url: 'https://rdoajcrhplkvwzecxffk.supabase.co', // Supabase URL'ini yapıştır
    anonKey: 'sb_publishable_-A9IAJAHUlkC_HFOxg_Udw_tzvZSc-a', // 'sb_publishable' ile başlayan key'i yapıştır
  );

  runApp(const SmartBunnyApp());
}

class SmartBunnyApp extends StatelessWidget {
  const SmartBunnyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Eğer kullanıcı daha önce giriş yapmışsa direkt Ana Ekrana at
    final session = Supabase.instance.client.auth.currentSession;
    
    return MaterialApp(
      title: 'Smart Bunny',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: Colors.white, // Arkaplan rengini sabitledik
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: AppColors.primaryPurple),
          titleTextStyle: TextStyle(
            color: AppColors.purple700,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Oturum varsa MainScreen, yoksa LoginScreen açılır
      home: session != null ? const MainScreen() : const LoginScreen(),
    );
  }
}