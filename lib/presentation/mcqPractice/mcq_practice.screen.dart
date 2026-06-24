import 'package:edupro/infrastructure/dal/model/exam_set.model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../infrastructure/theme/app_colors.dart';
import '../../infrastructure/theme/app_bar_helper.dart';
import 'controllers/mcq_practice.controller.dart';

class McqPracticeScreen extends GetView<McqPracticeController> {
  const McqPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHelper.buildSimpleAppBar(
        title: 'MCQ Practice',
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ExamSetSkeletonList();
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.getQuizList(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.examSetList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No exam sets available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getQuizList(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.examSetList.length,
            itemBuilder: (context, index) {
              final examSet = controller.examSetList[index];
              return _buildExamSetCard(context, examSet, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildExamSetCard(
    BuildContext context,
    ExamSetModel examSet,
    int index,
  ) {
    final isPass = examSet.passed ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: isPass ? Border.all(color: Colors.green.shade300, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isPass ? Colors.green.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStartDialog(context, examSet, index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPass
                              ? [
                                  Colors.green.shade400,
                                  Colors.teal.shade400,
                                ]
                              : [
                                  Colors.blue.shade400,
                                  Colors.purple.shade400,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'S-${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Set ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          _buildScoreBadge(examSet),
                        ],
                      ),
                    ),
                    Icon(
                      isPass ? Icons.check_circle_rounded : Icons.play_circle_filled,
                      color: isPass ? Colors.green.shade600 : Colors.blue.shade600,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: _formatDate(examSet.createdAt),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.question_answer,
                      label: 'Questions',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // In McqPracticeScreen - Update the _showStartDialog method
  void _showStartDialog(BuildContext context, ExamSetModel examSet, int index) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.quiz_rounded, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                // examSet.setName,
                'Global Set ${index + 1}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogInfoRow(
              Icons.format_list_numbered,
              'Set Number',
              '${examSet.setNo}',
            ),
            const SizedBox(height: 12),
            _buildDialogInfoRow(
              Icons.calendar_today,
              'Created',
              _formatDate(examSet.createdAt),
            ),
            const SizedBox(height: 12),
            _buildDialogInfoRow(Icons.access_time, 'Duration', '30 minutes'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Answer all questions to complete the quiz',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isQuestionsLoading.value
                  ? null
                  : () async {
                      // Close the dialog first
                      Navigator.of(dialogContext).pop();

                      // Wait a frame for the dialog to close completely
                      await Future.delayed(Duration.zero);

                      // Then load questions with the original context
                      controller.getQuestBySetId(
                        examSet.setNo.toString(),
                        examSet.setName,
                        examSet.setNo,
                        // context, // Use the original screen context, not dialog context
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: controller.isQuestionsLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Start Quiz'),
            ),
          ),
        ],
      ),
    );
  }
  // void _showStartDialog(BuildContext context, ExamSetModel examSet) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade50,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Icon(
  //               Icons.quiz_rounded,
  //               color: Colors.blue.shade700,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               examSet.setName,
  //               style: const TextStyle(fontSize: 18),
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildDialogInfoRow(Icons.format_list_numbered, 'Set Number', '${examSet.setNo}'),
  //           const SizedBox(height: 12),
  //           _buildDialogInfoRow(Icons.calendar_today, 'Created', _formatDate(examSet.createdAt)),
  //           const SizedBox(height: 12),
  //           _buildDialogInfoRow(Icons.access_time, 'Duration', '30 minutes'),
  //           const SizedBox(height: 16),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade50,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: const Row(
  //               children: [
  //                 Icon(Icons.info_outline, size: 16, color: Colors.blue),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Answer all questions to complete the quiz',
  //                     style: TextStyle(fontSize: 12, color: Colors.blue),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         Obx(() => ElevatedButton(
  //           onPressed: controller.isQuestionsLoading.value
  //               ? null
  //               : () {
  //             // Navigator.pop(context);
  //             controller.getQuestBySetId(
  //               examSet.setNo.toString(),
  //               examSet.setName,
  //               context,
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.blue,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //           child: controller.isQuestionsLoading.value
  //               ? const SizedBox(
  //             width: 20,
  //             height: 20,
  //             child: CircularProgressIndicator(
  //               strokeWidth: 2,
  //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //             ),
  //           )
  //               : const Text('Start Quiz'),
  //         )),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildScoreBadge(ExamSetModel examSet) {
    if (examSet.userScore == null) return const SizedBox.shrink();

    final isPass = examSet.passed ?? false;
    final score = examSet.userScore;
    final total = examSet.userTotalQuestions ?? 10;

    final bgColor = isPass ? Colors.green.shade50 : Colors.red.shade50;
    final textColor = isPass ? Colors.green.shade800 : Colors.red.shade800;
    final icon = isPass ? Icons.check_circle_outline : Icons.highlight_off;
    final text = isPass ? 'Passed: $score/$total' : 'Failed: $score/$total';

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamSetSkeletonList extends StatelessWidget {
  const _ExamSetSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          height: 116,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              _SkeletonBox(width: 50, height: 50, radius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 150, height: 16),
                    SizedBox(height: 12),
                    _SkeletonBox(width: 105, height: 12),
                  ],
                ),
              ),
              _SkeletonBox(width: 30, height: 30, radius: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
