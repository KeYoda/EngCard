import 'dart:math';

import 'package:eng_card/data/gridview.dart';

import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/settings.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/answer_button.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TestWord extends StatefulWidget {
  final List<Words> words;
  final VoidCallback onComplete;

  const TestWord({
    super.key,
    required this.words,
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() {
    return _TestWordState();
  }
}

class _TestWordState extends State<TestWord> {
  List<Words> combinedListWords = [];

  String? selectedAnswer;

  int totalQuests = 16;
  int scoreBlanc = 0;

  List<QuestionAnswer> answeredQuestionsTest = [];

  int currentIndex = 0;
  int correctAnswersCount = 0;

  final List<String> answers = [];
  bool isDisabled = false;
  bool showCorrectAnswer = false;
  String? selectedAnswerText;

  @override
  void initState() {
    super.initState();

    combinedListWords = widget.words;
    generateAnswers();
  }

  void generateAnswers() {
    combinedListWords.shuffle();

    String correctAnswer = combinedListWords[currentIndex].answer;
    totalQuests--;
    answers.clear();
    answers.add(correctAnswer);
    for (int i = 0; i < 4; i++) {
      String randomAnswer;
      do {
        randomAnswer =
            combinedListWords[Random.secure().nextInt(combinedListWords.length)]
                .answer;
      } while (randomAnswer == correctAnswer || answers.contains(randomAnswer));
      answers.add(randomAnswer);
    }

    answers.shuffle();
  }

  void checkAnswer(bool isCorrect) {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      isDisabled = true;
      showCorrectAnswer = true;
      if (isCorrect) {
        progressProv.increaseCircleProgress(widget.words[currentIndex].list);
        progressProv.completeQuestion(widget.words[currentIndex].list);
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
          if (currentIndex < 14) {
            currentIndex++;
            selectedAnswer = null;
            isDisabled = false;
            showCorrectAnswer = false;
            selectedAnswerText = null;
            generateAnswers();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TestResult(
                  totalScore: scoreBlanc,
                  correctAnswer: correctAnswersCount,
                  totalQuestions: 15,
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
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: whites,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
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
          SizedBox(height: 40.h),
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
                      combinedListWords[currentIndex].quest,
                      style: TextStyle(
                        color: whites,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
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
          SizedBox(height: 16.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 3.h,
            children: List.generate(
              answers.length,
              (index) => AnswerButton(
                answer: answers[index],
                isCorrect:
                    answers[index] == combinedListWords[currentIndex].answer,
                onTap: (isCorrect) {
                  setState(() {
                    selectedAnswer = answers[index];
                    selectedAnswerText = answers[index];
                  });
                  checkAnswer(isCorrect);
                },
                isDisabled: isDisabled,
                showCorrectAnswer: showCorrectAnswer,
                isSelected: selectedAnswerText == answers[index],
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
                      text: '15/',
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
          ),
        ],
      ),
    );
  }
}
