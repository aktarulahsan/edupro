class QuestionResult {
  final int questionId;
  final String questionText;
  final bool isCorrect;
  final List<String> selectedAnswers;
  final List<String> correctAnswers;
  final String? explanation;

  QuestionResult({
    required this.questionId,
    required this.questionText,
    required this.isCorrect,
    required this.selectedAnswers,
    required this.correctAnswers,
    this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['question_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      selectedAnswers: (json['selected_answers'] as List? ?? []).cast<String>(),
      correctAnswers: (json['correct_answers'] as List? ?? []).cast<String>(),
      explanation: json['explanation'],
    );
  }
}
