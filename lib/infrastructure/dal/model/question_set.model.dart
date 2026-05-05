import 'package:edupro/infrastructure/dal/model/question.dart';

class QuestionSet {
  final String setName;
  final int totalQuestions;
  final String subjectGroup;
  final int setNo;
  final List<Question> questions;

  QuestionSet({
    required this.setName,
    required this.totalQuestions,
    required this.subjectGroup,
    required this.setNo,
    required this.questions,
  });

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    return QuestionSet(
      setName: json['setName'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      subjectGroup: json['subjectGroup'] ?? '',
      setNo: json['setNo'] ?? 0,
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList() ??
          [],
    );
  }
}