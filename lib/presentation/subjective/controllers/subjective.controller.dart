import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/question_set.model.dart';
import 'package:edupro/infrastructure/dal/model/subject_wise_response.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:edupro/presentation/subjective/subjective_set_vew.dart';
import 'package:edupro/utils/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Models for Question Data

class SubjectiveController extends GetxController {
  final isLoading = false.obs;
  final isQuestionsLoading = false.obs;
  final errorMessage = ''.obs;
  final subjectList = <String>[].obs;
  final questionSets = <QuestionSet>[].obs;
  final selectedSubject = ''.obs;
  final selectedQuestionSet = Rxn<QuestionSet>();

  @override
  void onInit() {
    getGroupList();
    super.onInit();
  }

  // Existing method to get subject list
  Future<void> getGroupList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.subjectGroup,
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          errorMessage.value = _getErrorMessage(error);
          if (kDebugMode) {
            print('Error in getQuizList: $error');
          }
        },
        (success) {
          try {
            final res = BaseResponse.fromJson(success.data);
            if (res.data != null && res.data is List) {
              subjectList.value = List<String>.from(res.data);
              if (kDebugMode) {
                print('Successfully loaded ${subjectList.length} subjects');
              }
            } else {
              subjectList.clear();
              errorMessage.value = 'Invalid data format received';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response data';
            if (kDebugMode) {
              print('Parse error: $e');
            }
          }
        },
      );
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      if (kDebugMode) {
        print('Error in getQuizList: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // New method to get subject-wise questions
  Future<void> getSubjectWiseQuestions(String subject) async {
    loader();
    try {
      isQuestionsLoading.value = true;
      errorMessage.value = '';
      selectedSubject.value = subject;

      final options = UserCache.getOption();
      print(
        "${ApiEndPoints.quizModule.subjectWiseQuestions}?subjectGroup=$subject",
      );
      final requestPayload = APIRequestParam(
        path:
            '${ApiEndPoints.quizModule.subjectWiseQuestions}?subjectGroup=$subject',
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          hideLoader();
          errorMessage.value = _getErrorMessage(error);
          if (kDebugMode) {
            print('Error in getSubjectWiseQuestions: $error');
          }
        },
        (success) {
          try {
            final res = SubjectWiseResponse.fromJson(success.data);
            hideLoader();
            if (res.success && res.items.isNotEmpty) {
              questionSets.value = res.items;

              Get.to(
                () => SubjectiveSetVew(title: subject),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );

              // if (kDebugMode) {
              //   print('Successfully loaded ${res.items.length} question sets for $subject');
              //   print('Total questions: ${res.items.fold(0, (sum, set) => sum + set.totalQuestions)}');
              // }
            } else {
              // questionSets.clear();
              // errorMessage.value = res.message.isNotEmpty
              //     ? res.message
              //     : 'No questions found for this subject';
            }
          } catch (e) {
            hideLoader();
            errorMessage.value = 'Failed to parse questions data';
            if (kDebugMode) {
              print('Parse error: $e');
            }
          }
        },
      );
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      if (kDebugMode) {
        print('Error in getSubjectWiseQuestions: $e');
      }
    } finally {
      isQuestionsLoading.value = false;
    }
  }

  // Method to get specific question set
  Future<void> getQuestionSetByNumber(String subject, int setNo) async {
    try {
      isQuestionsLoading.value = true;
      errorMessage.value = '';

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path:
            '${ApiEndPoints.quizModule.subjectWiseQuestions}/$subject/set/$setNo',
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
        (error) {
          errorMessage.value = _getErrorMessage(error);
        },
        (success) {
          try {
            final res = SubjectWiseResponse.fromJson(success.data);
            if (res.success && res.items.isNotEmpty) {
              selectedQuestionSet.value = res.items.first;
            } else {
              selectedQuestionSet.value = null;
              errorMessage.value = res.message.isNotEmpty
                  ? res.message
                  : 'Question set not found';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse question set';
          }
        },
      );
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
    } finally {
      isQuestionsLoading.value = false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unexpected error occurred. Please try again.';
  }

  void onSubjectTap(String subject) {
    getSubjectWiseQuestions(subject);
  }

  void onQuestionSetTap(QuestionSet questionSet) {
    selectedQuestionSet.value = questionSet;
    // Navigate to question detail screen
    // Get.toNamed('/quiz-details', arguments: {'questionSet': questionSet});
  }

  void retry() {
    if (selectedSubject.value.isNotEmpty) {
      getSubjectWiseQuestions(selectedSubject.value);
    } else {
      getGroupList();
    }
  }

  void clearSelectedSubject() {
    selectedSubject.value = '';
    questionSets.clear();
    selectedQuestionSet.value = null;
  }
}
