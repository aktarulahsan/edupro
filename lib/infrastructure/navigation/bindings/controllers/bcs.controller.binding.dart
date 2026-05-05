import 'package:get/get.dart';

import '../../../../presentation/bcs/controllers/bcs.controller.dart';

class BcsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BcsController>(
      () => BcsController(),
    );
  }
}
