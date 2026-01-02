import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'core/utils/colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rdoajcrhplkvwzecxffk.supabase.co', 
    anonKey: 'sb_publishable_-A9IAJAHUlkC_HFOxg_Udw_tzvZSc-a', 
  );

  runApp(const SmartBunnyApp());
}

class SmartBunnyApp extends StatelessWidget {
  const SmartBunnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    return MaterialApp(
      title: 'Smart Bunny',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: Colors.white, 
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
      home: session != null ? const MainScreen() : const LoginScreen(),
    );
  }
}