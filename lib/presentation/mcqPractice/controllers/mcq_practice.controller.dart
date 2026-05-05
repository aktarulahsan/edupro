import 'dart:convert';

import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/exam_set.model.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:edupro/presentation/mcqPractice/question_screen.dart';
import 'package:edupro/utils/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class McqPracticeController extends GetxController {
  final isLoading = false.obs;
  final isQuestionsLoading = false.obs;
  final examSetList = <ExamSetModel>[].obs;
  final questionList = <QuizList>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getQuizList();
  }

  Future<void> getQuizList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.generateQuizSet,
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
              (error) {
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
              (success) {
            final res = BaseResponse.fromJson(success.data);
            examSetList.value = examSetModelPostFromJson(json.encode(res.items));
            isLoading.value = false;
          }
      );
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      // if (kDebugMode) {
      //   print('Error in getQuizList: $e');
      // }
    }
  }

  Future<void> getQuestBySetId(String setId, String title) async {
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
            questionList.value = quizListPostFromJson(json.encode(res.items));
            isQuestionsLoading.value = false;

            if (questionList.isNotEmpty) {
              print("Questions length: ${questionList.length}");

              // Ensure loader is hidden before navigation
              hideLoader();

              // Use a small delay to ensure the dialog is completely closed
              Future.delayed(const Duration(milliseconds: 100), () {
                if (Get.context != null) {
                  Get.to(
                        () => QuestionScreen(
                      quizList: questionList.toList(),
                      title: title,
                    ),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                }
              });
            } else {
              hideLoader();
              print("No questions available");
              Get.snackbar(
                'Info',
                "No questions available",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
      );
    } catch (e) {
      isQuestionsLoading.value = false;
      hideLoader();
      print("Error in getQuestBySetId: $e");
      Get.snackbar(
        'Error',
        'An error occurred while loading questions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}