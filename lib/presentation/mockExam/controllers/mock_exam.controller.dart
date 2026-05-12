import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_request.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_response.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockExamController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;
  final mockExams = <QuizModel>[].obs;
  final selectedExam = Rxn<QuizModel>();

  final GetStorage _storage = GetStorage();
  static const String _attemptCacheKey = 'mock_exam_attempts';

  final attempts = <String, MockExamAttempt>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedAttempts();
    getMockExams();
  }

  Future<void> getMockExams() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getQuizList,
        options: UserCache.getOption(),
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          errorMessage.value = _cleanError(error);
          isLoading.value = false;
        },
        (success) {
          try {
            final baseResponse = BaseResponse.fromJson(success.data);
            mockExams.value = _parseQuizModels(
              baseResponse.items ?? baseResponse.data ?? baseResponse.obj,
            );
            if (mockExams.isEmpty) {
              errorMessage.value = 'No mock exams are available right now.';
            }
          } catch (e) {
            errorMessage.value = 'Unable to read mock exam data.';
          } finally {
            isLoading.value = false;
          }
        },
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      isLoading.value = false;
    }
  }

  Future<SubmitQuizResponse?> submitMockExam({
    required QuizModel exam,
    required Map<int, dynamic> selectedOptions,
    required int totalTimeSpent,
    required bool autoSubmitted,
  }) async {
    try {
      isSubmitting.value = true;

      final request = SubmitQuizRequest(
        setId: exam.examId ?? exam.hashCode.toString(),
        setNo: int.tryParse(exam.examId ?? '') ?? 0,
        studentId: UserCache.getUserData()?.userId ?? 0,
        answers: prepareAnswers(
          questions: exam.quizList ?? [],
          selectedOptions: selectedOptions,
        ),
        totalTimeSpent: totalTimeSpent,
        autoSubmitted: autoSubmitted,
        deviceInfo: 'Flutter App',
        platform: GetPlatform.isAndroid
            ? 'Android'
            : GetPlatform.isIOS
            ? 'iOS'
            : GetPlatform.isWeb
            ? 'Web'
            : 'Flutter',
      );

      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.submitQuiz,
        data: request.toJson(),
        options: UserCache.getOption(),
      );

      final response = await AppApiProvider.instance.post(requestPayload);
      SubmitQuizResponse? submitResponse;

      response.fold(
        (error) {
          errorMessage.value = _cleanError(error);
          Get.snackbar(
            'Submission Failed',
            'Could not submit your mock exam. Showing local result.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (success) {
          final baseResponse = BaseResponse.fromJson(success.data);
          final data = baseResponse.data ?? baseResponse.obj ?? success.data;
          if (data is Map<String, dynamic>) {
            submitResponse = SubmitQuizResponse.fromJson(data);
          } else if (data is Map) {
            submitResponse = SubmitQuizResponse.fromJson(
              data.cast<String, dynamic>(),
            );
          }
        },
      );

      final localResult = calculateLocalResult(
        questions: exam.quizList ?? [],
        selectedOptions: selectedOptions,
      );
      saveAttempt(
        examId: exam.examId ?? exam.hashCode.toString(),
        score: submitResponse?.correctAnswers ?? localResult.correctAnswers,
        totalQuestions: submitResponse?.totalQuestions ?? localResult.total,
        percentage: submitResponse?.percentage ?? localResult.percentage,
        timeSpent: totalTimeSpent,
      );

      return submitResponse;
    } catch (e) {
      errorMessage.value = _cleanError(e);
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  List<QuizAnswer> prepareAnswers({
    required List<QuizList> questions,
    required Map<int, dynamic> selectedOptions,
  }) {
    final answers = <QuizAnswer>[];

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final options = question.optionList ?? [];
      final selected = selectedOptions[i];
      final selectedIndices = _toSelectedIndices(selected)..sort();
      final correctIndices = <int>[];

      for (var j = 0; j < options.length; j++) {
        if (options[j].correct == true) correctIndices.add(j);
      }
      correctIndices.sort();

      answers.add(
        QuizAnswer(
          questionNo: question.questionNo ?? i + 1,
          questionText: cleanQuestionText(question.questionText ?? ''),
          questionType: question.questionType ?? 1,
          selectedOptionIndices: selectedIndices,
          selectedOptionTexts: selectedIndices
              .where((index) => index >= 0 && index < options.length)
              .map((index) => cleanHtmlTags(options[index].option ?? ''))
              .toList(),
          isCorrect: const ListEquality().equals(
            selectedIndices,
            correctIndices,
          ),
          timeSpent: 0,
        ),
      );
    }

    return answers;
  }

  MockExamLocalResult calculateLocalResult({
    required List<QuizList> questions,
    required Map<int, dynamic> selectedOptions,
  }) {
    var correct = 0;

    for (var i = 0; i < questions.length; i++) {
      final options = questions[i].optionList ?? [];
      final selectedIndices = _toSelectedIndices(selectedOptions[i])..sort();
      final correctIndices = <int>[];

      for (var j = 0; j < options.length; j++) {
        if (options[j].correct == true) correctIndices.add(j);
      }
      correctIndices.sort();

      if (selectedIndices.isNotEmpty &&
          const ListEquality().equals(selectedIndices, correctIndices)) {
        correct++;
      }
    }

    final total = questions.length;
    return MockExamLocalResult(
      correctAnswers: correct,
      total: total,
      percentage: total == 0 ? 0 : (correct / total) * 100,
    );
  }

  int getDurationSeconds(QuizModel exam) {
    final start = DateTime.tryParse(exam.examStartTime ?? '');
    final end = DateTime.tryParse(exam.examEndTime ?? '');
    if (start != null && end != null && end.isAfter(start)) {
      return end.difference(start).inSeconds;
    }

    final questionCount = exam.quizList?.length ?? 0;
    if (questionCount >= 80) return 60 * 60;
    if (questionCount >= 50) return 45 * 60;
    return 30 * 60;
  }

  String examTitle(QuizModel exam, int index) {
    final text = exam.examText?.trim();
    if (text != null && text.isNotEmpty) return cleanHtmlTags(text);

    final examId = exam.examId?.trim();
    if (examId != null && examId.isNotEmpty) return 'Mock Exam $examId';

    return 'Mock Exam ${index + 1}';
  }

  void saveAttempt({
    required String examId,
    required int score,
    required int totalQuestions,
    required double percentage,
    required int timeSpent,
  }) {
    attempts[examId] = MockExamAttempt(
      examId: examId,
      score: score,
      totalQuestions: totalQuestions,
      percentage: percentage,
      timeSpent: timeSpent,
      completedAt: DateTime.now(),
    );
    _saveAttempts();
  }

  MockExamAttempt? getAttempt(String examId) => attempts[examId];

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
    }
    return remainingSeconds == 0
        ? '${minutes}m'
        : '${minutes}m ${remainingSeconds}s';
  }

  String cleanQuestionText(String text) {
    if (text.isEmpty) return '';
    var cleaned = text;
    cleaned = cleaned.replaceFirst(RegExp(r'^প্রশ্ন\s+[\d০-৯]+\.\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s+'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.'), '');
    return cleanHtmlTags(cleaned.trimLeft());
  }

  String cleanHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';
    var text = htmlString.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>', caseSensitive: false),
      (match) => _convertToSuperscript(match.group(1) ?? ''),
    );

    const replacements = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&rsquo;': "'",
      '&ldquo;': '"',
      '&rdquo;': '"',
    };

    replacements.forEach((key, value) {
      text = text.replaceAll(key, value);
    });

    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<QuizModel> _parseQuizModels(dynamic data) {
    if (data == null) return [];
    dynamic parsed = data;
    if (data is String) parsed = json.decode(data);

    if (parsed is Map<String, dynamic>) {
      return [QuizModel.fromJson(parsed)];
    }
    if (parsed is Map) {
      return [QuizModel.fromJson(parsed.cast<String, dynamic>())];
    }
    if (parsed is List) {
      return parsed
          .whereType<Map>()
          .map((item) => QuizModel.fromJson(item.cast<String, dynamic>()))
          .where((exam) => (exam.quizList ?? []).isNotEmpty)
          .toList();
    }
    return [];
  }

  List<int> _toSelectedIndices(dynamic selected) {
    if (selected == null) return [];
    if (selected is int) return [selected];
    if (selected is List<int>) return List<int>.from(selected);
    if (selected is List) return selected.whereType<int>().toList();
    return [];
  }

  void _loadCachedAttempts() {
    final cached = _storage.read<String>(_attemptCacheKey);
    if (cached == null || cached.isEmpty) return;

    try {
      final decoded = json.decode(cached);
      if (decoded is Map) {
        attempts.assignAll(
          decoded.map(
            (key, value) => MapEntry(
              key.toString(),
              MockExamAttempt.fromJson(Map<String, dynamic>.from(value)),
            ),
          ),
        );
      }
    } catch (_) {
      attempts.clear();
    }
  }

  Future<void> _saveAttempts() async {
    await _storage.write(
      _attemptCacheKey,
      json.encode(attempts.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  String _cleanError(dynamic error) {
    final message = error.toString().replaceAll('Exception:', '').trim();
    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }

  String _convertToSuperscript(String text) {
    const supMap = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '+': '⁺',
      '-': '⁻',
      '=': '⁼',
      '(': '⁽',
      ')': '⁾',
      'n': 'ⁿ',
      'i': 'ⁱ',
    };
    return text.split('').map((char) => supMap[char] ?? char).join();
  }
}

class MockExamLocalResult {
  MockExamLocalResult({
    required this.correctAnswers,
    required this.total,
    required this.percentage,
  });

  final int correctAnswers;
  final int total;
  final double percentage;
}

class MockExamAttempt {
  MockExamAttempt({
    required this.examId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.timeSpent,
    required this.completedAt,
  });

  final String examId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int timeSpent;
  final DateTime completedAt;

  factory MockExamAttempt.fromJson(Map<String, dynamic> json) {
    return MockExamAttempt(
      examId: json['examId']?.toString() ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      timeSpent: json['timeSpent'] ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'score': score,
    'totalQuestions': totalQuestions,
    'percentage': percentage,
    'timeSpent': timeSpent,
    'completedAt': completedAt.toIso8601String(),
  };
}
