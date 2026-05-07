import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../infrastructure/theme/app_colors.dart';
import '../../infrastructure/theme/app_bar_helper.dart';
import 'controllers/mock_exam.controller.dart';

class MockExamScreen extends GetView<MockExamController> {
  const MockExamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHelper.buildSimpleAppBar(
        title: 'Mock Exam',
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MockExam is coming soon',
          style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
