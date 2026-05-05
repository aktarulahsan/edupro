import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/mock_exam.controller.dart';

class MockExamScreen extends GetView<MockExamController> {
  const MockExamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MockExamScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MockExamScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
