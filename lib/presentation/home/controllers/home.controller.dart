// controllers/home.controller.dart
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/dal/model/feature_card_data.dart';
import 'package:edupro/infrastructure/dal/model/scoreboard_model.dart';
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final activeNavIndex = 0.obs;
  final userName = 'John Doe'.obs;
  final userInitials = 'JD'.obs;
  final userXP = 0.obs;
  final isScoreLoading = false.obs;
  final scoreErrorMessage = ''.obs;
  final dashboardData = Rx<DashboardData?>(null);

  final List<FeatureCardData> featureCards = const [
    FeatureCardData(
      Icons.help_outline_rounded,
      'MCQ Practice',
      'Topic-wise multiple choice questions with instant feedback',
    ),
    FeatureCardData(
      Icons.account_balance_outlined,
      'BCS Questions',
      'Bangladesh Civil Service bank, real exam style',
    ),
    FeatureCardData(
      Icons.view_in_ar_rounded,
      'Description',
      'Surprise questions from all categories',
    ),
    FeatureCardData(
      Icons.checklist_rounded,
      'Mock Exam',
      'Full-length simulated test with scoring',
    ),
    FeatureCardData(
      Icons.cast_for_education_rounded,
      'Subjective',
      'Written answer practice with model solutions',
    ),
    FeatureCardData(
      Icons.bar_chart_rounded,
      'Scoreboard',
      'Track your rank and progress over time',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    loadUserTotalScore();
  }

  void _loadUserData() {
    final name = UserCache.getUserName()?.trim();
    userName.value = name == null || name.isEmpty ? 'Guest' : name;
    userInitials.value = _initialsFromName(userName.value);
  }

  Future<void> loadUserTotalScore() async {
    final studentId = UserCache.getUesrId();
    if (studentId == null) {
      scoreErrorMessage.value = 'User not found';
      return;
    }

    isScoreLoading.value = true;
    scoreErrorMessage.value = '';

    try {
      final requestPayload = APIRequestParam(
        path: ApiEndPoints.quizModule.getDashboardData(studentId),
        options: UserCache.getOption(),
      );

      final response = await AppApiProvider.instance.get(requestPayload);
      response.fold(
        (_) {
          scoreErrorMessage.value = 'Score unavailable';
        },
        (success) {
          final res = BaseResponse.fromJson(success.data);
          final data = res.obj ?? res.data;
          DashboardData? parsedData;
          if (data is Map<String, dynamic>) {
            parsedData = DashboardData.fromJson(data);
          } else if (data is Map) {
            parsedData = DashboardData.fromJson(data.cast<String, dynamic>());
          }

          if (parsedData != null) {
            dashboardData.value = parsedData;
            userXP.value = parsedData.totalScore;
          } else {
            scoreErrorMessage.value = 'Score unavailable';
          }
        },
      );
    } catch (e) {
      scoreErrorMessage.value = 'Score unavailable';
      debugPrint('Failed to load total score: $e');
    } finally {
      isScoreLoading.value = false;
    }
  }

  Future<void> setActiveNav(int index) async {
    if (index == 0 || index == activeNavIndex.value) return;

    activeNavIndex.value = index;
    final route = switch (index) {
      1 => Routes.MCQ_PRACTICE,
      2 => Routes.MOCK_EXAM,
      3 => Routes.SCOREBOARD,
      4 => Routes.SETTING,
      _ => null,
    };

    if (route == null) {
      activeNavIndex.value = 0;
      return;
    }

    try {
      await Get.toNamed(route);
    } finally {
      activeNavIndex.value = 0;
      if (index != 4) {
        loadUserTotalScore();
      }
    }
  }

  void onCardTap(String title) {
    debugPrint('Tapped on: $title');
    switch (title) {
      case 'MCQ Practice':
        Get.toNamed(Routes.MCQ_PRACTICE);
        break;
      case 'BCS Questions':
        Get.toNamed(Routes.BCS);
        break;
      case 'Description':
        Get.toNamed(Routes.DESCRIPTION);
        break;
      case 'Mock Exam':
        Get.toNamed(Routes.MOCK_EXAM);
        break;
      case 'Subjective':
        Get.toNamed(Routes.SUBJECTIVE);
        break;
      default:
        Get.toNamed(Routes.SCOREBOARD);
        break;
    }
  }

  void updateUserData(String name, int xp) {
    userName.value = name;
    userXP.value = xp;
    userInitials.value = _initialsFromName(name);
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return 'G';
  }
}
