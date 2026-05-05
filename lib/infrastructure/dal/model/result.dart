import 'dart:convert';

class Result {
  int? count;
  int totalQuestions;
  int answeredQuestions;
  int correctAnswers;
  int incorrectAnswers;
  int skippedQuestions;
  double percentage;
  String grade;
  String feedback;
  bool isPassed;

  Result({
    this.count,
    this.totalQuestions = 0,
    this.answeredQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedQuestions = 0,
    this.percentage = 0.0,
    this.grade = '',
    this.feedback = '',
    this.isPassed = false,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    count: json["count"],
    totalQuestions: json['totalQuestions'] ?? 0,
    answeredQuestions: json['answeredQuestions'] ?? 0,
    correctAnswers: json['correctAnswers'] ?? 0,
    incorrectAnswers: json['incorrectAnswers'] ?? 0,
    skippedQuestions: json['skippedQuestions'] ?? 0,
    percentage: (json['percentage'] ?? 0).toDouble(),
    grade: json['grade'] ?? 'N/A',
    feedback: json['feedback'] ?? '',
    isPassed: json['isPassed'] ?? false,

  );

  Map<String, dynamic> toJson() => {
    "count": count,
    'totalQuestions': totalQuestions,
    'answeredQuestions': answeredQuestions,
    'correctAnswers': correctAnswers,
    'incorrectAnswers': incorrectAnswers,
    'skippedQuestions': skippedQuestions,
    'percentage': percentage,
    'grade': grade,
    'feedback': feedback,
    'isPassed': isPassed,
    'timestamp': DateTime.now().toIso8601String(),
  };

  setCount(count){
    this.count = count;
  }
  int? getCount(){
    return count!;
  }

}

