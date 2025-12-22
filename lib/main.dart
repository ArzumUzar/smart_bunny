import 'package:flutter/material.dart';
import 'core/utils/colors.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const SmartBunnyApp());
}

class SmartBunnyApp extends StatelessWidget {
  const SmartBunnyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bunny',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: Colors.transparent,
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
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.purple700,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: AppColors.purple700,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
      // Uygulama Giriş Ekranı ile başlar
      home: const LoginScreen(),
    );
  }
}
