import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var mobileNumber = ''.obs;
  var country = 'Bangladesh'.obs;
  var gender = 'Male'.obs;
  
  var isLoading = false.obs;

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    
    isLoading.value = true;

    final requestPayload = APIRequestParam(
      path: ApiEndPoints.authModule.registration,
      data: {
        "frist_name": firstName.value,
        "last_name": lastName.value,
        "emailAddress": email.value,
        "password": password.value,
        "mobile_number": mobileNumber.value,
        "country": country.value,
        "gender": gender.value,
        "status": 1,
      },
    );

    try {
      final response = await AppApiProvider.instance.post(requestPayload);
      response.fold(
        (error) {
          isLoading.value = false;
          Get.snackbar("Error", error.message ?? "Registration failed. Try again.");
        },
        (success) {
          isLoading.value = false;
          try {
            BaseResponse res = BaseResponse.fromJson(success.data);
            if (res.success == true) {
              Get.snackbar("Success", "Registration successful. Please log in.");
              Get.offNamed(Routes.AUTH);
            } else {
              Get.snackbar("Error", res.message ?? "Registration failed.");
            }
          } catch (e) {
            Get.snackbar("Error", "Failed to parse registration response.");
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
