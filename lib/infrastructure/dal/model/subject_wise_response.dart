
import 'package:edupro/infrastructure/dal/model/question_set.model.dart';



class SubjectWiseResponse {
  final bool success;
  final String message;
  final List<QuestionSet> items;

  SubjectWiseResponse({
    required this.success,
    required this.message,
    required this.items,
  });

  factory SubjectWiseResponse.fromJson(Map<String, dynamic> json) {
    return SubjectWiseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      items: (json['items'] as List?)
          ?.map((item) => QuestionSet.fromJson(item))
          .toList() ??
          [],
    );
  }
}
