import 'package:edupro/infrastructure/dal/model/question_set.model.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'controllers/description.controller.dart';

class DescriptionSetView extends StatefulWidget {
  final String title;

  const DescriptionSetView({super.key, required this.title});

  @override
  State<DescriptionSetView> createState() => _DescriptionSetViewState();
}

class _DescriptionSetViewState extends State<DescriptionSetView> {
  final DescriptionController controller = Get.find<DescriptionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.questionSets.isEmpty && controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(controller.errorMessage.value);
        }

        if (controller.questionSets.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildQuestionSetsList();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      foregroundColor: AppColors.appBarForeground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
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
                color: AppColors.errorLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.getSubjectWiseQuestions(widget.title),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                color: AppColors.warningLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 60,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Question Sets Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no question sets available for ${widget.title} at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.getSubjectWiseQuestions(widget.title),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildQuestionSetsList() {
    final sets = controller.questionSets;
    final totalQuestions = sets.fold<int>(
      0,
      (sum, set) => sum + (set.totalQuestions ?? 0),
    );

    return Column(
      children: [
        _buildSummaryCard(totalQuestions, sets.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return _buildQuestionSetCard(set, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int totalQuestions, int setCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.quiz,
            label: 'Total Questions',
            value: totalQuestions.toString(),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildSummaryItem(
            icon: Icons.folder_special,
            label: 'Question Sets',
            value: setCount.toString(),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildSummaryItem(
            icon: Icons.timer,
            label: 'Est. Time',
            value: '${totalQuestions * 2} min',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildQuestionSetCard(QuestionSet set, int setNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _navigateToQuestionDetails(set, setNumber),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1),
            ),
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '$setNumber',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                            set.setName ?? 'Question Set $setNumber',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.help_outline,
                                label: '${set.totalQuestions} Questions',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.timer_outlined,
                                label: '${(set.totalQuestions ?? 0) * 2} min',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (set.questions != null && set.questions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Includes ${set.questions!.length} questions with detailed explanations',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // New screen for showing questions with explanations
  void _navigateToQuestionDetails(QuestionSet set, int setNumber) {
    Get.to(
      () => QuestionDetailsScreen(
        questionSet: set,
        setNumber: setNumber,
        subjectTitle: widget.title,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  String _getQuestionType(int? type) {
    switch (type) {
      case 1:
        return 'Multiple Choice';
      case 2:
        return 'Single Choice';
      case 3:
        return 'True/False';
      default:
        return 'Standard';
    }
  }

  void _startQuiz(QuestionSet set) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ready to Start?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set: ${set.setName}'),
            const SizedBox(height: 8),
            Text('Total Questions: ${set.totalQuestions}'),
            const SizedBox(height: 8),
            Text('Estimated Time: ${(set.totalQuestions ?? 0) * 2} minutes'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Read each question carefully and select the best answer. You can review your answers before submitting.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Quiz Started',
                'Good luck with ${set.setName}!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }
}

// Separate screen for showing questions with explanations
class QuestionDetailsScreen extends StatefulWidget {
  final QuestionSet questionSet;
  final int setNumber;
  final String subjectTitle;

  const QuestionDetailsScreen({
    super.key,
    required this.questionSet,
    required this.setNumber,
    required this.subjectTitle,
  });

  @override
  State<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends State<QuestionDetailsScreen> {
  int _selectedQuestionIndex = 0;
  final PageController _pageController = PageController();

  // Helper method to clean question text by removing leading numbers
  // Helper method to clean question text by removing leading numbers and prefixes
  String _cleanQuestionText(String? text) {
    if (text == null) return '';

    String cleaned = text;

    // Remove Bengali pattern like "প্রশ্ন ১৮৬. " or "প্রশ্ন ১৬. "
    cleaned = cleaned.replaceFirst(RegExp(r'^প্রশ্ন\s+[\d০-৯]+\.\s*'), '');

    // Remove English pattern like "14. " (with space)
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s+'), '');

    // Remove English pattern like "14." (without space)
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.'), '');

    // Remove any extra spaces at the beginning
    cleaned = cleaned.trimLeft();

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questionSet.questions ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.questionSet.setName ?? 'Question Set ${widget.setNumber}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        foregroundColor: AppColors.appBarForeground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.surfaceVariant),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_selectedQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.subjectTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_selectedQuestionIndex + 1) / questions.length,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  // height: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    questions.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedQuestionIndex == index
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedQuestionIndex = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final cleanedQuestionText = _cleanQuestionText(
                  question.questionText,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.surfaceVariant,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.7),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Question No: ${question.questionNo}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getQuestionTypeColor(
                                            question.questionType,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _getQuestionType(
                                            question.questionType,
                                          ),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _getQuestionTypeColor(
                                              question.questionType,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              cleanedQuestionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Answer Section
                      // Container(
                      //   padding: const EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: AppColors.surfaceVariant,
                      //         blurRadius: 10,
                      //         offset: const Offset(0, 2),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Icon(
                      //             Icons.check_circle_outline,
                      //             size: 22,
                      //             color: Colors.green.shade600,
                      //           ),
                      //           const SizedBox(width: 8),
                      //           Text(
                      //             'Correct Answer',
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //               color: Colors.green.shade800,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const SizedBox(height: 12),
                      //       Container(
                      //         padding: const EdgeInsets.all(12),
                      //         decoration: BoxDecoration(
                      //           color: Colors.green.shade50,
                      //           borderRadius: BorderRadius.circular(12),
                      //           border: Border.all(
                      //             color: Colors.green.shade200,
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Container(
                      //               width: 30,
                      //               height: 30,
                      //               decoration: BoxDecoration(
                      //                 color: Colors.green.shade100,
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               child: Center(
                      //                 child: Text(
                      //                   _getOptionLetter(question.correctAnswer),
                      //                   style: TextStyle(
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.bold,
                      //                     color: Colors.green.shade800,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             const SizedBox(width: 12),
                      //             Expanded(
                      //               child: Text(
                      //                 _getOptionText(question.correctAnswer),
                      //                 style: TextStyle(
                      //                   fontSize: 14,
                      //                   color: Colors.green.shade900,
                      //                   fontWeight: FontWeight.w500,
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 16),

                      // Explanation Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.surfaceVariant,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 22,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.explanation ??
                                  'No explanation available for this question.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (_selectedQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                if (_selectedQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedQuestionIndex < questions.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _showCompletionDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedQuestionIndex < questions.length - 1
                          ? 'Next Question'
                          : 'Complete Review',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Great Job! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'You\'ve reviewed all ${widget.questionSet.questions?.length ?? 0} questions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Set: ${widget.questionSet.setName}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text('Back to Sets'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Start quiz action
              Get.snackbar(
                'Ready to Test?',
                'Start the quiz to test your knowledge!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Take Quiz'),
          ),
        ],
      ),
    );
  }

  String _getQuestionType(int? type) {
    switch (type) {
      case 1:
        return 'Multiple Choice';
      case 2:
        return 'Single Choice';
      case 3:
        return 'True/False';
      default:
        return 'Standard';
    }
  }

  Color _getQuestionTypeColor(int? type) {
    switch (type) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getOptionLetter(String? option) {
    if (option == null) return '?';
    switch (option.toUpperCase()) {
      case 'OPT1':
        return 'A';
      case 'OPT2':
        return 'B';
      case 'OPT3':
        return 'C';
      case 'OPT4':
        return 'D';
      default:
        return option;
    }
  }

  String _getOptionText(String? option) {
    if (option == null) return 'Not specified';
    switch (option.toUpperCase()) {
      case 'OPT1':
        return 'Option 1';
      case 'OPT2':
        return 'Option 2';
      case 'OPT3':
        return 'Option 3';
      case 'OPT4':
        return 'Option 4';
      default:
        return option;
    }
  }
}

// Separate screen for showing questions with explanations
/*
class QuestionDetailsScreen extends StatefulWidget {
  final QuestionSet questionSet;
  final int setNumber;
  final String subjectTitle;

  const QuestionDetailsScreen({
    super.key,
    required this.questionSet,
    required this.setNumber,
    required this.subjectTitle,
  });

  @override
  State<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends State<QuestionDetailsScreen> {
  int _selectedQuestionIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final questions = widget.questionSet.questions ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.questionSet.setName ?? 'Question Set ${widget.setNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        foregroundColor: AppColors.appBarForeground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.surfaceVariant,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_selectedQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.subjectTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_selectedQuestionIndex + 1) / questions.length,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  // height: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    questions.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedQuestionIndex == index
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedQuestionIndex = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.surfaceVariant,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.7),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Question No: ${question.questionNo}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.surface0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getQuestionTypeColor(
                                            question.questionType,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getQuestionType(question.questionType),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _getQuestionTypeColor(
                                              question.questionType,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              cleanQuestionText(question.questionText ?? 'Question text not available')
                              ,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Answer Section
                      // Container(
                      //   padding: const EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: AppColors.surfaceVariant,
                      //         blurRadius: 10,
                      //         offset: const Offset(0, 2),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Icon(
                      //             Icons.check_circle_outline,
                      //             size: 22,
                      //             color: Colors.green.shade600,
                      //           ),
                      //           const SizedBox(width: 8),
                      //           Text(
                      //             'Correct Answer',
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //               color: Colors.green.shade800,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const SizedBox(height: 12),
                      //       Container(
                      //         padding: const EdgeInsets.all(12),
                      //         decoration: BoxDecoration(
                      //           color: Colors.green.shade50,
                      //           borderRadius: BorderRadius.circular(12),
                      //           border: Border.all(
                      //             color: Colors.green.shade200,
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Container(
                      //               width: 30,
                      //               height: 30,
                      //               decoration: BoxDecoration(
                      //                 color: Colors.green.shade100,
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               child: Center(
                      //                 child: Text(
                      //                   _getOptionLetter(question.correctAnswer),
                      //                   style: TextStyle(
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.bold,
                      //                     color: Colors.green.shade800,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             const SizedBox(width: 12),
                      //             Expanded(
                      //               child: Text(
                      //                 _getOptionText(question.correctAnswer),
                      //                 style: TextStyle(
                      //                   fontSize: 14,
                      //                   color: Colors.green.shade900,
                      //                   fontWeight: FontWeight.w500,
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 16),

                      // Explanation Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.surfaceVariant,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 22,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.explanation ?? 'No explanation available for this question.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (_selectedQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                if (_selectedQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedQuestionIndex < questions.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _showCompletionDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedQuestionIndex < questions.length - 1
                          ? 'Next Question'
                          : 'Complete Review',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Great Job! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve reviewed all ${widget.questionSet.questions?.length ?? 0} questions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Set: ${widget.questionSet.setName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text('Back to Sets'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Start quiz action
              Get.snackbar(
                'Ready to Test?',
                'Start the quiz to test your knowledge!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Take Quiz'),
          ),
        ],
      ),
    );
  }

  String _getQuestionType(int? type) {
    switch (type) {
      case 1:
        return 'Multiple Choice';
      case 2:
        return 'Single Choice';
      case 3:
        return 'True/False';
      default:
        return 'Standard';
    }
  }

  Color _getQuestionTypeColor(int? type) {
    switch (type) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getOptionLetter(String? option) {
    if (option == null) return '?';
    switch (option.toUpperCase()) {
      case 'OPT1':
        return 'A';
      case 'OPT2':
        return 'B';
      case 'OPT3':
        return 'C';
      case 'OPT4':
        return 'D';
      default:
        return option;
    }
  }

  String _getOptionText(String? option) {
    if (option == null) return 'Not specified';
    switch (option.toUpperCase()) {
      case 'OPT1':
        return 'Option 1';
      case 'OPT2':
        return 'Option 2';
      case 'OPT3':
        return 'Option 3';
      case 'OPT4':
        return 'Option 4';
      default:
        return option;
    }
  }


  // Add this helper method to clean the question text
  String cleanQuestionText(String? text) {
    if (text == null) return '';

    // Remove patterns like "37. " at the beginning
    String cleaned = text.replaceFirst(RegExp(r'^\d+\.\s*'), '');

    // Remove patterns like "প্রশ্ন ১৮৬. " at the beginning
    cleaned = cleaned.replaceFirst(RegExp(r'^প্রশ্ন\s+\d+\.\s*'), '');

    // Remove patterns like "37." without space
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.'), '');

    return cleaned.trim();
  }

// Then use this method when displaying the question text
}*/
