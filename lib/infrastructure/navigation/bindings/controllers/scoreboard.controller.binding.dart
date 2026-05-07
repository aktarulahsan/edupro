import 'package:get/get.dart';

import '../../../../presentation/scoreboard/controllers/scoreboard.controller.dart';

class ScoreboardControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoreboardController>(
      () => ScoreboardController(),
    );
  }
}
