

import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/question_set.model.dart';
import 'package:edupro/infrastructure/dal/model/subject_wise_response.dart';

import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:edupro/presentation/description/description_set_view.dart';
import 'package:edupro/utils/loader.dart';
import 'package:get/get.dart';

class DescriptionController extends GetxController {
  //TODO: Implement DescriptionController

  final errorMessage = ''.obs;
  final subjectList = <String>[].obs;
  final isLoading = false.obs;
  final questionSets = <QuestionSet>[].obs;
  final selectedSubject = ''.obs;

  @override
  void onInit() {
    getGroupList();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  Future<void> getGroupList() async {
    try {
      isLoading.value = true;
      // loader();
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

        },
            (success) {
          try {
            final res = BaseResponse.fromJson(success.data);
            if (res.data != null && res.data is List) {
              subjectList.value = List<String>.from(res.data);

            } else {
              subjectList.clear();
              errorMessage.value = 'Invalid data format received';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response data';
            // if (kDebugMode) {
            //   print('Parse error: $e');
            // }
          }
        },
      );
    } catch (e) {
      // hideLoader();
      errorMessage.value = _getErrorMessage(e);
      // if (kDebugMode) {
      //   print('Error in getQuizList: $e');
      // }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubjectWiseQuestions(String subject) async {
    loader();
    try {
      // isQuestionsLoading.value = true;
      errorMessage.value = '';
      // selectedSubject.value = subject;

      final options = UserCache.getOption();
      print("${ApiEndPoints.quizModule.subjectWiseQuestions}?subjectGroup=$subject");
      final requestPayload = APIRequestParam(
        path: '${ApiEndPoints.quizModule.subjectWiseQuestions}?subjectGroup=$subject',
        options: options,
      );

      final response = await AppApiProvider.instance.get(requestPayload);

      response.fold(
            (error) {
          hideLoader();
          errorMessage.value = _getErrorMessage(error);
          // if (kDebugMode) {
          //   print('Error in getSubjectWiseQuestions: $error');
          // }
        },
            (success) {
          try {
            final res = SubjectWiseResponse.fromJson(success.data);
            hideLoader();
            if (res.success && res.items.isNotEmpty) {
              questionSets.value = res.items;

              Get.to(
                    () => DescriptionSetView(title: subject,),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );


            } else {

            }
          } catch (e) {
            hideLoader();
            errorMessage.value = 'Failed to parse questions data';

          }
        },
      );
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);

    } finally {
      // isQuestionsLoading.value = false;
    }
  }





  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unexpected error occurred. Please try again.';
  }


}
