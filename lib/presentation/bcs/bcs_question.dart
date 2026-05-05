
import 'package:edupro/infrastructure/dal/model/quizModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'controllers/bcs.controller.dart';
import 'package:collection/collection.dart';

class BcsQuestion extends StatefulWidget {
  const BcsQuestion({super.key, required this.quizModel});
  final QuizModel quizModel;

  @override
  State<BcsQuestion> createState() => _BcsQuestionState();
}

class _BcsQuestionState extends State<BcsQuestion> with TickerProviderStateMixin {
  final BcsController _controller = Get.find();
  final Map<String, dynamic> _localAnswers = {};
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadExistingAnswers();
    _updateProgress();
  }

  void _loadExistingAnswers() {
    final String examId = widget.quizModel.examId ?? '';
    for (var question in widget.quizModel.quizList ?? []) {
      final savedAnswer = _controller.getUserAnswer(examId, question.questionId ?? '');
      if (savedAnswer != null) {
        _localAnswers[question.questionId!] = savedAnswer;
      }
    }
  }

  void _updateProgress() {
    _progressAnimation = Tween<double>(
      begin: 0,
      end: _answeredPercentage,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward(from: 0);
  }

  double get _answeredPercentage {
    final total = widget.quizModel.quizList?.length ?? 1;
    final answered = _localAnswers.length;
    return answered / total;
  }

  int get _answeredCount => _localAnswers.length;
  int get _totalQuestions => widget.quizModel.quizList?.length ?? 0;

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                HapticFeedback.lightImpact();
              },
              itemCount: _totalQuestions,
              itemBuilder: (context, index) => _buildQuestionCard(
                widget.quizModel.quizList![index],
                index + 1,
              ),
            ),
          ),
          _buildNavigationButtons(),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.quizModel.examId ?? 'BCS Examination',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF2C3E50),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => _showExitConfirmation(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.flag_outlined),
          onPressed: () => _showQuestionNavigator(),
          tooltip: 'Question Navigator',
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Question $_currentIndex/$_totalQuestions',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_answeredCount/$_totalQuestions Answered',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: const Color(0xFFE8ECF0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                  minHeight: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizList data, int questionNumber) {
    final isCheckbox = data.questionType == 2;
    final options = data.optionList ?? [];
    final selectedAnswer = _localAnswers[data.questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$questionNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _parseHtmlString(data.questionText ?? ''),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...options.asMap().entries.map(
                      (entry) => _buildOption(
                    entry.value,
                    data.questionId!,
                    entry.key + 1,
                    isCheckbox,
                    selectedAnswer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(Option option, String questionId, int index, bool isCheckbox, dynamic selectedAnswer) {
    final isSelected = isCheckbox
        ? (selectedAnswer as List?)?.contains(option.optionId) ?? false
        : selectedAnswer == option.optionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4A90E2).withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFFE8ECF0),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: isCheckbox
          ? CheckboxListTile(
        title: Text(
          _parseHtmlString(option.option?.toString() ?? ''),
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF2C3E50),
          ),
        ),
        value: isSelected,
        onChanged: (value) => _onOptionSelected(questionId, option.optionId!, isCheckbox, value),
        activeColor: const Color(0xFF4A90E2),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      )
          : RadioListTile<String>(
        title: Text(
          _parseHtmlString(option.option?.toString() ?? ''),
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF2C3E50),
          ),
        ),
        value: option.optionId!,
        groupValue: selectedAnswer,
        onChanged: (value) => _onOptionSelected(questionId, value!, isCheckbox, true),
        activeColor: const Color(0xFF4A90E2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // void _onOptionSelected(String questionId, dynamic value, bool isCheckbox, bool? checked) {
  //   setState(() {
  //     if (isCheckbox) {
  //       List<String> selectedList = List.from(_localAnswers[questionId] ?? []);
  //       if (checked == true) {
  //         selectedList.add(value);
  //       } else {
  //         selectedList.remove(value);
  //       }
  //       if (selectedList.isEmpty) {
  //         _localAnswers.remove(questionId);
  //       } else {
  //         _localAnswers[questionId] = selectedList;
  //       }
  //     } else {
  //       _localAnswers[questionId] = value;
  //     }
  //     _updateProgress();
  //     HapticFeedback.selectionClick();
  //   });
  //
  //   // Auto-save to controller
  //   _controller.saveCurrentQuizAnswer(questionId, _localAnswers[questionId]);
  // }
  void _onOptionSelected(String questionId, dynamic value, bool isCheckbox, bool? checked) {
    final String examId = widget.quizModel.examId ?? '';
    final QuizList currentQuestion = widget.quizModel.quizList!
        .firstWhere((q) => q.questionId == questionId);

    setState(() {
      if (isCheckbox) {
        List<String> selectedList = List.from(_localAnswers[questionId] ?? []);
        if (checked == true) {
          selectedList.add(value);
        } else {
          selectedList.remove(value);
        }
        if (selectedList.isEmpty) {
          _localAnswers.remove(questionId);
        } else {
          _localAnswers[questionId] = selectedList;
        }
      } else {
        _localAnswers[questionId] = value;
      }
      _updateProgress();
      HapticFeedback.selectionClick();
    });

    // Save to controller with examId
    _controller.saveCurrentQuizAnswer(
        examId,
        questionId,
        _localAnswers[questionId],
        currentQuestion
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 1)
            OutlinedButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                HapticFeedback.lightImpact();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          if (_currentIndex < _totalQuestions)
            ElevatedButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                HapticFeedback.lightImpact();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isAllAnswered = _answeredCount == _totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            // onPressed: isAllAnswered ? () => _submitQuiz() : null,
            onPressed: _submitQuiz,

            style: ElevatedButton.styleFrom(
              // backgroundColor: isAllAnswered ? const Color(0xFF4A90E2) : const Color(0xFFE8ECF0),
              // foregroundColor: isAllAnswered ? Colors.white : Colors.grey,

              backgroundColor:  const Color(0xFF4A90E2)  ,
              foregroundColor:   Colors.white ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isAllAnswered ? 'Submit Quiz' : 'Answer All Questions to Submit',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitQuiz() async {
    HapticFeedback.heavyImpact();

    final totalQuestions = _totalQuestions;
    int correctAnswers = 0;

    for (var question in widget.quizModel.quizList!) {
      final correctOptions = question.optionList
          ?.where((option) => option.correct == true)
          .map((e) => e.optionId)
          .toList();
      final selected = _localAnswers[question.questionId];

      if (question.questionType == 2) {
        if (selected is List && correctOptions != null) {
          final selectedSorted = List.from(selected)..sort();
          final correctSorted = List.from(correctOptions)..sort();
          if (ListEquality().equals(selectedSorted, correctSorted)) {
            correctAnswers++;
          }
        }
      } else {
        if (selected != null && correctOptions != null && correctOptions.contains(selected)) {
          correctAnswers++;
        }
      }
    }

    final percentage = (correctAnswers / totalQuestions * 100);
    final isPerfect = correctAnswers == totalQuestions;

    if (isPerfect) {
      _confettiController.play();
    }

    await _showResultDialog(correctAnswers, totalQuestions, percentage, isPerfect);
  }

  Future<void> _showResultDialog(int correct, int total, double percentage, bool isPerfect) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPerfect)
                  Lottie.asset(
                    'assets/animations/celebration.json',
                    width: 120,
                    height: 120,
                  )
                else
                  Lottie.asset(
                    'assets/animations/result.json',
                    width: 120,
                    height: 120,
                  ),
                const SizedBox(height: 16),
                Text(
                  isPerfect ? 'Perfect Score!' : 'Quiz Completed',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow('Correct Answers', '$correct', Colors.green),
                      const SizedBox(height: 12),
                      _buildResultRow('Incorrect Answers', '${total - correct}', Colors.red),
                      const SizedBox(height: 12),
                      _buildResultRow('Score', '${percentage.toStringAsFixed(1)}%',
                          percentage >= 60 ? Colors.green : Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildResultMessage(percentage, isPerfect),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _localAnswers.clear();
                            _updateProgress();
                          });
                          _pageController.jumpToPage(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
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

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultMessage(double percentage, bool isPerfect) {
    String message;
    IconData icon;
    Color color;

    if (isPerfect) {
      message = '🌟 Excellent! You\'ve mastered this exam! 🌟';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 80) {
      message = '🎯 Great job! You\'re well prepared!';
      icon = Icons.thumb_up;
      color = const Color(0xFF4A90E2);
    } else if (percentage >= 60) {
      message = '📚 Good effort! Review and try again.';
      icon = Icons.school;
      color = Colors.blue;
    } else if (percentage >= 40) {
      message = '📖 Keep practicing! You\'ll get there.';
      icon = Icons.book;
      color = Colors.orange;
    } else {
      message = '💪 Don\'t give up! Review the material and try again.';
      icon = Icons.favorite;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Exit Quiz'),
        content: const Text('Your progress will be saved. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showQuestionNavigator() {
    final String examId = widget.quizModel.examId ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Question Navigator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_controller.getExamAnsweredCount(examId)}/$_totalQuestions',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _totalQuestions,
                itemBuilder: (context, index) {
                  final question = widget.quizModel.quizList![index];
                  final questionId = question.questionId ?? '';
                  final isAnswered = _controller.isQuestionAnswered(examId, questionId);
                  final isCorrect = _controller.isAnswerCorrect(examId, questionId);

                  // Determine color based on answer status
                  Color backgroundColor;
                  Color textColor;
                  IconData? icon;

                  if (!isAnswered) {
                    // Not answered - Grey
                    backgroundColor = const Color(0xFFE8ECF0);
                    textColor = const Color(0xFF2C3E50);
                    icon = null;
                  } else if (isCorrect == true) {
                    // Correct answer - Green
                    backgroundColor =   Colors.green;
                    textColor = Colors.white;
                    icon = Icons.check_circle;
                  } else {
                    // Wrong answer - Red
                    backgroundColor = const Color(0xFFE53935);
                    textColor = Colors.white;
                    icon = Icons.cancel;
                  }

                  return Material(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pageController.jumpToPage(index);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (icon != null)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(
                                icon,
                                size: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(const Color(0xFFE8ECF0), 'Not Answered'),
                  _buildLegendItem(const Color(0xFF4CAF50), 'Correct'),
                  _buildLegendItem(const Color(0xFFE53935), 'Wrong'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return '';

    // Handle superscript
    htmlString = htmlString.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>', caseSensitive: false),
          (match) => _convertToSuperscript(match.group(1) ?? ''),
    );

    // Handle HTML entities
    final entities = {
      '&nbsp;': ' ', '&amp;': '&', '&lt;': '<', '&gt;': '>',
      '&quot;': '"', '&#39;': "'", '&rsquo;': "'", '&ldquo;': '"', '&rdquo;': '"',
      '&mdash;': '—', '&ndash;': '–',
    };

    entities.forEach((entity, char) {
      htmlString = htmlString.replaceAll(entity, char);
    });

    // Remove any remaining HTML tags
    htmlString = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    htmlString = htmlString.replaceAll(RegExp(r'\s+'), ' ');

    return htmlString.trim();
  }

  String _convertToSuperscript(String text) {
    const supMap = {
      '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
      '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
      '+': '⁺', '-': '⁻', '=': '⁼', '(': '⁽', ')': '⁾', 'n': 'ⁿ', 'i': 'ⁱ',
    };
    return text.split('').map((c) => supMap[c] ?? c).join();
  }
}



