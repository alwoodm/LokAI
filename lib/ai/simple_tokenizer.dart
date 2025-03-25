/// Prosty tokenizer do szacowania liczby tokenów w tekście
/// 
/// Ta implementacja jest uproszczona i służy tylko do demonstracji.
/// W rzeczywistej aplikacji należałoby użyć bardziej zaawansowanego tokenizera,
/// który jest zgodny z wykorzystywanym modelem AI.
class SimpleTokenizer {
  /// Dzieli tekst na przybliżone tokeny i zwraca ich liczbę
  /// Uproszczona implementacja zakłada, że średnio 4 znaki to jeden token
  static int countTokens(String text) {
    if (text.isEmpty) {
      return 0;
    }
    
    // Bardzo uproszczona metoda liczenia tokenów
    // W rzeczywistości powinno się użyć tokenizerów odpowiednich dla danego modelu
    const double avgCharsPerToken = 4.0;
    
    // Usuwamy białe znaki, które nie są istotne dla liczenia tokenów
    final trimmedText = text.trim();
    
    // Liczba tokenów to przybliżona liczba znaków podzielona przez średnią długość tokena
    return (trimmedText.length / avgCharsPerToken).ceil();
  }
  
  /// Pobiera pierwsze n tokenów z tekstu
  static String truncateToTokenLimit(String text, int maxTokens) {
    if (text.isEmpty || maxTokens <= 0) {
      return '';
    }
    
    // Bardzo uproszczona metoda obcinania do limitu tokenów
    const double avgCharsPerToken = 4.0;
    final maxChars = (maxTokens * avgCharsPerToken).floor();
    
    if (text.length <= maxChars) {
      return text;
    }
    
    return '${text.substring(0, maxChars)}...';
  }
}
