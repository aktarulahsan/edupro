import 'package:get/get.dart';

import '../../../../presentation/setting/controllers/setting.controller.dart';

class SettingControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(
      () => SettingController(),
    );
  }
}
