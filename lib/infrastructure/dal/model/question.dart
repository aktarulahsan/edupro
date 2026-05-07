import 'package:edupro/infrastructure/dal/model/option_model.dart';

class Question {
  final int questionNo;
  final String questionId;
  final String questionText;
  final String givenAns;
  final String correctAnswer;
  final int questionType; // 1: single choice, 2: multiple choice
  final String explanation;
  final List<OptionModel> optionList;

  Question({
    required this.questionNo,
    required this.questionId,
    required this.questionText,
    required this.givenAns,
    required this.correctAnswer,
    required this.questionType,
    required this.explanation,
    required this.optionList,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionNo: json['questionNo'] ?? 0,
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      givenAns: json['givenAns'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      questionType: json['questionType'] ?? 0,
      explanation: json['explanation'] ?? '',
      optionList:
          (json['optionList'] as List?)
              ?.map((o) => OptionModel.fromJson(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "questionId": questionId,
    "questionNo": questionNo,
    "explanation": explanation,
    "questionText": questionText,
    "givenAns": givenAns,
    "correctAnswer": correctAnswer,
    "questionType": questionType,
    "optionList": optionList.map((o) => o.toJson()).toList(),
  };
}
