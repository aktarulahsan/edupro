import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/exam_set.model.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_request.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_response.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:edupro/presentation/mcqPractice/question_screen.dart';
import 'package:edupro/utils/loader.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class McqPracticeController extends GetxController {
  static const _examSetsCacheKey = 'mcq_exam_sets_cache';
  static const _examSetsCacheTimeKey = 'mcq_exam_sets_cache_time';
  static const _questionCachePrefix = 'mcq_questions_cache_';
  static const _questionCacheTimePrefix = 'mcq_questions_cache_time_';
  static const _questionCacheLifetime = Duration(hours: 6);

  final GetStorage _storage = GetStorage();
  final isLoading = false.obs;
  final isQuestionsLoading = false.obs;
  final examSetList = <ExamSetModel>[].obs;
  final questionList = <QuizList>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final hasCachedData = _loadCachedExamSets();
    getQuizList(showLoader: !hasCachedData);
  }

  Future<void> getQuizList({bool showLoader = true}) async {
    try {
      isLoading.value = showLoader && examSetList.isEmpty;
      errorMessage.value = '';

      final userId = UserCache.getUesrId() ?? 1001;
      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: '${ApiEndPoints.quizModule.generateQuizSet}?userId=$userId',
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          if (examSetList.isEmpty) {
            errorMessage.value = error.toString();
          }
          isLoading.value = false;
        },
        (success) {
          final res = BaseResponse.fromJson(success.data);
          final parsedSets = _parseExamSets(res.items);
          examSetList.assignAll(parsedSets);
          _saveExamSetsToCache(parsedSets);
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      // if (kDebugMode) {
      //   print('Error in getQuizList: $e');
      // }
    }
  }

  Future<void> getQuestBySetId(String setId, String title, int setNo) async {
    final cachedQuestions = _loadCachedQuestions(setId);
    if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
      questionList.assignAll(cachedQuestions);
      _openQuestionScreen(title: title, setNo: setNo);
      return;
    }

    try {
      isQuestionsLoading.value = true;

      loader();

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getQuestionSetUrl(setId),
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          isQuestionsLoading.value = false;
          hideLoader();
          Get.snackbar(
            'Error',
            "Failed to load questions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (success) {
          final res = BaseResponse.fromJson(success.data);
          final parsedQuestions = _parseQuestions(res.items);
          questionList.assignAll(parsedQuestions);
          isQuestionsLoading.value = false;

          if (questionList.isNotEmpty) {
            _saveQuestionsToCache(setId, parsedQuestions);
            hideLoader();
            _openQuestionScreen(title: title, setNo: setNo);
          } else {
            hideLoader();
            Get.snackbar(
              'Info',
              "No questions available",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      );
    } catch (e) {
      isQuestionsLoading.value = false;
      hideLoader();
      debugPrint('Error in getQuestBySetId: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading questions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _loadCachedExamSets() {
    try {
      final cached = _storage.read<List<dynamic>>(_examSetsCacheKey);
      if (cached == null || cached.isEmpty) return false;

      final parsedSets = _parseExamSets(cached);
      if (parsedSets.isEmpty) return false;

      examSetList.assignAll(parsedSets);
      return true;
    } catch (e) {
      debugPrint('MCQ exam-set cache load failed: $e');
      return false;
    }
  }

  Future<void> _saveExamSetsToCache(List<ExamSetModel> sets) async {
    try {
      await _storage.write(
        _examSetsCacheKey,
        sets.map((set) => set.toJson()).toList(),
      );
      await _storage.write(
        _examSetsCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('MCQ exam-set cache save failed: $e');
    }
  }

  List<QuizList>? _loadCachedQuestions(String setId) {
    try {
      final cachedAt = _storage.read<int>('$_questionCacheTimePrefix$setId');
      if (cachedAt == null) return null;

      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(cachedAt),
      );
      if (age > _questionCacheLifetime) return null;

      final cached = _storage.read<List<dynamic>>(
        '$_questionCachePrefix$setId',
      );
      if (cached == null || cached.isEmpty) return null;
      return _parseQuestions(cached);
    } catch (e) {
      debugPrint('MCQ question cache load failed: $e');
      return null;
    }
  }

  Future<void> _saveQuestionsToCache(
    String setId,
    List<QuizList> questions,
  ) async {
    try {
      await _storage.write(
        '$_questionCachePrefix$setId',
        questions.map((question) => question.toJson()).toList(),
      );
      await _storage.write(
        '$_questionCacheTimePrefix$setId',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('MCQ question cache save failed: $e');
    }
  }

  List<ExamSetModel> _parseExamSets(dynamic source) {
    return _asList(source)
        .whereType<Map>()
        .map((item) => ExamSetModel.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  List<QuizList> _parseQuestions(dynamic source) {
    return _asList(source)
        .whereType<Map>()
        .map((item) => QuizList.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  List<dynamic> _asList(dynamic source) {
    if (source is List) return source;
    if (source is String) {
      final decoded = json.decode(source);
      return decoded is List ? decoded : const [];
    }
    return const [];
  }

  void _openQuestionScreen({required String title, required int setNo}) {
    if (Get.context == null) return;
    Get.to(
      () => QuestionScreen(
        quizList: questionList.toList(growable: false),
        title: title,
        setNo: setNo,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 220),
    );
  }

  Future<SubmitQuizResponse?> submitQuizResult({
    required String setId,
    required int setNo,

    required List<QuizAnswer> answers,
    required int totalTimeSpent,
    required bool autoSubmitted,
  }) async {
    try {
      isLoading.value = true;

      final user = UserCache.getUserData();
      if (user == null) {
        throw Exception('User not found');
      }

      final request = SubmitQuizRequest(
        setId: setId,
        setNo: setNo,
        studentId: user.userId is int
            ? user.userId as int
            : int.tryParse(user.userId?.toString() ?? '') ?? 0,
        answers: answers,
        totalTimeSpent: totalTimeSpent,
        autoSubmitted: autoSubmitted,
        deviceInfo: await _getDeviceInfo(),
        platform: Theme.of(Get.context!).platform.toString(),
      );

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.submitQuiz,
        data: request.toJson(),
        options: options,
      );

      final response = await AppApiProvider.instance.post(requestPayload);

      SubmitQuizResponse? submitResponse;

      response.fold(
        (error) {
          errorMessage.value = error.toString();
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Failed to submit quiz: ${error.toString()}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (success) {
          final res = BaseResponse.fromJson(success.data);
          if (res.success == true || res.status == 'success') {
            submitResponse = SubmitQuizResponse.fromJson(res.data ?? {});
            // Update user XP if needed
            if (submitResponse!.gainedXP > 0) {
              _updateUserXP(submitResponse!.gainedXP);
            }
            getQuizList(showLoader: false);
          } else {
            Get.snackbar(
              'Submission Failed',
              res.message ?? 'Unknown error occurred',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
          isLoading.value = false;
        },
      );

      return submitResponse;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'An error occurred while submitting quiz',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<String?> _getDeviceInfo() async {
    // You can add device info package to get more details
    // For now, return basic info
    return 'Flutter App';
  }

  void _updateUserXP(int gainedXP) {
    // Update user XP in cache or database
    final user = UserCache.getUserData();
    if (user != null) {
      // user.totalXP = (user.totalXP ?? 0) + gainedXP;
      UserCache.saveUserData(user);
    }
  }

  // Helper method to prepare answers from the quiz screen
  Map<String, dynamic> prepareQuizSubmissionData({
    required List<QuizList> quizList,
    required Map<int, dynamic> selectedOptions,
    required int totalTimeSpent,
    required String setId,
    required int setNo,
    required bool autoSubmitted,
  }) {
    final answers = <QuizAnswer>[];

    for (int i = 0; i < quizList.length; i++) {
      final question = quizList[i];
      final selectedOptionIndices = selectedOptions[i];

      // Get correct option indices
      final correctOptionIndices = <int>[];
      final correctOptionTexts = <String>[];
      for (int j = 0; j < question.optionList!.length; j++) {
        if (question.optionList![j].correct == true) {
          correctOptionIndices.add(j);
          correctOptionTexts.add(
            _cleanHtmlTags(question.optionList![j].option?.toString() ?? ''),
          );
        }
      }

      // Prepare selected options
      List<int> selectedIndices;
      List<String> selectedTexts;

      if (selectedOptionIndices == null) {
        // No answer selected
        selectedIndices = [];
        selectedTexts = [];
      } else if (selectedOptionIndices is int) {
        selectedIndices = [selectedOptionIndices];
        selectedTexts = [
          question.optionList![selectedOptionIndices].option?.toString() ?? '',
        ];
      } else if (selectedOptionIndices is List) {
        selectedIndices = List<int>.from(selectedOptionIndices);
        selectedTexts = selectedIndices
            .map(
              (idx) => _cleanHtmlTags(
                question.optionList![idx].option?.toString() ?? '',
              ),
            )
            .toList();
      } else {
        selectedIndices = [];
        selectedTexts = [];
      }

      // Sort for comparison
      selectedIndices.sort();

      // Check if answer is correct
      final isCorrect = const ListEquality().equals(
        selectedIndices,
        correctOptionIndices,
      );

      answers.add(
        QuizAnswer(
          questionNo: question.questionNo ?? 0,
          questionText: _cleanQuestionText(question.questionText ?? ''),
          questionType: question.questionType ?? 1,
          selectedOptionIndices: selectedIndices,
          selectedOptionTexts: selectedTexts
              .map((t) => _cleanHtmlTags(t))
              .toList(),
          isCorrect: isCorrect,
          timeSpent: 0, // You can track time per question if needed
        ),
      );
    }

    return {
      'setId': setId,
      'setNo': setNo,
      'answers': answers,
      'totalTimeSpent': totalTimeSpent,
      'autoSubmitted': autoSubmitted,
    };
  }

  String _cleanQuestionText(String text) {
    // Use the same cleaning logic from your QuestionScreen
    if (text.isEmpty) return '';
    String cleaned = text;
    cleaned = cleaned.replaceFirst(RegExp(r'^প্রশ্ন\s+[\d০-৯]+\.\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s+'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.'), '');
    cleaned = cleaned.trimLeft();
    cleaned = _cleanHtmlTags(cleaned);
    return cleaned;
  }

  String _cleanHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';
    htmlString = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    htmlString = htmlString.replaceAll(RegExp(r'\s+'), ' ');
    return htmlString.trim();
  }
}
