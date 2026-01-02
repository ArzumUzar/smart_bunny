class RankService {
  static const String rankRookie = 'Çaylak Tavşan';
  static const String rankRunner = 'Hızlı Koşucu';
  static const String rankHunter = 'Havuç Avcısı';
  static const String rankLegend = 'Efsanevi Tavşan';

  static String getRank(int score) {
    if (score >= 100) return rankLegend;
    if (score >= 50) return rankHunter;
    if (score >= 20) return rankRunner;
    return rankRookie;
  }

  static int getNextTarget(int score) {
    if (score >= 100) return 100;
    if (score >= 50) return 100;
    if (score >= 20) return 50;
    return 20;
  }

  static double getProgress(int score) {
    if (score >= 100) return 1.0;
    
    int lowerBound = 0;
    int upperBound = 20;

    if (score >= 50) {
      lowerBound = 50;
      upperBound = 100;
    } else if (score >= 20) {
      lowerBound = 20;
      upperBound = 50;
    } 
    
    return (score - lowerBound) / (upperBound - lowerBound);
  }
}