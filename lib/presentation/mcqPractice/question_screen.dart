import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:edupro/infrastructure/dal/model/submit_quiz_response.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/mcqPractice/controllers/mcq_practice.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    super.key,
    required this.quizList,
    required this.title,
    required this.setNo,
  });

  final List<QuizList> quizList;
  final String title;
  final int setNo;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // Use index as key instead of questionId to avoid conflicts
  final Map<int, dynamic> _selectedOptions = {};
  bool _isSubmitting = false;

  // Timer variables
  static const int _totalMinutes = 30;
  static const int _totalSeconds = _totalMinutes * 60;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  int get answeredQuestions {
    int count = 0;
    for (int i = 0; i < widget.quizList.length; i++) {
      final selected = _selectedOptions[i];
      if (selected != null) {
        if (selected is List) {
          if (selected.isNotEmpty) count++;
        } else if (selected is int) {
          count++;
        } else if (selected is String) {
          if (selected.isNotEmpty) count++;
        }
      }
    }
    return count;
  }

  int get totalQuestions => widget.quizList.length;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _autoSubmitQuiz();
      }
    });
  }

  void _autoSubmitQuiz() {
    if (!_isSubmitting) {
      _submitQuiz(isAutoSubmit: true);
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 60) {
      return AppColors.error;
    } else if (_remainingSeconds <= 300) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTimerAndProgress(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...List.generate(widget.quizList.length, (index) {
                        return _buildQuestionCard(
                          widget.quizList[index],
                          index,
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingSubmitButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      foregroundColor: AppColors.appBarForeground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () {
          _timer?.cancel();
          Get.back();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
          tooltip: 'View Explanations',
          onPressed: _showExplanations,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: AppColors.secondary),
          tooltip: 'Bookmark',
          onPressed: _showBookmarkInfo,
        ),
      ],
    );
  }

  Widget _buildTimerAndProgress() {
    final progress = answeredQuestions / totalQuestions;
    final timerColor = _getTimerColor();

    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  timerColor.withOpacity(0.1),
                  timerColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: timerColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: timerColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Time Remaining:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                    fontFamily: _remainingSeconds <= 60 ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$answeredQuestions/$totalQuestions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
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

  Widget _buildQuestionCard(QuizList data, int index) {
    // questionType: 1 = Radio (Single Choice), 2 = Checkbox (Multiple Choice)
    final isCheckbox = data.questionType == 2;
    final options = data.optionList ?? [];
    final hasAnswer = _selectedOptions.containsKey(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasAnswer
                  ? AppColors.primaryBackground
                  : AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasAnswer ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _cleanQuestionText(data.questionText ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(options.length, (optIndex) {
                if (isCheckbox) {
                  return _buildCheckboxItem(options[optIndex], index, optIndex);
                } else {
                  return _buildRadioItem(options[optIndex], index, optIndex);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(Option item, int questionIndex, int optionIndex) {
    final selectedOptions = _selectedOptions[questionIndex] as List<int>? ?? [];
    final isChecked = selectedOptions.contains(optionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primaryBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? AppColors.primaryLight : AppColors.surfaceVariant,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          _cleanHtmlTags(item.option?.toString() ?? ''),
          style: TextStyle(
            fontSize: 14,
            color: isChecked ? AppColors.primaryDark : AppColors.textPrimary,
            fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        value: isChecked,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              if (_selectedOptions[questionIndex] == null) {
                _selectedOptions[questionIndex] = <int>[];
              }
              (_selectedOptions[questionIndex] as List<int>).add(optionIndex);
            } else {
              (_selectedOptions[questionIndex] as List<int>).remove(
                optionIndex,
              );
              if ((_selectedOptions[questionIndex] as List<int>).isEmpty) {
                _selectedOptions.remove(questionIndex);
              }
            }
          });
        },
        activeColor: AppColors.primary,
        checkColor: AppColors.textWhite,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRadioItem(Option item, int questionIndex, int optionIndex) {
    final selectedOption = _selectedOptions[questionIndex] as int?;
    final isSelected = selectedOption == optionIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
        ),
      ),
      child: RadioListTile<int>(
        title: Text(
          _cleanHtmlTags(item.option?.toString() ?? ''),
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        value: optionIndex,
        groupValue: selectedOption,
        onChanged: (value) {
          setState(() {
            if (value != null) {
              _selectedOptions[questionIndex] = value;
            }
          });
        },
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildFloatingSubmitButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.success.withOpacity(0.3),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textWhite,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Submit Quiz (${answeredQuestions}/$totalQuestions)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _cleanQuestionText(String text) {
    if (text.isEmpty) return '';

    String cleaned = text;

    // Remove Bengali pattern like "প্রশ্ন ১৮৬. " or "প্রশ্ন ১৬. "
    cleaned = cleaned.replaceFirst(RegExp(r'^প্রশ্ন\s+[\d০-৯]+\.\s*'), '');

    // Remove English pattern like "14. " (with space)
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s+'), '');

    // Remove English pattern like "14." (without space)
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.'), '');

    // Remove any extra spaces at the beginning
    cleaned = cleaned.trimLeft();

    // Remove HTML tags
    cleaned = _cleanHtmlTags(cleaned);

    return cleaned;
  }

  String _cleanHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    // Handle superscript tags
    htmlString = htmlString.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>', caseSensitive: false),
      (match) => _convertToSuperscript(match.group(1) ?? ''),
    );

    // HTML entity replacements
    final replacements = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&rsquo;': "'",
      '&ldquo;': '"',
      '&rdquo;': '"',
    };

    replacements.forEach((key, value) {
      htmlString = htmlString.replaceAll(key, value);
    });

    // Remove any remaining HTML tags
    htmlString = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // Clean up extra spaces
    htmlString = htmlString.replaceAll(RegExp(r'\s+'), ' ');
    htmlString = htmlString.trim();

    return htmlString;
  }

  String _convertToSuperscript(String text) {
    const supMap = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '+': '⁺',
      '-': '⁻',
      '=': '⁼',
      '(': '⁽',
      ')': '⁾',
      'n': 'ⁿ',
      'i': 'ⁱ',
    };
    return text.split('').map((c) => supMap[c] ?? c).join();
  }

  Future<void> _submitQuiz({bool isAutoSubmit = false}) async {
    if (!isAutoSubmit && answeredQuestions < totalQuestions) {
      _showWarningDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_timer != null) {
      _timer?.cancel();
    }

    // Calculate time spent
    final timeSpent = _totalSeconds - _remainingSeconds;

    // Get controller
    final controller = Get.find<McqPracticeController>();

    // Prepare submission data
    final submissionData = controller.prepareQuizSubmissionData(
      quizList: widget.quizList,
      selectedOptions: _selectedOptions,
      totalTimeSpent: timeSpent,
      setId: widget.quizList.firstOrNull?.examId?.toString() ?? '1',
      setNo: widget.setNo,
      autoSubmitted: isAutoSubmit,
    );

    // Submit to API
    final result = await controller.submitQuizResult(
      setId: submissionData['setId'],
      setNo: submissionData['setNo'],
      answers: submissionData['answers'],
      totalTimeSpent: submissionData['totalTimeSpent'],
      autoSubmitted: submissionData['autoSubmitted'],
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result != null && result.success) {
      // Calculate correct answers from response or locally
      int correctAnswers = result.correctAnswers;
      double percentage = result.percentage;
      bool isPass = result.passed;

      _showResultDialog(
        correctAnswers: correctAnswers,
        percentage: percentage,
        isPass: isPass,
        isAutoSubmit: isAutoSubmit,
        submitResponse: result,
      );
    } else {
      // Fallback to local calculation if API fails
      int correctAnswers = _calculateCorrectAnswers();
      double percentage = (correctAnswers / totalQuestions) * 100;
      bool isPass = percentage >= 50;

      _showResultDialog(
        correctAnswers: correctAnswers,
        percentage: percentage,
        isPass: isPass,
        isAutoSubmit: isAutoSubmit,
      );
    }
  }

  int _calculateCorrectAnswers() {
    int correctAnswers = 0;

    for (int i = 0; i < widget.quizList.length; i++) {
      final question = widget.quizList[i];

      if (_selectedOptions.containsKey(i)) {
        var selectedOptionIndices = _selectedOptions[i];

        // Get correct option indices
        final correctOptionIndices = <int>[];
        for (int j = 0; j < question.optionList!.length; j++) {
          if (question.optionList![j].correct == true) {
            correctOptionIndices.add(j);
          }
        }

        // Convert single selection to list for comparison
        if (selectedOptionIndices is int) {
          selectedOptionIndices = [selectedOptionIndices];
        }

        // Sort both lists for comparison
        final List<int> selectedList = List.from(selectedOptionIndices);
        selectedList.sort();
        correctOptionIndices.sort();

        if (const ListEquality().equals(selectedList, correctOptionIndices)) {
          correctAnswers++;
        }
      }
    }

    return correctAnswers;
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Incomplete Quiz'),
          ],
        ),
        content: Text(
          'You have answered $answeredQuestions out of $totalQuestions questions.\n\nDo you still want to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // _submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Anyway'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog({
    required int correctAnswers,
    required double percentage,
    required bool isPass,
    required bool isAutoSubmit,
    SubmitQuizResponse? submitResponse,
  }) {
    final timeSpent = _totalSeconds - _remainingSeconds;
    final timeSpentFormatted = _formatTime(timeSpent);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isPass ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: isPass ? Colors.amber : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Quiz Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAutoSubmit)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_off, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Time\'s up! Quiz auto-submitted.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (isAutoSubmit) const SizedBox(height: 12),

            // XP Gained
            if (submitResponse != null && submitResponse.gainedXP > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade100, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+${submitResponse.gainedXP} XP Earned!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Total XP: ${submitResponse.totalXP}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (submitResponse != null && submitResponse.gainedXP > 0)
              const SizedBox(height: 12),

            // Rank Info
            if (submitResponse?.rank != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rank #${submitResponse!.rank!.currentRank} of ${submitResponse.rank!.totalParticipants}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (submitResponse.rank!.pointsToNextRank > 0)
                            Text(
                              '${submitResponse.rank!.pointsToNextRank} XP to next rank',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPass ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isPass ? Icons.check_circle : Icons.cancel,
                    color: isPass ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${isPass ? "PASSED" : "FAILED"}',
                    style: TextStyle(
                      color: isPass ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Score', '$correctAnswers/$totalQuestions'),
            const SizedBox(height: 8),
            _buildResultRow('Percentage', '${percentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            _buildResultRow('Time Taken', timeSpentFormatted),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPass ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Quizzes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _resetQuiz() {
    setState(() {
      _selectedOptions.clear();
      _remainingSeconds = _totalSeconds;
      _isSubmitting = false;
    });
    _timer?.cancel();
    _startTimer();
  }

  void _showExplanations() {
    if (answeredQuestions == 0) {
      Get.snackbar(
        'Info',
        'Answer some questions first to view explanations',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Coming Soon',
      'Explanations feature will be available soon',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showBookmarkInfo() {
    Get.snackbar(
      'Bookmark',
      'Bookmark feature coming soon!',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
