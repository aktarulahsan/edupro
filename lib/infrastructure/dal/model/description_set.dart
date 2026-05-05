import 'dart:convert';

import 'package:edupro/infrastructure/dal/model/question.dart';


DescriptionSet descriptionSetFromJson(String str) => DescriptionSet.fromJson(json.decode(str));

String descriptionSetToJson(DescriptionSet data) => json.encode(data.toJson());

class DescriptionSet {
  String? setName;
  int? totalQuestions;
  String? subjectGroup;
  int? setNo;
  List<Question>? questions;

  DescriptionSet({
    this.setName,
    this.totalQuestions,
    this.subjectGroup,
    this.setNo,
    this.questions,
  });

  DescriptionSet copyWith({
    String? setName,
    int? totalQuestions,
    String? subjectGroup,
    int? setNo,
    List<Question>? questions,
  }) =>
      DescriptionSet(
        setName: setName ?? this.setName,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        subjectGroup: subjectGroup ?? this.subjectGroup,
        setNo: setNo ?? this.setNo,
        questions: questions ?? this.questions,
      );

  factory DescriptionSet.fromJson(Map<String, dynamic> json) => DescriptionSet(
    setName: json["setName"],
    totalQuestions: json["totalQuestions"],
    subjectGroup: json["subjectGroup"],
    setNo: json["setNo"],
    questions: json["questions"] == null ? [] : List<Question>.from(json["questions"]!.map((x) => Question.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "setName": setName,
    "totalQuestions": totalQuestions,
    "subjectGroup": subjectGroup,
    "setNo": setNo,
    "questions": questions == null ? [] : List<dynamic>.from(questions!.map((x) => x.toJson())),
  };
}