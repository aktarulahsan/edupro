import 'dart:async';

import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../infrastructure/theme/app_bar_helper.dart';
import '../../infrastructure/theme/app_colors.dart';
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
      body: Obx(() {
        if (controller.isLoading.value && controller.mockExams.isEmpty) {
          return _buildLoading();
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.mockExams.isEmpty) {
          return _buildError();
        }

        if (controller.mockExams.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          onRefresh: controller.getMockExams,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    children: [
                      _buildHero(),
                      const SizedBox(height: 16),
                      _buildStats(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: controller.mockExams.length,
                  itemBuilder: (context, index) {
                    final exam = controller.mockExams[index];
                    return _buildExamCard(context, exam, index);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.blueToSlateGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full-length exam practice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Timed tests, clear progress, and instant scoring.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final exams = controller.mockExams;
    final totalQuestions = exams.fold<int>(
      0,
      (sum, exam) => sum + (exam.quizList?.length ?? 0),
    );
    final completed = controller.attempts.length;
    final bestScore = controller.attempts.values.fold<double>(
      0,
      (best, attempt) => attempt.percentage > best ? attempt.percentage : best,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.library_books_outlined,
            exams.length.toString(),
            'Exams',
            AppColors.primary,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.help_outline_rounded,
            totalQuestions.toString(),
            'Questions',
            AppColors.accent,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.verified_outlined,
            completed.toString(),
            'Done',
            AppColors.success,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.emoji_events_outlined,
            '${bestScore.toStringAsFixed(0)}%',
            'Best',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 46, color: AppColors.divider);
  }

  Widget _buildExamCard(BuildContext context, QuizModel exam, int index) {
    final title = controller.examTitle(exam, index);
    final questionCount = exam.quizList?.length ?? 0;
    final duration = controller.getDurationSeconds(exam);
    final examId = exam.examId ?? exam.hashCode.toString();
    final attempt = controller.getAttempt(examId);
    final completed = attempt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? AppColors.success.withValues(alpha: 0.24)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showStartSheet(context, exam, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: completed
                            ? const LinearGradient(
                                colors: [
                                  AppColors.success,
                                  AppColors.successLight,
                                ],
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChip(
                                Icons.help_outline_rounded,
                                '$questionCount Questions',
                                AppColors.accent,
                              ),
                              _buildChip(
                                Icons.timer_outlined,
                                controller.formatDuration(duration),
                                AppColors.primary,
                              ),
                              if (completed)
                                _buildChip(
                                  Icons.leaderboard_outlined,
                                  '${attempt.score}/${attempt.totalQuestions}',
                                  AppColors.success,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
                if (completed) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (attempt.percentage / 100).clamp(0, 1),
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        attempt.percentage >= 50
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Last score',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${attempt.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showStartSheet(BuildContext context, QuizModel exam, int index) {
    final title = controller.examTitle(exam, index);
    final questionCount = exam.quizList?.length ?? 0;
    final duration = controller.getDurationSeconds(exam);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDark,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSheetRow(
                  Icons.help_outline_rounded,
                  'Questions',
                  questionCount.toString(),
                ),
                _buildSheetRow(
                  Icons.timer_outlined,
                  'Duration',
                  controller.formatDuration(duration),
                ),
                _buildSheetRow(
                  Icons.fact_check_outlined,
                  'Mode',
                  'Timed mock exam',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Keep the app open during the exam. Your result is calculated when time ends or you submit.',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.selectedExam.value = exam;
                          Get.to(
                            () => MockExamQuestionScreen(
                              exam: exam,
                              title: title,
                              durationSeconds: duration,
                            ),
                            transition: Transition.rightToLeft,
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Exam'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          height: index == 0 ? 112 : 116,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/error_animation.json',
              width: 170,
              height: 170,
              repeat: false,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                size: 72,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load mock exams',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: controller.getMockExams,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty_animation.json',
              width: 170,
              height: 170,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.assignment_outlined,
                size: 72,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Mock Exams',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New full-length exams will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class MockExamQuestionScreen extends StatefulWidget {
  const MockExamQuestionScreen({
    super.key,
    required this.exam,
    required this.title,
    required this.durationSeconds,
  });

  final QuizModel exam;
  final String title;
  final int durationSeconds;

  @override
  State<MockExamQuestionScreen> createState() => _MockExamQuestionScreenState();
}

class _MockExamQuestionScreenState extends State<MockExamQuestionScreen> {
  final MockExamController _controller = Get.find<MockExamController>();
  final PageController _pageController = PageController();
  final Map<int, dynamic> _selectedOptions = {};

  Timer? _timer;
  late int _remainingSeconds;
  int _currentIndex = 0;
  bool _isSubmitting = false;

  List<QuizList> get _questions => widget.exam.quizList ?? [];
  int get _totalQuestions => _questions.length;
  String get _examId => widget.exam.examId ?? widget.exam.hashCode.toString();
  int get _answeredCount {
    var count = 0;
    for (final selected in _selectedOptions.values) {
      if (selected is List && selected.isNotEmpty) count++;
      if (selected is int) count++;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _controller.loadExamAnswers(_examId, _questions);
    _selectedOptions.addAll(
      _controller.getSelectedOptionsForExam(_examId, _questions),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() => _remainingSeconds = 0);
        _submitExam(autoSubmitted: true);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.appBarForeground,
          elevation: 0,
          leading: IconButton(
            onPressed: _showExitDialog,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          actions: [
            IconButton(
              tooltip: 'Submit exam',
              onPressed: _isSubmitting ? null : _confirmSubmit,
              icon: const Icon(Icons.done_all_rounded),
            ),
            IconButton(
              tooltip: 'Question list',
              onPressed: _showQuestionNavigator,
              icon: const Icon(Icons.grid_view_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildExamHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index], index);
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamHeader() {
    final progress = _totalQuestions == 0
        ? 0.0
        : _answeredCount / _totalQuestions;
    final timerColor = _timerColor;

    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              _buildPill(
                Icons.timer_outlined,
                _formatClock(_remainingSeconds),
                timerColor,
              ),
              const Spacer(),
              _buildPill(
                Icons.check_circle_outline_rounded,
                '$_answeredCount/$_totalQuestions',
                AppColors.success,
              ),
              const SizedBox(width: 8),
              _buildPill(
                Icons.article_outlined,
                '${_currentIndex + 1}/$_totalQuestions',
                AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuizList question, int questionIndex) {
    final options = question.optionList ?? [];
    final isMultiple = question.questionType == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${questionIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _controller.cleanQuestionText(question.questionText ?? ''),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isMultiple ? 'Select all correct answers' : 'Select one answer',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(options.length, (optionIndex) {
              return isMultiple
                  ? _buildCheckboxOption(
                      options[optionIndex],
                      questionIndex,
                      optionIndex,
                    )
                  : _buildRadioOption(
                      options[optionIndex],
                      questionIndex,
                      optionIndex,
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(Option option, int questionIndex, int optionIndex) {
    final selected = _selectedOptions[questionIndex] as int?;
    final isSelected = selected == optionIndex;
    final question = _questions[questionIndex];

    return RadioGroup<int>(
      groupValue: selected,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedOptions[questionIndex] = value);
        _controller.saveCurrentExamAnswer(
          examId: _examId,
          questionIndex: questionIndex,
          question: question,
          answer: value,
        );
      },
      child: _OptionShell(
        isSelected: isSelected,
        child: RadioListTile<int>(
          value: optionIndex,
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            _controller.cleanHtmlTags(option.option ?? ''),
            style: TextStyle(
              color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              fontSize: 14,
              height: 1.35,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    Option option,
    int questionIndex,
    int optionIndex,
  ) {
    final selected = _selectedOptions[questionIndex] as List<int>? ?? <int>[];
    final isSelected = selected.contains(optionIndex);
    final question = _questions[questionIndex];

    return _OptionShell(
      isSelected: isSelected,
      child: CheckboxListTile(
        value: isSelected,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          _controller.cleanHtmlTags(option.option ?? ''),
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
            fontSize: 14,
            height: 1.35,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onChanged: (checked) {
          setState(() {
            final next = List<int>.from(selected);
            if (checked == true) {
              if (!next.contains(optionIndex)) next.add(optionIndex);
            } else {
              next.remove(optionIndex);
            }
            next.sort();
            if (next.isEmpty) {
              _selectedOptions.remove(questionIndex);
            } else {
              _selectedOptions[questionIndex] = next;
            }
            _controller.saveCurrentExamAnswer(
              examId: _examId,
              questionIndex: questionIndex,
              question: question,
              answer: next,
            );
          });
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Previous',
              onPressed: _currentIndex == 0
                  ? null
                  : () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _confirmSubmit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.done_all_rounded),
                label: const Text('Submit Exam'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'Next',
              onPressed: _currentIndex == _totalQuestions - 1
                  ? null
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderDark,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Questions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_answeredCount of $_totalQuestions answered',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _totalQuestions,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final answered = _selectedOptions.containsKey(index);
                        final active = index == _currentIndex;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : answered
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : answered
                                    ? AppColors.success
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : answered
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildNavigatorLegend(AppColors.primary, 'Current'),
                      const SizedBox(width: 12),
                      _buildNavigatorLegend(AppColors.success, 'Answered'),
                      const SizedBox(width: 12),
                      _buildNavigatorLegend(AppColors.textTertiary, 'Skipped'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigatorLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmSubmit() {
    if (_answeredCount == _totalQuestions) {
      _submitExam();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Submit incomplete exam?'),
        content: Text(
          'You have answered $_answeredCount of $_totalQuestions questions. Unanswered questions will count as incorrect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Answering'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    final timeSpent = widget.durationSeconds - _remainingSeconds;
    final submittedOptions = Map<int, dynamic>.from(_selectedOptions);
    final localResult = _controller.calculateLocalResult(
      questions: _questions,
      selectedOptions: submittedOptions,
    );
    final response = await _controller.submitMockExam(
      exam: widget.exam,
      selectedOptions: submittedOptions,
      totalTimeSpent: timeSpent,
      autoSubmitted: autoSubmitted,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showResultDialog(
      response: response,
      correctAnswers: localResult.correctAnswers,
      answeredQuestions: localResult.answeredQuestions,
      incorrectAnswers: localResult.incorrectAnswers,
      totalQuestions: localResult.total,
      percentage: localResult.percentage,
      timeSpent: timeSpent,
      autoSubmitted: autoSubmitted,
    );
  }

  void _showResultDialog({
    required SubmitQuizResponse? response,
    required int correctAnswers,
    required int answeredQuestions,
    required int incorrectAnswers,
    required int totalQuestions,
    required double percentage,
    required int timeSpent,
    required bool autoSubmitted,
  }) {
    final passed = response?.passed ?? percentage >= 50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.insights_rounded,
              color: passed ? AppColors.xpGold : AppColors.primary,
              size: 30,
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text('Mock Exam Result')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (autoSubmitted) ...[
              _buildResultNotice(
                Icons.timer_off_rounded,
                'Time is up. Your exam was submitted automatically.',
                AppColors.error,
              ),
              const SizedBox(height: 12),
            ],
            _buildScoreCircle(percentage),
            const SizedBox(height: 18),
            _buildResultRow('Score', '$correctAnswers/$totalQuestions'),
            _buildResultRow('Answered', '$answeredQuestions/$totalQuestions'),
            _buildResultRow('Incorrect', '$incorrectAnswers/$totalQuestions'),
            _buildResultRow('Time Spent', _formatClock(timeSpent)),
            if ((response?.gainedXP ?? 0) > 0)
              _buildResultRow('XP Earned', '+${response!.gainedXP}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('Back to Exams'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedOptions.clear();
                _currentIndex = 0;
                _remainingSeconds = widget.durationSeconds;
              });
              _controller.clearExamAnswers(_examId);
              _pageController.jumpToPage(0);
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultNotice(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(double percentage) {
    final color = percentage >= 50 ? AppColors.success : AppColors.warning;
    return SizedBox(
      width: 126,
      height: 126,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            strokeWidth: 10,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Leave exam?'),
        content: const Text(
          'Your current answers are saved locally. You can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return AppColors.error;
    if (_remainingSeconds <= 300) return AppColors.warning;
    return AppColors.primary;
  }

  String _formatClock(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _OptionShell extends StatelessWidget {
  const _OptionShell({required this.isSelected, required this.child});

  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primaryLight : AppColors.border,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: child,
    );
  }
}
