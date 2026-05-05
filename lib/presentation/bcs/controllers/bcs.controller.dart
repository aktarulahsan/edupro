import 'dart:convert';

import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/result.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/result.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BcsController extends GetxController {
  final isLoading = false.obs;
  final isUpdating = false.obs; // For background updates
  final errorMessage = Rxn<String>();
  final quizList = <QuizModel>[].obs;
  final result = Result().obs;

  // Store answers per examId
  final Map<String, Map<String, dynamic>> examAnswers = <String, Map<String, dynamic>>{}.obs;
  final Map<String, Map<String, bool>> examCorrectness = <String, Map<String, bool>>{}.obs;

  // Current active quiz
  final currentQuiz = Rxn<QuizModel>();
  final currentQuizAnswers = <String, dynamic>{}.obs;
  final currentQuizCorrectness = <String, bool>{}.obs;

  // GetStorage instance
  final GetStorage _storage = GetStorage();

  // Cache keys
  static const String _cacheKey = 'cached_quiz_data';
  static const String _cacheTimestampKey = 'cached_quiz_timestamp';
  static const String _answersCacheKey = 'exam_answers_cache';
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Performance optimization
  bool _isFetching = false;
  bool _initialLoadDone = false;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // First load from cache instantly
    await _loadCachedAnswers();
    await _loadCachedQuizzes();

    // Then fetch fresh data in background
    _fetchFreshDataInBackground();
  }

  Future<void> _loadCachedQuizzes() async {
    try {
      final cachedJson = _storage.read<String>(_cacheKey);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> cachedData = json.decode(cachedJson);
        final List<dynamic> quizzesData = cachedData['quizzes'] ?? [];

        if (quizzesData.isNotEmpty) {
          final quizzes = <QuizModel>[];
          for (var item in quizzesData) {
            if (item is Map) {
              try {
                final typedMap = item.cast<String, dynamic>();
                final quiz = QuizModel.fromJson(typedMap);
                quizzes.add(quiz);
              } catch (e) {
                debugPrint('Error parsing cached quiz: $e');
              }
            }
          }

          if (quizzes.isNotEmpty) {
            quizList.value = quizzes;
            debugPrint('Loaded ${quizzes.length} quizzes from cache instantly');
          }
        }
      }
    } catch (e) {
      debugPrint('Cache load error: $e');
    }
  }

  Future<void> _fetchFreshDataInBackground() async {
    if (_isFetching) return;

    // Small delay to ensure UI is rendered first
    await Future.delayed(const Duration(milliseconds: 100));

    await getQuizList(refresh: true, isBackground: true);
  }

  Future<void> _loadCachedAnswers() async {
    try {
      final cachedAnswers = _storage.read<String>(_answersCacheKey);
      if (cachedAnswers != null) {
        final Map<String, dynamic> allData = json.decode(cachedAnswers);

        if (allData['examAnswers'] != null) {
          examAnswers.clear();
          (allData['examAnswers'] as Map).forEach((key, value) {
            examAnswers[key] = Map<String, dynamic>.from(value);
          });
        }

        if (allData['examCorrectness'] != null) {
          examCorrectness.clear();
          (allData['examCorrectness'] as Map).forEach((key, value) {
            examCorrectness[key] = Map<String, bool>.from(value);
          });
        }

        debugPrint('Loaded answers for ${examAnswers.length} exams from cache');
      }
    } catch (e) {
      debugPrint('Error loading cached answers: $e');
    }
  }

  Future<void> _saveAnswersToCache() async {
    try {
      final cacheData = {
        'examAnswers': examAnswers.map((k, v) => MapEntry(k, v)),
        'examCorrectness': examCorrectness.map((k, v) => MapEntry(k, v)),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final answersJson = json.encode(cacheData);
      await _storage.write(_answersCacheKey, answersJson);
    } catch (e) {
      debugPrint('Error saving answers to cache: $e');
    }
  }

  Future<void> getQuizList({bool refresh = false, bool isBackground = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!isBackground) {
      isLoading.value = true;
    } else {
      isUpdating.value = true;
    }

    errorMessage.value = null;

    try {
      final options = UserCache.getOption();

      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getQuizList,
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet.');
        },
      );

      response.fold(
            (error) {
          if (!isBackground) {
            errorMessage.value = _getErrorMessage(error);
          }
          isLoading.value = false;
          isUpdating.value = false;
          _isFetching = false;
        },
            (success) async {
          try {
            final baseResponse = BaseResponse.fromJson(success.data);

            List<QuizModel> parsedQuizzes = await compute(_parseQuizzesInBackground, {
              'data': baseResponse.data,
              'refresh': refresh,
            });

            // Update UI with new data
            quizList.value = parsedQuizzes;

            // Save to cache
            if (quizList.isNotEmpty) {
              await _saveToCache(quizList);
              debugPrint('Saved ${quizList.length} quizzes to cache');
            }

            isLoading.value = false;
            isUpdating.value = false;
            _isFetching = false;
          } catch (e) {
            debugPrint('Parse error: $e');
            if (!isBackground) {
              errorMessage.value = 'Failed to load quiz data';
            }
            isLoading.value = false;
            isUpdating.value = false;
            _isFetching = false;
          }
        },
      );
    } catch (e) {
      debugPrint('Network error: $e');
      if (!isBackground) {
        errorMessage.value = 'Unable to connect. Please check your connection.';
      }
      isLoading.value = false;
      isUpdating.value = false;
      _isFetching = false;
    }
  }

  static List<QuizModel> _parseQuizzesInBackground(Map<String, dynamic> params) {
    final data = params['data'];
    List<QuizModel> parsedQuizzes = [];

    if (data != null) {
      if (data is Map) {
        final typedMap = data.cast<String, dynamic>();
        final quiz = QuizModel.fromJson(typedMap);
        parsedQuizzes.add(quiz);
      } else if (data is List) {
        for (var item in data) {
          if (item is Map) {
            final typedMap = item.cast<String, dynamic>();
            final quiz = QuizModel.fromJson(typedMap);
            parsedQuizzes.add(quiz);
          }
        }
      } else if (data is String) {
        final decoded = json.decode(data);
        if (decoded is Map) {
          final typedMap = decoded.cast<String, dynamic>();
          final quiz = QuizModel.fromJson(typedMap);
          parsedQuizzes.add(quiz);
        } else if (decoded is List) {
          for (var item in decoded) {
            if (item is Map) {
              final typedMap = item.cast<String, dynamic>();
              final quiz = QuizModel.fromJson(typedMap);
              parsedQuizzes.add(quiz);
            }
          }
        }
      }
    }

    return parsedQuizzes;
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString().replaceAll('Exception:', '').trim();
    return 'An unexpected error occurred';
  }

  Future<void> _saveToCache(List<QuizModel> data) async {
    try {
      final cacheData = {
        'quizzes': data.map((e) => e.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonData = json.encode(cacheData);
      await _storage.write(_cacheKey, jsonData);
      await _storage.write(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  // Load answers for a specific exam
  void loadExamAnswers(String examId, List<QuizList> questions) {
    if (examAnswers.containsKey(examId)) {
      currentQuizAnswers.assignAll(examAnswers[examId]!);
      currentQuizCorrectness.assignAll(examCorrectness[examId] ?? {});
    } else {
      currentQuizAnswers.clear();
      currentQuizCorrectness.clear();
    }
    debugPrint('Loaded answers for exam $examId: ${currentQuizAnswers.length} answers');
  }

  // Save answer for current exam
  void saveCurrentQuizAnswer(String examId, String questionId, dynamic answer, QuizList question) {
    // Save answer
    currentQuizAnswers[questionId] = answer;
    examAnswers[examId] = Map.from(currentQuizAnswers);

    // Check correctness
    final isCorrect = _checkIfAnswerCorrect(question, answer);
    currentQuizCorrectness[questionId] = isCorrect;
    examCorrectness[examId] = Map.from(currentQuizCorrectness);

    // Save to cache
    _saveAnswersToCache();

    debugPrint('Saved answer for exam $examId, question $questionId: $answer, Correct: $isCorrect');
  }

  bool _checkIfAnswerCorrect(QuizList question, dynamic answer) {
    if (question.optionList == null) return false;

    final correctOptions = question.optionList!
        .where((opt) => opt.correct == true)
        .map((opt) => opt.optionId)
        .toList();

    if (question.questionType == 2) {
      if (answer is List) {
        final sortedAnswer = List.from(answer)..sort();
        final sortedCorrect = List.from(correctOptions)..sort();
        return ListEquality().equals(sortedAnswer, sortedCorrect);
      }
      return false;
    } else {
      return correctOptions.contains(answer);
    }
  }

  bool isQuestionAnswered(String examId, String questionId) {
    return examAnswers[examId]?.containsKey(questionId) ?? false;
  }

  bool? isAnswerCorrect(String examId, String questionId) {
    return examCorrectness[examId]?[questionId];
  }

  dynamic getUserAnswer(String examId, String questionId) {
    return examAnswers[examId]?[questionId];
  }

  // Get statistics for an exam
  int getExamAnsweredCount(String examId) {
    return examAnswers[examId]?.length ?? 0;
  }

  int getExamCorrectCount(String examId) {
    return examCorrectness[examId]?.values.where((v) => v == true).length ?? 0;
  }

  int getExamIncorrectCount(String examId) {
    return examCorrectness[examId]?.values.where((v) => v == false).length ?? 0;
  }

  // Get overall statistics
  int getTotalExamsAttended() {
    return examAnswers.keys.length;
  }

  int getTotalQuestionsAcrossAllExams() {
    int total = 0;
    for (var quiz in quizList) {
      total += quiz.quizList?.length ?? 0;
    }
    return total;
  }

  int getTotalAnsweredAcrossAllExams() {
    int total = 0;
    for (var examId in examAnswers.keys) {
      total += examAnswers[examId]?.length ?? 0;
    }
    return total;
  }

  int getTotalCorrectAcrossAllExams() {
    int total = 0;
    for (var examId in examCorrectness.keys) {
      total += examCorrectness[examId]?.values.where((v) => v == true).length ?? 0;
    }
    return total;
  }

  // Clear answers for a specific exam
  void clearExamAnswers(String examId) {
    examAnswers.remove(examId);
    examCorrectness.remove(examId);
    if (currentQuiz.value?.examId == examId) {
      currentQuizAnswers.clear();
      currentQuizCorrectness.clear();
    }
    _saveAnswersToCache();
    debugPrint('Cleared answers for exam $examId');
  }

  // Clear all answers
  void clearAllAnswers() {
    examAnswers.clear();
    examCorrectness.clear();
    currentQuizAnswers.clear();
    currentQuizCorrectness.clear();
    _saveAnswersToCache();
    debugPrint('Cleared all exam answers');
  }

  void retry() => getQuizList(refresh: true);

  Future<void> clearCache() async {
    try {
      await _storage.remove(_cacheKey);
      await _storage.remove(_cacheTimestampKey);
      await _storage.remove(_answersCacheKey);
      clearAllAnswers();
      await getQuizList(refresh: true);
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  @override
  void onClose() {
    quizList.clear();
    examAnswers.clear();
    examCorrectness.clear();
    currentQuizAnswers.clear();
    currentQuizCorrectness.clear();
    super.onClose();
  }
}