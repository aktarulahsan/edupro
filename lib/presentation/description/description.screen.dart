import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'controllers/description.controller.dart';

class DescriptionScreen extends GetView<DescriptionController> {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Subject Groups',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade400,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.getGroupList(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(controller.errorMessage.value);
        }

        if (controller.subjectList.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildSubjectList();
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.getGroupList(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 60,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subjects Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no subject groups available at the moment. Please check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.getGroupList(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.subjectList.length,
      itemBuilder: (context, index) {
        final subject = controller.subjectList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                _showSubjectDetails(context, subject);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.deepPurple.shade50,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Subject Group',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.quiz_outlined,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Available Quizzes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSubjectDetails(BuildContext context, String subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade50,
                            Colors.deepPurple.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.deepPurple, Colors.purple],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.school,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subject Group Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      icon: Icons.description_outlined,
                      title: 'About this Subject',
                      content:
                      'This subject group covers comprehensive topics in $subject. Designed to help students master concepts through interactive learning and assessments.',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.quiz_outlined,
                      title: 'Assessment Details',
                      content:
                      '• Multiple choice questions\n• Practice tests available\n• Progress tracking\n• Detailed performance analytics',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.timeline_outlined,
                      title: 'Learning Path',
                      content:
                      '• Beginner to advanced levels\n• Topic-wise breakdown\n• Regular assessments\n• Performance-based recommendations',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to subject details/quizzes

                          controller.getSubjectWiseQuestions(subject);

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Start Learning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Colors.deepPurple.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}