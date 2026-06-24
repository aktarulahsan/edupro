
import 'dart:convert';

List<ExamSetModel> examSetModelPostFromJson(var str) =>
    List<ExamSetModel>.from(json.decode(str!).map((x) => ExamSetModel.fromJson(x)));


class ExamSetModel {
  final int setNo;
  final int userId;
  final String setName;
  final DateTime createdAt;
  final int? userScore;
  final int? userTotalQuestions;
  final bool? passed;

  ExamSetModel({
    required this.setNo,
    required this.userId,
    required this.setName,
    required this.createdAt,
    this.userScore,
    this.userTotalQuestions,
    this.passed,
  });

  factory ExamSetModel.fromJson(Map<String, dynamic> json) {
    return ExamSetModel(
      setNo: json['setNo'],
      userId: json['userId'],
      setName: json['setName'],
      createdAt: DateTime.parse(json['createdAt']),
      userScore: json['userScore'],
      userTotalQuestions: json['userTotalQuestions'],
      passed: json['passed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNo': setNo,
      'userId': userId,
      'setName': setName,
      'createdAt': createdAt.toIso8601String(),
      'userScore': userScore,
      'userTotalQuestions': userTotalQuestions,
      'passed': passed,
    };
  }
}