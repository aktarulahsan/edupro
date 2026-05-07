// scoreboard_model.dart
class DashboardData {
  final int studentId;
  final int totalSubmissions;
  final int totalSetsAttempted;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalScore;
  final int totalPossibleScore;
  final double averagePercentage;
  final double averageTimeSpent;
  final int passedCount;
  final int failedCount;
  final Submission? bestSubmission;
  final Submission? latestSubmission;
  final List<Submission> recentSubmissions;

  DashboardData({
    required this.studentId,
    required this.totalSubmissions,
    required this.totalSetsAttempted,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalScore,
    required this.totalPossibleScore,
    required this.averagePercentage,
    required this.averageTimeSpent,
    required this.passedCount,
    required this.failedCount,
    this.bestSubmission,
    this.latestSubmission,
    required this.recentSubmissions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      studentId: json['studentId'] ?? 0,
      totalSubmissions: json['totalSubmissions'] ?? 0,
      totalSetsAttempted: json['totalSetsAttempted'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      incorrectAnswers: json['incorrectAnswers'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalPossibleScore: json['totalPossibleScore'] ?? 0,
      averagePercentage: (json['averagePercentage'] ?? 0).toDouble(),
      averageTimeSpent: (json['averageTimeSpent'] ?? 0).toDouble(),
      passedCount: json['passedCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      bestSubmission: json['bestSubmission'] != null
          ? Submission.fromJson(json['bestSubmission'])
          : null,
      latestSubmission: json['latestSubmission'] != null
          ? Submission.fromJson(json['latestSubmission'])
          : null,
      recentSubmissions:
          (json['recentSubmissions'] as List?)
              ?.map((e) => Submission.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Submission {
  final int id;
  final String setId;
  final int setNo;
  final int studentId;
  final int? totalQuestion;
  final int? totalMark;
  final int? totalAns;
  final String? result;
  final int totalTimeSpent;
  final bool autoSubmitted;
  final String deviceInfo;
  final String platform;
  final String createdAt;
  final String updatedAt;
  final List<Answer> answers;

  Submission({
    required this.id,
    required this.setId,
    required this.setNo,
    required this.studentId,
    this.totalQuestion,
    this.totalMark,
    this.totalAns,
    this.result,
    required this.totalTimeSpent,
    required this.autoSubmitted,
    required this.deviceInfo,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
    required this.answers,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] ?? 0,
      setId: json['setId'] ?? '',
      setNo: json['setNo'] ?? 0,
      studentId: json['studentId'] ?? 0,
      totalQuestion: json['totalQuestion'],
      totalMark: json['totalMark'],
      totalAns: json['totalAns'],
      result: json['result'],
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      autoSubmitted: json['autoSubmitted'] ?? false,
      deviceInfo: json['deviceInfo'] ?? '',
      platform: json['platform'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      answers:
          (json['answers'] as List?)?.map((e) => Answer.fromJson(e)).toList() ??
          [],
    );
  }

  int get correctAnswersCount {
    return answers.where((a) => a.isCorrect == true).length;
  }

  int get wrongAnswersCount {
    return answers.where((a) => a.isCorrect == false).length;
  }

  double get scorePercentage {
    final total = answers.length;
    if (total == 0) return 0;
    return (correctAnswersCount / total) * 100;
  }
}

class Answer {
  final int id;
  final int questionId;
  final String questionText;
  final int questionType;
  final List<int> selectedOptionIndices;
  final List<String> selectedOptionTexts;
  final bool isCorrect;
  final int timeSpent;
  final int attemptNumber;
  final bool bookmarked;
  final int? scoreEarned;
  final int maxScore;

  Answer({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.selectedOptionIndices,
    required this.selectedOptionTexts,
    required this.isCorrect,
    required this.timeSpent,
    required this.attemptNumber,
    required this.bookmarked,
    this.scoreEarned,
    required this.maxScore,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? 0,
      selectedOptionIndices: List<int>.from(
        json['selectedOptionIndices'] ?? [],
      ),
      selectedOptionTexts: List<String>.from(json['selectedOptionTexts'] ?? []),
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      attemptNumber: json['attemptNumber'] ?? 1,
      bookmarked: json['bookmarked'] ?? false,
      scoreEarned: json['scoreEarned'],
      maxScore: json['maxScore'] ?? 1,
    );
  }
}
