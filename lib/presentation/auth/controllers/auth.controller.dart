import 'package:edupro/infrastructure/dal/daos/baseResponse.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/service/apiService.dart';
import 'package:edupro/infrastructure/service/api_endpoint.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum AuthAPIState { loading, loaded, failure, idle }

class AuthController extends GetxController {
  //TODO: Implement AuthController
  Rx<AuthAPIState> authAPIState = Rx(AuthAPIState.idle);
  var formKey = GlobalKey<FormState>().obs;
  var checkedValue = false.obs;
  var checkboxValue = false.obs;
  var userInfo = UserModel().obs;
  final count = 0.obs;

  late Rx<UserModel> authUser;
  late Rx<String> userToken;

  void increment() => count.value++;

  Future<void> logInAsUser(String uName, String uPass) async {
    authAPIState.value = AuthAPIState.loading;
    //print(uName);
    //print(uPass);
    // API URL
    final requestPayload = APIRequestParam(
      path: ApiEndPoints.authModule.login,
      // data: {
      //   "user_name": "advlaboni81@gmail.com",
      //   "password": "Dreamers202!"
      // });
      data: {"user_name": uName, "password": uPass},
    );
    try {
      await AppApiProvider.instance.post(requestPayload).then((response) {
        response.fold(
              (error) {
            // log("Default Login Error");
            authAPIState.value = AuthAPIState.failure;
            // homeContentAPIErrorSTRING.value = error.message ?? error.dioError();
            Get.snackbar("error ", "Login info not match");
          },
              (success) async {
            UserModel user = UserModel.fromJson(success.data['payload']);
            // user.userType = UserType.user;
            // authUser = Rx<UserModel>(user);
            // userToken = Rx<String>(user.authorization!.token);
            await UserCache.clearUserData();
            await UserCache.saveUserData(user);

            if (UserCache.isAPIUser()) {
              // Get.offAllNamed(
              //   Routes.DASHBOARD,
              // );
            } else {
              // Get.offAllNamed(Routes.DASHBOARD);
            }
          },
        );
      });
    } catch (e) {
      authAPIState.value = AuthAPIState.failure;
      Get.snackbar("error ", "error");
    }
  }

  Future<void> logInAsAppUser(String uName, String uPass) async {
    authAPIState.value = AuthAPIState.loading;
    print(uName);
    print(uPass);
    // API URL
    print("Login API URL : ${ApiEndPoints.authModule.login}");
    final requestPayload = APIRequestParam(
      path: ApiEndPoints.authModule.login3(uName,uPass ),

    );

    try {
      await AppApiProvider.instance.get(requestPayload).then((response) {
        response.fold(
              (error) {
            // log("Default Login Error");
            authAPIState.value = AuthAPIState.failure;
            // homeContentAPIErrorSTRING.value = error.message ?? error.dioError();
            Get.snackbar("error ", "Login info not match");
          },
              (success) async {
            BaseResponse response = BaseResponse.fromJson(success.data);
            UserModel user = UserModel.fromJson(response.obj);
            // user.userType = UserType.user;
            authUser = Rx<UserModel>(user);
            // userToken = Rx<String>(user.authorization!.token);
            await UserCache.clearUserData();
            await UserCache.saveUserData(authUser.value);
            if (UserCache.isAPIUser()) {
              Get.offAllNamed(Routes.HOME);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          },
        );
      });
    } catch (e) {
      authAPIState.value = AuthAPIState.failure;
      Get.snackbar("error ", "error");
    }
  }

  Future<void> signin() async {
    // final prefs = await SharedPreferences.getInstance();
    //print("login");
    try {
      Get.toNamed("/home");

      /*  await ApiService.userSignIn(
          userInfo.value.emailAddress, userInfo.value.password)
          .then((value) {
        BaseResponse response = BaseResponse.fromJson(value.data);
        //print(response.toJson());
        UsersModel model = UsersModel.fromJson(response.obj);
        //print('model.emailAddress ${model.emailAddress}');

        box.remove('userInfo');
        box.write('userInfo', model.toJson());


        prefs.setString('emailAddress', model.emailAddress.toString());
        prefs.setString('frist_name', model.fristName.toString());
        prefs.setString('last_name', model.lastName.toString());
        prefs.setString('mobile_number', model.mobileNumber.toString());
        prefs.setString('userlogin', model.emailAddress.toString());

        if (response.message == "find data Successfully") {
          Get.toNamed("/");
        } else {
          // Get.snackbar("warning", "Sign up fail");
          AppUtility.showtoastMess(message: "Sign in fail");
        }
      });*/
    } catch (e) {
      // AppUtility.showtoastMess(message: e.toString());
    }
  }
}
