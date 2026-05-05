import 'package:get/get.dart';

import '../../../../presentation/subjective/controllers/subjective.controller.dart';

class SubjectiveControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectiveController>(
      () => SubjectiveController(),
    );
  }
}
