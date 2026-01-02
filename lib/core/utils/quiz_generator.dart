import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/language.dart';
import '../../models/level.dart';
import '../../models/question.dart';

class QuizGenerator {
  
  // Veritabanından soruları çeken asenkron fonksiyon
  static Future<List<Question>> generateQuestions(Language language, Level level) async {
    try {
      // 1. Supabase'e istek at: "Bu dil ve seviyedeki soruları getir"
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .eq('language', language.name.toLowerCase()) // örn: 'english'
          .eq('level', level.code.toLowerCase())       // örn: 'a1'
          .limit(20); // En fazla 20 soru getir

      // 2. Gelen veriyi listeye çevir
      final List<dynamic> data = response;
      
      if (data.isEmpty) {
        return []; // Soru yoksa boş liste dön
      }
      
      // 3. JSON verisini Question objesine dönüştür
      return data.map((json) => Question.fromJson(json)).toList();

    } catch (e) {
      // Hata olursa (İnternet yoksa vs.) konsola yaz ve boş dön
      print('Soru çekme hatası: $e');
      return [];
    }
  }
}