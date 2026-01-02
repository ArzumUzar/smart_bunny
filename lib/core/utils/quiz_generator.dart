import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/language.dart';
import '../../models/level.dart';
import '../../models/question.dart';
import 'package:flutter/foundation.dart';

class QuizGenerator {
  
  static Future<List<Question>> generateQuestions(Language language, Level level) async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .eq('language', language.name.toLowerCase()) 
          .eq('level', level.code.toLowerCase())       
          .limit(20); 

      final List<dynamic> data = response;
      
      if (data.isEmpty) {
        return []; 
      }
      
      return data.map((json) => Question.fromJson(json)).toList();

    } catch (e) {
      debugPrint('Soru çekme hatası: $e');
      return [];
    }
  }
}