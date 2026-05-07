import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  EnvironmentsBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthScreen(),
      binding: AuthControllerBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashControllerBinding(),
    ),
    GetPage(
      name: Routes.MCQ_PRACTICE,
      page: () => const McqPracticeScreen(),
      binding: McqPracticeControllerBinding(),
    ),
    GetPage(
      name: Routes.BCS,
      page: () => const BcsScreen(),
      binding: BcsControllerBinding(),
    ),
    GetPage(
      name: Routes.MOCK_EXAM,
      page: () => const MockExamScreen(),
      binding: MockExamControllerBinding(),
    ),
    GetPage(
      name: Routes.SUBJECTIVE,
      page: () => const SubjectiveScreen(),
      binding: SubjectiveControllerBinding(),
    ),
    GetPage(
      name: Routes.DESCRIPTION,
      page: () => const DescriptionScreen(),
      binding: DescriptionControllerBinding(),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => const SettingScreen(),
      binding: SettingControllerBinding(),
    ),
    GetPage(
      name: Routes.SCOREBOARD,
      page: () => const ScoreboardScreen(),
      binding: ScoreboardControllerBinding(),
    ),
  ];
}
