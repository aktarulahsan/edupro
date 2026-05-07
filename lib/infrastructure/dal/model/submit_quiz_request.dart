class SubmitQuizRequest {
  final String setId;
  final int setNo;
  final int studentId;
  final List<QuizAnswer> answers;
  final int totalTimeSpent; // in seconds
  final bool autoSubmitted;
  final String? deviceInfo;
  final String? platform;

  SubmitQuizRequest({
    required this.setId,
    required this.setNo,
    required this.studentId,
    required this.answers,
    required this.totalTimeSpent,
    required this.autoSubmitted,
    this.deviceInfo,
    this.platform,
  });

  Map<String, dynamic> toJson() => {
    'setId': setId,
    'setNo':setNo,
    'studentId': studentId,
    'answers': answers.map((e) => e.toJson()).toList(),
    'totalTimeSpent': totalTimeSpent,
    'autoSubmitted': autoSubmitted,
    'deviceInfo': deviceInfo,
    'platform': platform,
  };
}

class QuizAnswer {
  final int questionNo;
  final String questionText;
  final int questionType; // 1: single choice, 2: multiple choice
  final List<int> selectedOptionIndices;
  final List<String> selectedOptionTexts;
  final bool isCorrect;
  final int timeSpent; // time spent on this question in seconds

  QuizAnswer({
    required this.questionNo,
    required this.questionText,
    required this.questionType,
    required this.selectedOptionIndices,
    required this.selectedOptionTexts,
    required this.isCorrect,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionNo,
    'questionText': questionText,
    'questionType': questionType,
    'selectedOptionIndices': selectedOptionIndices,
    'selectedOptionTexts': selectedOptionTexts,
    'isCorrect': isCorrect,
    'timeSpent': timeSpent,
  };
}
