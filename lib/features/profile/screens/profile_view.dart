import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase
import '../../../core/utils/colors.dart';
import '../../../core/utils/rank_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfileView extends StatelessWidget {
  final String userName; // İsim parametresi eklendi
  final int totalScore;

  const ProfileView({
    Key? key,
    required this.userName,
    required this.totalScore,
  }) : super(key: key);

  // GERÇEK ÇIKIŞ İŞLEMİ
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Supabase oturumunu kapat
    await Supabase.instance.client.auth.signOut();

    // 2. Login ekranına at
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRank = RankService.getRank(totalScore);
    final nextTarget = RankService.getNextTarget(totalScore);
    final progressValue = RankService.getProgress(totalScore);
    final remaining = nextTarget - totalScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple600, width: 3),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.purple100,
              child: Text('🐰', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 16),
          
          // VERİTABANINDAN GELEN İSİM
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.purple100)
            ),
            child: Text(
              currentRank,
              style: const TextStyle(color: AppColors.purple700, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primaryPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🥕 $totalScore Havuç', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if(totalScore < 100)
                    Text('Hedef: $nextTarget', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                if(totalScore < 100)
                  Text(
                    'Bir sonraki rütbeye $remaining havuç kaldı!',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  )
                else
                  const Text(
                    'Tebrikler! En üst rütbeye ulaştın! 🎉',
                    style: TextStyle(fontSize: 12, color: AppColors.purple600, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          
          TextButton.icon(
            onPressed: () => _handleLogout(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Çıkış Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}