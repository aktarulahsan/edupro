import 'package:get/get.dart';

import '../../../../presentation/mockExam/controllers/mock_exam.controller.dart';

class MockExamControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockExamController>(
      () => MockExamController(),
    );
  }
}
