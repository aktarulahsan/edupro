import 'dart:convert';

List<QuizModel> quizModelPostFromJson2(var str) {
  if (str == null) return [];

  final decoded = json.decode(str);

  if (decoded is Map) {
    return [QuizModel.fromJson(decoded.cast<String, dynamic>())];
  } else if (decoded is List) {
    return decoded
        .map((e) => QuizModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  return [];
}

List<QuizModel> quizModelPostFromJson(var str) =>
    List<QuizModel>.from(json.decode(str!).map((x) => QuizModel.fromJson(x)));

List<QuizList> quizListPostFromJson(var str) =>
    List<QuizList>.from(json.decode(str!).map((x) => QuizList.fromJson(x)));

class QuizModel {
  String? status;
  int? statusCode;
  String? message;
  String? studentId;
  String? studentName;
  String? examId;
  dynamic mark;
  dynamic passmark;
  dynamic numberOfQuiz;
  String? examStartTime;
  String? examEndTime;
  String? examText;
  List<QuizList>? quizList;

  QuizModel({
    this.status,
    this.statusCode,
    this.message,
    this.studentId,
    this.studentName,
    this.examId,
    this.mark,
    this.passmark,
    this.numberOfQuiz,
    this.examStartTime,
    this.examEndTime,
    this.examText,
    this.quizList,
  });

  factory QuizModel.fromRawJson(String str) =>
      QuizModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    status: json["status"]?.toString(),
    statusCode: json["statusCode"] as int?,
    message: json["message"]?.toString(),
    studentId: json["studentId"]?.toString(),
    studentName: json["studentName"]?.toString(),
    examId: json["examId"]?.toString(),
    mark: json["mark"],
    passmark: json["passmark"],
    numberOfQuiz: json["numberOfQuiz"],
    examStartTime: json["examStartTime"]?.toString(),
    examEndTime: json["examEndTime"]?.toString(),
    examText: json["examText"]?.toString(),
    quizList: json["quizList"] == null
        ? []
        : (json["quizList"] as List)
              .map((x) => QuizList.fromJson(x.cast<String, dynamic>()))
              .toList(),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "studentId": studentId,
    "studentName": studentName,
    "examId": examId,
    "mark": mark,
    "passmark": passmark,
    "numberOfQuiz": numberOfQuiz,
    "examStartTime": examStartTime,
    "examEndTime": examEndTime,
    "examText": examText,
    "quizList": quizList?.map((x) => x.toJson()).toList() ?? [],
  };
}

class QuizList {
  dynamic mark;
  String? examId;
  String? questionId;
  int? questionNo;
  String? questionText;
  String? givenAns;
  String? correctAnswer;
  String? explanation;
  int? questionType;
  List<Option>? optionList;

  QuizList({
    this.mark,
    this.examId,
    this.questionId,
    this.questionNo,
    this.questionText,
    this.givenAns,
    this.correctAnswer,
    this.explanation,
    this.questionType,
    this.optionList,
  });

  factory QuizList.fromRawJson(String str) =>
      QuizList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuizList.fromJson(Map<String, dynamic> json) => QuizList(
    mark: json["mark"],
    examId: json["examId"]?.toString(),
    questionId: json["questionId"]?.toString(),
    questionNo: json["questionNo"],
    questionText: json["questionText"]?.toString().replaceAll(
      RegExp(r'<[^>]*>|\\r|\\n'),
      '',
    ),
    givenAns: json["givenAns"]?.toString() ?? "",
    correctAnswer: json["correctAnswer"]?.toString() ?? "",
    explanation: json["explanation"]?.toString(),
    questionType: json["questionType"] as int?,
    optionList: json["optionList"] == null
        ? []
        : (json["optionList"] as List)
              .map((x) => Option.fromJson(x.cast<String, dynamic>()))
              .toList(),
  );

  Map<String, dynamic> toJson() => {
    "mark": mark,
    "examId": examId,
    "questionId": questionId,
    "questionNo": questionNo,
    "questionText": questionText,
    "givenAns": givenAns,
    "correctAnswer": correctAnswer,
    "explanation": explanation,
    "questionType": questionType,
    "optionList": optionList?.map((x) => x.toJson()).toList() ?? [],
  };
}

class Option {
  int? optionNo;
  String? optionId;
  String? questionId;
  String? option; // Changed from dynamic to String?
  String? answer; // Changed from dynamic to String?
  bool? correct;

  Option({
    this.optionNo,
    this.optionId,
    this.questionId,
    this.option,
    this.answer,
    this.correct,
  });

  factory Option.fromRawJson(String str) => Option.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    optionNo: json["optionNo"] ?? 0,
    optionId: json["optionId"]?.toString(),
    questionId: json["questionId"]?.toString(),
    option: json["option"]?.toString(), // Convert to String
    answer: json["answer"]?.toString(), // Convert to String
    correct: json["correct"] as bool?,
  );

  Map<String, dynamic> toJson() => {
    "optionNo": optionNo,
    "optionId": optionId,
    "questionId": questionId,
    "option": option,
    "answer": answer,
    "correct": correct,
  };
}
