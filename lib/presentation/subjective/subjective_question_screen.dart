import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edupro/infrastructure/dal/model/option_model.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/dal/model/question.dart';
import 'controllers/subjective.controller.dart';

class SubjectiveQuestionScreen extends StatefulWidget {
  const SubjectiveQuestionScreen({
    super.key,
    required this.quizList,
    required this.title,
  });

  final List<Question> quizList;
  final String title;

  @override
  State<SubjectiveQuestionScreen> createState() =>
      _SubjectiveQuestionScreenState();
}

class _SubjectiveQuestionScreenState extends State<SubjectiveQuestionScreen> {
  final Map<int, dynamic> _selectedOptions = {};
  bool _isSubmitting = false;

  // Timer variables
  static const int _totalMinutes = 30;
  static const int _totalSeconds = _totalMinutes * 60;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  // Scroll controller for auto-scroll
  final ScrollController _scrollController = ScrollController();

  // List of GlobalKeys for each question to get their position
  late List<GlobalKey> _questionKeys;

  int get answeredQuestions {
    int count = 0;
    for (int i = 0; i < widget.quizList.length; i++) {
      final selected = _selectedOptions[i];
      if (selected != null) {
        if (selected is List) {
          if (selected.isNotEmpty) count++;
        } else if (selected is String) {
          if (selected.isNotEmpty) count++;
        } else if (selected is int) {
          count++;
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
    // Initialize keys for each question
    _questionKeys = List.generate(
      widget.quizList.length,
      (index) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
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
      return Colors.red;
    } else if (_remainingSeconds <= 300) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  void _scrollToNextQuestion(int currentIndex) {
    // Check if there's a next question
    if (currentIndex + 1 < totalQuestions) {
      // Small delay to ensure the UI has updated
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          // Get the key of the next question
          final nextQuestionKey = _questionKeys[currentIndex + 1];

          // Get the render box of the next question
          final RenderBox? nextQuestionBox =
              nextQuestionKey.currentContext?.findRenderObject() as RenderBox?;

          if (nextQuestionBox != null) {
            // Get the screen height
            final screenHeight = MediaQuery.of(context).size.height;

            // Get the position of the next question relative to the screen
            final boxPosition = nextQuestionBox.localToGlobal(Offset.zero);
            final boxHeight = nextQuestionBox.size.height;

            // Calculate the offset to center the question
            // We want the question to appear in the middle of the screen
            final targetOffset =
                _scrollController.offset +
                (boxPosition.dy - (screenHeight / 2) + (boxHeight / 2));

            // Smooth scroll to the target position
            _scrollController.animateTo(
              targetOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            );

            // Show a snackbar indicating auto-scroll
            // Get.snackbar(
            //   'Auto-Scroll',
            //   'Moving to question ${currentIndex + 2}',
            //   backgroundColor: Colors.blue.withOpacity(0.8),
            //   colorText: Colors.white,
            //   duration: const Duration(milliseconds: 1200),
            //   snackPosition: SnackPosition.BOTTOM,
            //   margin: const EdgeInsets.all(10),
            // );
          } else {
            // Fallback to approximate position if render box not found
            final double nextQuestionPosition = (currentIndex + 1) * 280.0;
            _scrollController.animateTo(
              nextQuestionPosition,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    } else {
      // This was the last question, show completion message
      Get.snackbar(
        'Great Job! 🎉',
        'You\'ve answered all questions! Tap submit to finish.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _scrollToQuestion(int questionIndex) {
    if (_scrollController.hasClients && questionIndex < _questionKeys.length) {
      final questionKey = _questionKeys[questionIndex];
      final RenderBox? questionBox =
          questionKey.currentContext?.findRenderObject() as RenderBox?;

      if (questionBox != null) {
        final screenHeight = MediaQuery.of(context).size.height;
        final boxPosition = questionBox.localToGlobal(Offset.zero);
        final boxHeight = questionBox.size.height;

        final targetOffset =
            _scrollController.offset +
            (boxPosition.dy - (screenHeight / 2) + (boxHeight / 2));

        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        Get.snackbar(
          'Question ${questionIndex + 1}',
          'Navigating to question ${questionIndex + 1}',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Fallback
        final double position = questionIndex * 280.0;
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onOptionSelected(int questionIndex) {
    // Check if all questions are answered
    if (answeredQuestions == totalQuestions) {
      Get.snackbar(
        'Complete! ✅',
        'You\'ve answered all questions. Tap submit to finish the quiz.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTimerAndProgress(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...List.generate(widget.quizList.length, (index) {
                        return Container(
                          key:
                              _questionKeys[index], // Use GlobalKey for each question
                          child: _buildQuestionCard(
                            widget.quizList[index],
                            index,
                          ),
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
          _showExitConfirmation();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.list_alt, color: Colors.blue),
          tooltip: 'Jump to Question',
          onPressed: _showQuestionNavigator,
        ),
        IconButton(
          icon: const Icon(Icons.lightbulb_outline, color: Colors.blue),
          tooltip: 'View Explanations',
          onPressed: _showExplanations,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.blue),
          tooltip: 'Bookmark',
          onPressed: _showBookmarkInfo,
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    if (answeredQuestions > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Exit Quiz?'),
          content: Text(
            'You have answered $answeredQuestions out of $totalQuestions questions. Your progress will be lost if you exit.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Quiz'),
            ),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Get.back();
                Get.back();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Exit Anyway'),
            ),
          ],
        ),
      );
    } else {
      _timer?.cancel();
      Get.back();
    }
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jump to Question',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap on any question number to navigate',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: totalQuestions,
                  itemBuilder: (context, index) {
                    final isAnswered = _selectedOptions.containsKey(index);
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToQuestion(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAnswered
                              ? Colors.green
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isAnswered ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Green: Answered'),
                  Text(
                    '$answeredQuestions/$totalQuestions Completed',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerAndProgress() {
    final progress = answeredQuestions / totalQuestions;
    final timerColor = _getTimerColor();

    return Container(
      color: Colors.white,
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
                    color: Colors.grey[700],
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
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$answeredQuestions/$totalQuestions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
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
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1 ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question data, int index) {
    final isCheckbox = data.questionType == 2;
    final options = data.optionList ?? [];
    final hasAnswer = _selectedOptions.containsKey(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: hasAnswer ? Colors.blue.shade50 : Colors.grey.shade50,
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
                    color: hasAnswer ? Colors.blue : Colors.grey,
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
                    _parseHtmlString(data.questionText ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Colors.black87,
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
                return isCheckbox
                    ? _buildCheckboxItem(options[optIndex], index, optIndex)
                    : _buildRadioItem(options[optIndex], index, optIndex);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    OptionModel item,
    int questionIndex,
    int optionIndex,
  ) {
    final selectedOptions = _selectedOptions[questionIndex] as List? ?? [];
    final isChecked = selectedOptions.contains(optionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isChecked ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          _parseHtmlString(item.option.toString() ?? ''),
          style: TextStyle(
            fontSize: 14,
            color: isChecked ? Colors.blue.shade700 : Colors.grey[800],
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

          // Auto-scroll to next question after selection
          _scrollToNextQuestion(questionIndex);
          _onOptionSelected(questionIndex);
        },
        activeColor: Colors.blue,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRadioItem(OptionModel item, int questionIndex, int optionIndex) {
    final selectedOption = _selectedOptions[questionIndex] as int?;
    final isSelected = selectedOption == optionIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: RadioListTile<int>(
        title: Text(
          _parseHtmlString(item.option.toString() ?? ''),
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.blue.shade700 : Colors.grey[800],
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

          // Auto-scroll to next question after selection
          _scrollToNextQuestion(questionIndex);
          _onOptionSelected(questionIndex);
        },
        activeColor: Colors.blue,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildFloatingSubmitButton() {
    final canSubmit = answeredQuestions >= 1;

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
            onPressed: _isSubmitting || !canSubmit ? null : _submitQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: canSubmit ? 4 : 0,
              shadowColor: canSubmit ? Colors.green.withOpacity(0.3) : null,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canSubmit ? Icons.check_circle : Icons.lock_outline,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        canSubmit
                            ? 'Submit Quiz ($answeredQuestions/$totalQuestions)'
                            : 'at least 1 question to submit',
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

  String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return '';

    htmlString = htmlString.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>', caseSensitive: false),
      (match) => _convertToSuperscript(match.group(1) ?? ''),
    );

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

    htmlString = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    htmlString = htmlString.replaceFirst(
      RegExp(r'^প্রশ্ন\s+[\d০-৯]+\.\s*'),
      '',
    );
    htmlString = htmlString.replaceFirst(RegExp(r'^[\d]+\.\s*'), '');
    htmlString = htmlString.replaceFirst(RegExp(r'^প্রশ্ন\s*'), '');
    htmlString = htmlString.replaceAll(RegExp(r'\s+'), ' ');
    htmlString = htmlString.trim();
    htmlString = htmlString.replaceFirst(RegExp(r'^[\.\s]+'), '');

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

  void _submitQuiz({bool isAutoSubmit = false}) async {
    if (!isAutoSubmit && answeredQuestions < 1) {
      Get.snackbar(
        'Cannot Submit',
        'Please answer at least 1 question before submitting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_timer != null) {
      _timer?.cancel();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    int correctAnswers = 0;

    for (int i = 0; i < widget.quizList.length; i++) {
      final question = widget.quizList[i];

      if (_selectedOptions.containsKey(i)) {
        var selectedOptionIndices = _selectedOptions[i];

        final correctOptionIndices = <int>[];
        for (int j = 0; j < question.optionList.length; j++) {
          if (question.optionList[j].correct == true) {
            correctOptionIndices.add(j);
          }
        }

        if (selectedOptionIndices is int) {
          selectedOptionIndices = [selectedOptionIndices];
        }

        final List<int> selectedList = List.from(selectedOptionIndices);
        selectedList.sort();
        correctOptionIndices.sort();

        if (const ListEquality().equals(selectedList, correctOptionIndices)) {
          correctAnswers++;
        }
      }
    }

    final percentage = (correctAnswers / totalQuestions) * 100;
    final isPass = percentage >= 50;

    setState(() {
      _isSubmitting = false;
    });

    _showResultDialog(correctAnswers, percentage, isPass, isAutoSubmit);
  }

  void _showWarningDialog() {
    if (answeredQuestions < 1) {
      Get.snackbar(
        'Cannot Submit',
        'Please answer at least 1 question before submitting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

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
              _submitQuiz();
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

  void _showResultDialog(
    int correctAnswers,
    double percentage,
    bool isPass,
    bool isAutoSubmit,
  ) {
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
                backgroundColor: Colors.grey[200],
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
            color: Colors.black87,
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

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
