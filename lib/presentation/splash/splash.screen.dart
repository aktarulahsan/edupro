import 'package:edupro/infrastructure/constant/resources.dart';
import 'package:flutter/material.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/navigation/bindings/controllers/auth.controller.binding.dart';
import 'package:edupro/infrastructure/navigation/bindings/controllers/home.controller.binding.dart';
import 'package:edupro/presentation/auth/auth.screen.dart';
import 'package:edupro/presentation/home/home.screen.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:get/get.dart';

import 'controllers/splash.controller.dart';

// class SplashScreen extends GetView<SplashController> {
//   const SplashScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 5), () {
//       UserCache.getUesrId() !=null? Get.offAll(() => const HomeScreen(), binding: HomeControllerBinding())
//           :Get.offAll(() => const AuthScreen(), binding: AuthControllerBinding());
//     });
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Image.asset(
//           R.ASSETS_IMAGES_LOGO_PNG,
//         ).animate().scale(duration: 2000.ms).then()
import 'package:edupro/infrastructure/constant/resources.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/navigation/bindings/controllers/auth.controller.binding.dart';
import 'package:edupro/infrastructure/navigation/bindings/controllers/home.controller.binding.dart';
import 'package:edupro/presentation/auth/auth.screen.dart';
import 'package:edupro/presentation/home/home.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Build সম্পূর্ণ হওয়ার পর navigation শুরু করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));

    // Widget এখনও mounted কিনা চেক করুন
    if (!mounted) return;

    final userId = await UserCache.getUesrId();
    print("userId: $userId");

    if (userId != null) {
      Get.offAll(() => const HomeScreen(), binding: HomeControllerBinding());
    } else {
      Get.offAll(() => const AuthScreen(), binding: AuthControllerBinding());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: Image.asset(
          R.ASSETS_IMAGES_LOGO_PNG,
        ).animate().scale(duration: 2000.ms).then()..shimmer(),
      ),
    );
  }
}
