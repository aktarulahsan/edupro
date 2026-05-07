import 'package:edupro/infrastructure/dal/model/question_result.dart';
import 'package:edupro/infrastructure/dal/model/rankInfo.dart';

class SubmitQuizResponse {
  final bool success;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double percentage;
  final bool passed;
  final int totalXP;
  final int gainedXP;
  final String message;
  final RankInfo? rank;
  final List<QuestionResult> questionResults;

  SubmitQuizResponse({
    required this.success,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.percentage,
    required this.passed,
    required this.totalXP,
    required this.gainedXP,
    required this.message,
    this.rank,
    required this.questionResults,
  });

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) {
    return SubmitQuizResponse(
      success: json['success'] ?? false,
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      incorrectAnswers: json['incorrect_answers'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      totalXP: json['total_xp'] ?? 0,
      gainedXP: json['gained_xp'] ?? 0,
      message: json['message'] ?? '',
      rank: json['rank'] != null ? RankInfo.fromJson(json['rank']) : null,
      questionResults: (json['question_results'] as List? ?? [])
          .map((e) => QuestionResult.fromJson(e))
          .toList(),
    );
  }
}
