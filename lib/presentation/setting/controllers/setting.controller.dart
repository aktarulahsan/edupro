import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  final user = Rxn<UserModel>();
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    user.value = UserCache.getUserData();
  }

  Future<void> signOut() async {
    await UserCache.clearUserData();
    Get.offAllNamed(Routes.AUTH);
  }

  Future<void> revokeAccount() async {
    await UserCache.clearUserData();
    Get.offAllNamed(Routes.AUTH);
  }

  void increment() => count.value++;
}
