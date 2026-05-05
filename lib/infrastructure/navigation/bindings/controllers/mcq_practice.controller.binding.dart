import 'package:get/get.dart';

import '../../../../presentation/mcqPractice/controllers/mcq_practice.controller.dart';

class McqPracticeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<McqPracticeController>(
      () => McqPracticeController(),
    );
  }
}
