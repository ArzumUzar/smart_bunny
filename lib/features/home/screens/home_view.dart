import 'package:flutter/material.dart';
import '../../../models/language.dart';
import '../../../models/level.dart';
import '../../../core/utils/colors.dart';

class HomeView extends StatelessWidget {
  final Language? selectedLanguage;
  final Level? selectedLevel;
  final int notesCount;
  final VoidCallback onOpenDrawer;
  final VoidCallback onStartQuiz;

  const HomeView({
    super.key,
    required this.selectedLanguage,
    required this.selectedLevel,
    required this.notesCount,
    required this.onOpenDrawer,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('🐰', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('Hoş Geldin!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Dil öğrenme yolculuğuna başlamak için bir dil ve seviye seç', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple100),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seçimlerim', style: TextStyle(color: AppColors.purple700, fontSize: 18, fontWeight: FontWeight.w600)),
                    OutlinedButton(
                      onPressed: onOpenDrawer,
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.purple600, side: const BorderSide(color: AppColors.purple100)),
                      child: const Text('Değiştir', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dil', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(selectedLanguage?.name ?? 'Dil seçilmedi', style: const TextStyle(color: AppColors.purple700, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seviye', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(selectedLevel?.code ?? 'Seviye seçilmedi', style: const TextStyle(color: AppColors.purple700, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: selectedLanguage != null && selectedLevel != null ? AppColors.buttonGradient : null,
              color: selectedLanguage == null || selectedLevel == null ? Colors.grey[300] : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: selectedLanguage != null && selectedLevel != null ? [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))] : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectedLanguage != null && selectedLevel != null ? onStartQuiz : null,
                borderRadius: BorderRadius.circular(30),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🥕', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Text('Quiz Başlat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.purpleCardGradient, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('🥕', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 8),
                      const Text('Toplam Not', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text('$notesCount', style: const TextStyle(color: AppColors.purple700, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.blueCardGradient, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 8),
                      const Text('Aktif Seviye', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(selectedLevel?.code ?? '-', style: const TextStyle(color: AppColors.primaryPurple, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}