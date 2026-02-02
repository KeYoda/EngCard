import 'dart:math';

import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/blanc_settings.dart';
import 'package:eng_card/screens/test/answer_button.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BlancTestScreen extends StatefulWidget {
  final List<Words> words;
  final VoidCallback onComplete;
  final String level;

  const BlancTestScreen(
      {super.key,
      required this.words,
      required this.onComplete,
      required this.level});

  @override
  State<StatefulWidget> createState() {
    return _TestScreenState();
  }
}

class _TestScreenState extends State<BlancTestScreen> {
  List<Words> combinedListWords = [];
  String? selectedAnswer;

  int totalQuests = 11;
  int scoreBlanc = 0;

  List<QuestionAnswer> answeredQuestionsTest = [];

  int currentIndex = 0;
  int correctAnswersCount = 0; // Track correct answers

  final List<String> answers = [];
  bool isDisabled = false; // Disable flag
  bool showCorrectAnswer = false; // Yeni parametre eklendi
  String? selectedAnswerText; // Seçilen cevabın text'i için

  @override
  void initState() {
    super.initState();
    combinedListWords = widget.words;
    generateAnswers();
  }

  void generateAnswers() {
    combinedListWords.shuffle();

    String correctAnswer = combinedListWords[currentIndex].quest;
    totalQuests--;
    answers.clear();
    answers.add(correctAnswer);
    for (int i = 0; i < 4; i++) {
      String randomAnswer;
      do {
        randomAnswer =
            combinedListWords[Random.secure().nextInt(combinedListWords.length)]
                .quest;
      } while (randomAnswer == correctAnswer || answers.contains(randomAnswer));
      answers.add(randomAnswer);
    }

    // Shuffle the answers array
    answers.shuffle();
  }

  void checkAnswer(bool isCorrect) {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      progressProv.increaseLinearProgress(widget.level);
      progressProv.completeQuestion(widget.words[currentIndex].list);
      isDisabled = true;
      showCorrectAnswer = true; // Doğru cevabı göster
      if (isCorrect) {
        scoreBlanc = scoreBlanc + 10;
        correctAnswersCount++;
      }

      if (currentIndex < combinedListWords.length) {
        String question = combinedListWords[currentIndex].quest;
        String list = combinedListWords[currentIndex].list;
        String answer = combinedListWords[currentIndex].answer;

        answeredQuestionsTest.add(QuestionAnswer(
          question: question,
          answer: answer,
          list: list,
        ));
      }

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (currentIndex < 9) {
            currentIndex++;
            selectedAnswer =
                null; // Clear selected answer for the next question
            isDisabled = false; // Re-enable the buttons
            showCorrectAnswer =
                false; // Doğru cevabı gösterme durumu sıfırlanıyor
            selectedAnswerText = null; // Seçilen cevabı sıfırlıyoruz
            generateAnswers(); // Generate new answers with a new correct answer
          } else {
            // Navigate to the result screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TestResult(
                  level: widget.level,
                  totalScore: scoreBlanc,
                  correctAnswer: correctAnswersCount,
                  totalQuestions: 10,
                  answeredQuestions: answeredQuestionsTest,
                ),
              ),
            );
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Change to your design size
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: whites,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlancSettings(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        backgroundColor: whites,
        title: const Text("Test Uygulaması"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 50.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  color: hardgreen,
                  height: 150.h,
                  width: 500.w,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      _getFormattedQuestion(
                        combinedListWords[currentIndex].front,
                      ),
                      style: TextStyle(
                          color: whites,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  left: 330.w,
                  top: 10.h,
                  child: Text(
                    combinedListWords[currentIndex].list,
                    style: TextStyle(color: orange, fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: List.generate(
              answers.length,
              (index) => AnswerButton(
                answer: answers[index],
                isCorrect:
                    answers[index] == combinedListWords[currentIndex].quest,
                onTap: (isCorrect) {
                  setState(() {
                    selectedAnswer = answers[index];
                    selectedAnswerText =
                        answers[index]; // Seçilen cevabın text'ini ayarla
                  });
                  checkAnswer(isCorrect);
                },
                isDisabled: isDisabled,
                showCorrectAnswer: showCorrectAnswer,
                isSelected: selectedAnswerText ==
                    answers[index], // Hangi butona tıklandığını kontrol et
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Row(
            children: [
              SizedBox(width: 169.w),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '10/',
                      style: TextStyle(
                        color: hardgreen,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$totalQuests',
                      style: TextStyle(
                        color: orange,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: hardgreen,
            indent: 165.w,
            endIndent: 156.w,
            thickness: 4.h,
          )
        ],
      ),
    );
  }

  String _getFormattedQuestion(String front) {
    return front.replaceAll(combinedListWords[currentIndex].quest, '......');
  }
}
