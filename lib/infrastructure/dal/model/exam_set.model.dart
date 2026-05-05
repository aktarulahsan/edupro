
import 'dart:convert';

List<ExamSetModel> examSetModelPostFromJson(var str) =>
    List<ExamSetModel>.from(json.decode(str!).map((x) => ExamSetModel.fromJson(x)));


class ExamSetModel {
  final int setNo;
  final int userId;
  final String setName;
  final DateTime createdAt;

  ExamSetModel({
    required this.setNo,
    required this.userId,
    required this.setName,
    required this.createdAt,
  });

  factory ExamSetModel.fromJson(Map<String, dynamic> json) {
    return ExamSetModel(
      setNo: json['setNo'],
      userId: json['userId'],
      setName: json['setName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNo': setNo,
      'userId': userId,
      'setName': setName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}