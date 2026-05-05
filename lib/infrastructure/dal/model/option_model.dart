
class OptionModel {
  final int optionNo;
  final String optionId;
  final String questionId;
  final String option;
  final bool correct;

  OptionModel({
    required this.optionNo,
    required this.optionId,
    required this.questionId,
    required this.option,
    required this.correct,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      optionNo: json['optionNo'] ?? 0,
      optionId: json['optionId'] ?? '',
      questionId: json['questionId'] ?? '',
      option: json['option'] ?? '',
      correct: json['correct'] ?? false,
    );
  }
  Map<String, dynamic> toJson() => {
    "optionNo": optionNo,
    "optionId": optionId,
    "questionId": questionId,
    "option": option,
    "correct": correct,

  };
}
