import 'package:get/get.dart';

import '../../../../presentation/description/controllers/description.controller.dart';

class DescriptionControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DescriptionController>(
      () => DescriptionController(),
    );
  }
}
