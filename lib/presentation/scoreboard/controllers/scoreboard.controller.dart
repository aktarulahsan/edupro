import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/scoreboard_model.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:get/get.dart';

class ScoreboardController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rx<DashboardData?>(null);
  final selectedSubmissionIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardData();
  }

  Future<void> getDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = UserCache.getUserData();
      final studentId = user?.userId;
      if (studentId == null) {
        errorMessage.value = 'User not found';
        isLoading.value = false;
        return;
      }

      final options = UserCache.getOption();
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getDashboardData(studentId),
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
          if (res.success == true || res.status == 'success') {
            if (res.obj != null) {
              dashboardData.value = DashboardData.fromJson(res.obj);
            } else {
              errorMessage.value = 'No data available';
            }
          } else {
            errorMessage.value = res.message ?? 'Unknown error occurred';
          }
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes min ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  String formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
