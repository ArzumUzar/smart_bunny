import 'package:flutter/material.dart';
import '../models/language.dart';
import '../models/level.dart';
import '../core/utils/colors.dart';

class LanguageDrawer extends StatelessWidget {
  final Language? selectedLanguage;
  final Level? selectedLevel;
  final Function(Language) onLanguageSelect;
  final Function(Level) onLevelSelect;

  const LanguageDrawer({
    Key? key,
    required this.selectedLanguage,
    required this.selectedLevel,
    required this.onLanguageSelect,
    required this.onLevelSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text('🐰', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text(
                    'Dil ve Seviye Seçimi',
                    style: TextStyle(color: AppColors.purple700, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Öğrenmek istediğin dili ve seviyeni seç', style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 32),
              const Text('Dil Seç', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              ...Language.values.map((lang) {
                final isSelected = selectedLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onLanguageSelect(lang),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.purple600 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text(lang.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          if (isSelected) const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              if (selectedLanguage != null) ...[
                const SizedBox(height: 24),
                const Text('Seviye Seç', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.8,
                  children: Level.values.map((level) {
                    final isSelected = selectedLevel == level;
                    return InkWell(
                      onTap: () => onLevelSelect(level),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.buttonGradient : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(level.code, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(level.description, style: TextStyle(color: isSelected ? Colors.white.withOpacity(0.8) : Colors.black54, fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}