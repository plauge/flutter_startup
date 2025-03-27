/// Håndterer generering af spørgsmål og svar til bekræftelsesprocessen.
///
/// Denne fil indeholder funktionalitet til at generere tilfældige matematiske spørgsmål
/// og beregne de korrekte svar, som bruges i bekræftelsesprocessen.

import 'dart:math' as math;
import 'dart:developer' as developer;

/// En klasse til at generere spørgsmål og svar til bekræftelsesprocessen
class ConfirmQuestionGenerator {
  /// Genererer en streng med to tilfældige tal (1-999) adskilt af et komma
  /// og beregner summen af tallene som returneres i et map med 'question' og 'answer'
  static Map<String, String> generateQuestionAndAnswer() {
    final random = math.Random();
    final int firstNumber = random.nextInt(999) + 1; // 1-999
    final int secondNumber = random.nextInt(999) + 1; // 1-999
    final String questionString = "$firstNumber,$secondNumber";

    // Beregn summen
    final int sum = firstNumber + secondNumber;
    final String answerString = sum.toString();

    developer.log(
        'Genererede ny spørgsmålsstreng: $questionString, svar: $answerString',
        name: 'ConfirmQuestionGenerator');

    return {
      'question': questionString,
      'answer': answerString,
    };
  }
}
