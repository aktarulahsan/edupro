import 'package:edupro/infrastructure/dal/model/exam_set.model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading exam sets...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                          colors: [
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
                          const SizedBox(height: 4),
                          // Text(
                          //   'Set ${examSet.setNo}',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_filled,
                      color: Colors.blue.shade600,
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
                        examSet.setNo
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
}
