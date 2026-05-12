import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_request.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_response.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/foundation.dart';
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
  static const String _examCacheKey = 'mock_exam_cache';
  static const String _examCacheTimestampKey = 'mock_exam_cache_timestamp';
  static const String _attemptCacheKey = 'mock_exam_attempts';
  static const String _answersCacheKey = 'mock_exam_answers_cache';
  static const Duration _cacheExpiry = Duration(hours: 12);

  final attempts = <String, MockExamAttempt>{}.obs;
  final examAnswers = <String, Map<String, dynamic>>{}.obs;
  final examCorrectness = <String, Map<String, bool>>{}.obs;
  final currentExamAnswers = <String, dynamic>{}.obs;
  final currentExamCorrectness = <String, bool>{}.obs;
  bool _isFetching = false;

  static final RegExp _questionPrefixBanglaRegex = RegExp(
    r'^প্রশ্ন\s+[\d০-৯]+\.\s*',
  );
  static final RegExp _questionPrefixNumberWithSpaceRegex = RegExp(
    r'^\d+\.\s+',
  );
  static final RegExp _questionPrefixNumberRegex = RegExp(r'^\d+\.');
  static final RegExp _supRegex = RegExp(
    r'<sup>(.*?)</sup>',
    caseSensitive: false,
  );
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _loadCachedAttempts();
    await _loadCachedAnswers();
    await _loadCachedExams();
    await getMockExams(isBackground: mockExams.isNotEmpty);
  }

  Future<void> getMockExams({
    bool forceRefresh = false,
    bool isBackground = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      if (!isBackground) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      if (!forceRefresh && mockExams.isEmpty) {
        await _loadCachedExams();
        isBackground = mockExams.isNotEmpty;
        if (isBackground) {
          isLoading.value = false;
        }
      }

      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getQuizList,
        options: UserCache.getOption(),
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      await response.fold<Future<void>>(
        (error) async {
          errorMessage.value = _cleanError(error);
          isLoading.value = false;
          _isFetching = false;
        },
        (success) async {
          try {
            final baseResponse = BaseResponse.fromJson(success.data);
            final parsedExams = await compute(
              _parseQuizModelsInBackground,
              baseResponse.items ?? baseResponse.data ?? baseResponse.obj,
            );
            mockExams.assignAll(parsedExams);
            if (parsedExams.isNotEmpty) {
              await _saveExamsToCache(parsedExams);
            } else {
              errorMessage.value = 'No mock exams are available right now.';
            }
          } catch (e) {
            debugPrint('Mock exam parse error: $e');
            errorMessage.value = 'Unable to read mock exam data.';
          } finally {
            isLoading.value = false;
            _isFetching = false;
          }
        },
      );
    } catch (e) {
      errorMessage.value = _cleanError(e);
      isLoading.value = false;
      _isFetching = false;
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
        score: localResult.correctAnswers,
        totalQuestions: localResult.total,
        percentage: localResult.percentage,
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
    var answered = 0;

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedIndices = _toSelectedIndices(selectedOptions[i]);
      if (selectedIndices.isEmpty) continue;

      answered++;
      if (_checkIfAnswerCorrect(question, selectedIndices)) {
        correct++;
      }
    }

    final total = questions.length;
    return MockExamLocalResult(
      correctAnswers: correct,
      answeredQuestions: answered,
      incorrectAnswers: answered - correct,
      total: total,
      percentage: total == 0 ? 0 : (correct / total) * 100,
    );
  }

  void loadExamAnswers(String examId, List<QuizList> questions) {
    final storedAnswers = examAnswers[examId];
    if (storedAnswers == null) {
      currentExamAnswers.clear();
      currentExamCorrectness.clear();
      return;
    }

    currentExamAnswers.assignAll(storedAnswers);
    currentExamCorrectness.assignAll(examCorrectness[examId] ?? {});
  }

  Map<int, dynamic> getSelectedOptionsForExam(
    String examId,
    List<QuizList> questions,
  ) {
    final storedAnswers = examAnswers[examId] ?? currentExamAnswers;
    final selectedOptions = <int, dynamic>{};

    for (var i = 0; i < questions.length; i++) {
      final questionId = _questionKey(questions[i], i);
      final answer = storedAnswers[questionId];
      if (answer == null) continue;
      selectedOptions[i] = _normalizeStoredAnswer(questions[i], answer);
    }

    return selectedOptions;
  }

  void saveCurrentExamAnswer({
    required String examId,
    required int questionIndex,
    required QuizList question,
    required dynamic answer,
  }) {
    final questionId = _questionKey(question, questionIndex);
    final normalizedAnswer = _normalizeAnswerForQuestion(question, answer);

    if (_isEmptyAnswer(normalizedAnswer)) {
      currentExamAnswers.remove(questionId);
      currentExamCorrectness.remove(questionId);
    } else {
      currentExamAnswers[questionId] = normalizedAnswer;
      currentExamCorrectness[questionId] = _checkIfAnswerCorrect(
        question,
        normalizedAnswer,
      );
    }

    examAnswers[examId] = Map<String, dynamic>.from(currentExamAnswers);
    examCorrectness[examId] = Map<String, bool>.from(currentExamCorrectness);
    _saveAnswersToCache();
  }

  bool isQuestionAnswered(String examId, QuizList question, int questionIndex) {
    return examAnswers[examId]?.containsKey(
          _questionKey(question, questionIndex),
        ) ??
        false;
  }

  int getExamAnsweredCount(String examId) => examAnswers[examId]?.length ?? 0;

  void clearExamAnswers(String examId) {
    examAnswers.remove(examId);
    examCorrectness.remove(examId);
    currentExamAnswers.clear();
    currentExamCorrectness.clear();
    _saveAnswersToCache();
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

  String cleanQuestionText(String text) => _cleanQuestionTextStatic(text);

  String cleanHtmlTags(String htmlString) => _cleanHtmlTagsStatic(htmlString);

  static List<QuizModel> _parseQuizModelsInBackground(dynamic data) {
    if (data == null) return [];
    dynamic parsed = data;
    if (data is String) parsed = json.decode(data);

    if (parsed is Map<String, dynamic>) {
      return [
        _normalizeQuizModel(QuizModel.fromJson(parsed)),
      ].where((exam) => (exam.quizList ?? []).isNotEmpty).toList();
    }
    if (parsed is Map) {
      return [
        _normalizeQuizModel(QuizModel.fromJson(parsed.cast<String, dynamic>())),
      ].where((exam) => (exam.quizList ?? []).isNotEmpty).toList();
    }
    if (parsed is List) {
      return parsed
          .whereType<Map>()
          .map((item) => QuizModel.fromJson(item.cast<String, dynamic>()))
          .map(_normalizeQuizModel)
          .where((exam) => (exam.quizList ?? []).isNotEmpty)
          .toList();
    }
    return [];
  }

  static QuizModel _normalizeQuizModel(QuizModel exam) {
    exam.examText = _cleanHtmlTagsStatic(exam.examText ?? '');

    for (final question in exam.quizList ?? <QuizList>[]) {
      question.questionText = _cleanQuestionTextStatic(
        question.questionText ?? '',
      );
      question.explanation = _cleanHtmlTagsStatic(question.explanation ?? '');

      for (final option in question.optionList ?? <Option>[]) {
        option.option = _cleanHtmlTagsStatic(option.option ?? '');
        option.answer = _cleanHtmlTagsStatic(option.answer ?? '');
      }
    }

    return exam;
  }

  static String _cleanQuestionTextStatic(String text) {
    if (text.isEmpty) return '';
    var cleaned = text;
    cleaned = cleaned.replaceFirst(_questionPrefixBanglaRegex, '');
    cleaned = cleaned.replaceFirst(_questionPrefixNumberWithSpaceRegex, '');
    cleaned = cleaned.replaceFirst(_questionPrefixNumberRegex, '');
    return _cleanHtmlTagsStatic(cleaned.trimLeft());
  }

  static String _cleanHtmlTagsStatic(String htmlString) {
    if (htmlString.isEmpty) return '';
    var text = htmlString.replaceAllMapped(
      _supRegex,
      (match) => _convertToSuperscriptStatic(match.group(1) ?? ''),
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
        .replaceAll(_htmlTagRegex, '')
        .replaceAll(_whitespaceRegex, ' ')
        .trim();
  }

  List<int> _toSelectedIndices(dynamic selected) {
    if (selected == null) return [];
    if (selected is int) return [selected];
    if (selected is List<int>) return List<int>.from(selected);
    if (selected is List) return selected.whereType<int>().toList();
    return [];
  }

  String _questionKey(QuizList question, int index) {
    final questionId = question.questionId?.trim();
    if (questionId != null && questionId.isNotEmpty) return questionId;

    final questionNo = question.questionNo;
    if (questionNo != null) return questionNo.toString();

    return index.toString();
  }

  dynamic _normalizeStoredAnswer(QuizList question, dynamic answer) {
    if (question.questionType == 2) {
      return _toSelectedIndices(answer)..sort();
    }

    final indices = _toSelectedIndices(answer);
    return indices.isEmpty ? null : indices.first;
  }

  dynamic _normalizeAnswerForQuestion(QuizList question, dynamic answer) {
    if (question.questionType == 2) {
      final indices = _toSelectedIndices(answer).toSet().toList()..sort();
      return indices;
    }

    if (answer is int) return answer;
    final indices = _toSelectedIndices(answer);
    return indices.isEmpty ? null : indices.first;
  }

  bool _isEmptyAnswer(dynamic answer) {
    if (answer == null) return true;
    if (answer is List) return answer.isEmpty;
    return false;
  }

  bool _checkIfAnswerCorrect(QuizList question, dynamic answer) {
    final options = question.optionList ?? [];
    final selectedIndices = _toSelectedIndices(answer)..sort();
    final correctIndices = <int>[];

    for (var i = 0; i < options.length; i++) {
      if (options[i].correct == true) correctIndices.add(i);
    }
    correctIndices.sort();

    if (question.questionType == 2) {
      return selectedIndices.isNotEmpty &&
          const ListEquality().equals(selectedIndices, correctIndices);
    }

    return selectedIndices.length == 1 &&
        correctIndices.contains(selectedIndices.first);
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

  Future<void> _loadCachedAnswers() async {
    final cached = _storage.read<String>(_answersCacheKey);
    if (cached == null || cached.isEmpty) return;

    try {
      final decoded = json.decode(cached);
      if (decoded is! Map) return;

      final answers = decoded['examAnswers'];
      if (answers is Map) {
        examAnswers.assignAll(
          answers.map(
            (examId, answersByQuestion) => MapEntry(
              examId.toString(),
              Map<String, dynamic>.from(answersByQuestion as Map),
            ),
          ),
        );
      }

      final correctness = decoded['examCorrectness'];
      if (correctness is Map) {
        examCorrectness.assignAll(
          correctness.map(
            (examId, correctnessByQuestion) => MapEntry(
              examId.toString(),
              Map<String, bool>.from(correctnessByQuestion as Map),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Mock exam answers cache load error: $e');
      examAnswers.clear();
      examCorrectness.clear();
    }
  }

  Future<void> _loadCachedExams() async {
    final cached = _storage.read<String>(_examCacheKey);
    if (cached == null || cached.isEmpty) return;

    try {
      final decoded = json.decode(cached);
      if (decoded is! Map) return;

      final timestamp = decoded['timestamp'] is int
          ? decoded['timestamp'] as int
          : int.tryParse(decoded['timestamp']?.toString() ?? '');
      if (timestamp != null) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedAt) > _cacheExpiry) return;
      }

      final parsedExams = await compute(
        _parseQuizModelsInBackground,
        decoded['quizzes'],
      );
      if (parsedExams.isNotEmpty) {
        mockExams.assignAll(parsedExams);
      }
    } catch (e) {
      debugPrint('Mock exam cache load error: $e');
    }
  }

  Future<void> _saveExamsToCache(List<QuizModel> exams) async {
    try {
      await _storage.write(
        _examCacheKey,
        json.encode({
          'quizzes': exams.map((exam) => exam.toJson()).toList(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      await _storage.write(
        _examCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Mock exam cache save error: $e');
    }
  }

  Future<void> _saveAttempts() async {
    await _storage.write(
      _attemptCacheKey,
      json.encode(attempts.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  Future<void> _saveAnswersToCache() async {
    try {
      await _storage.write(
        _answersCacheKey,
        json.encode({
          'examAnswers': examAnswers.map((key, value) => MapEntry(key, value)),
          'examCorrectness': examCorrectness.map(
            (key, value) => MapEntry(key, value),
          ),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (e) {
      debugPrint('Mock exam answers cache save error: $e');
    }
  }

  String _cleanError(dynamic error) {
    final message = error.toString().replaceAll('Exception:', '').trim();
    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }

  static String _convertToSuperscriptStatic(String text) {
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
    required this.answeredQuestions,
    required this.incorrectAnswers,
    required this.total,
    required this.percentage,
  });

  final int correctAnswers;
  final int answeredQuestions;
  final int incorrectAnswers;
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
