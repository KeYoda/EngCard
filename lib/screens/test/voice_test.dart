import 'dart:math';

import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:eng_card/screens/test/voice_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class VoiceTest extends StatefulWidget {
  final List<Words> words;
  final VoidCallback onComplete;
  final String level;

  const VoiceTest(
      {super.key,
      required this.level,
      required this.onComplete,
      required this.words});
  @override
  State<StatefulWidget> createState() {
    return _StateVoiceTest();
  }
}

class _StateVoiceTest extends State<VoiceTest> {
  List<Words> combinedListWordsCard = [];
  List<QuestionAnswer> answeredQuestionsCard = [];

  FlutterTts flutterTts = FlutterTts();

  int currentIndex = 0;
  int countIndex = 9;
  int scoreVoice = 0;
  int correctAnswerCount = 0;

  int totalQuests = 8;
  List<String> userInput = [];
  List<String> shuffledCharacters = [];
  Set<int> pressedButtons = {};

  @override
  void initState() {
    super.initState();
    _initTts();
    combinedListWordsCard = widget.words;
    combinedListWordsCard.shuffle();
    _initializeUserInput();
  }

  void _initializeUserInput() {
    if (currentIndex < combinedListWordsCard.length) {
      String question = combinedListWordsCard[currentIndex].quest;
      String list = combinedListWordsCard[currentIndex].list;
      String answer = combinedListWordsCard[currentIndex].answer;

      answeredQuestionsCard.add(QuestionAnswer(
        question: question,
        answer: answer,
        list: list,
      ));
      userInput =
          List.filled(combinedListWordsCard[currentIndex].quest.length, '');
      shuffledCharacters = combinedListWordsCard[currentIndex].quest.split('');
      shuffledCharacters.shuffle(Random());
      pressedButtons.clear();
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  List<Widget> _generateLetterBoxes(String word) {
    return List.generate(word.length, (index) {
      return Container(
        // margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: hardgreen),
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Text(
          userInput[index].isEmpty ? '_' : userInput[index],
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: hardgreen,
          ),
          overflow: TextOverflow.ellipsis, // Taşma durumunda ...
          softWrap: false, //
        ),
      );
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (currentIndex < combinedListWordsCard.length - 1) {
        currentIndex++;
        countIndex--;
        _initializeUserInput();
      } else {
        // Handle end of questions
        // You can navigate to another screen or show a dialog here
      }
    });
  }

  List<Widget> _generateLetterButtons() {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    return List.generate(shuffledCharacters.length, (index) {
      return Container(
        height: 50,
        width: 45,
        padding: EdgeInsets.all(5.w),
        child: Center(
          child: ElevatedButton(
            onPressed: pressedButtons.contains(index)
                ? null
                : () {
                    // Handle button press
                    print("Pressed: ${shuffledCharacters[index]}");

                    // Find the first empty spot in userInput
                    int firstEmptyIndex = userInput.indexOf('');

                    if (firstEmptyIndex != -1) {
                      setState(() {
                        userInput[firstEmptyIndex] = shuffledCharacters[index];
                        pressedButtons.add(index);
                      });
                    }

                    // Check if the word is complete
                    if (!userInput.contains('')) {
                      progressProv.increaseCircleProgress(widget.level);
                      progressProv.completeQuestion(widget.level);
                      // Wait for a short delay before moving to the next question
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          // Check if the user's input matches the current word
                          if (userInput.join('') ==
                              combinedListWordsCard[currentIndex].quest) {
                            correctAnswerCount++;
                            currentIndex++;
                            countIndex--;
                            scoreVoice = scoreVoice + 10;
                            if (currentIndex < combinedListWordsCard.length) {
                              _initializeUserInput();
                            } else {}
                          } else {
                            userInput = List.filled(
                                combinedListWordsCard[currentIndex]
                                    .quest
                                    .length,
                                '');
                            pressedButtons.clear();
                          }
                        });
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(3),
              backgroundColor: hardgreen, // Button color
              foregroundColor: whites, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.w),
              ),
            ),
            child: Text(
              textAlign: TextAlign.center,
              shuffledCharacters[index],
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= 8) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TestResult(
              totalQuestions: 8,
              correctAnswer: correctAnswerCount,
              answeredQuestions: answeredQuestionsCard,
              totalScore: scoreVoice,
            ),
          ),
        );
      });
    }

    if (currentIndex < combinedListWordsCard.length) {
      String currentWord = combinedListWordsCard[currentIndex].quest;

      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceSettings(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          backgroundColor: whites,
          title: Text(
            'Dinleme',
            style: TextStyle(color: hardgreen, fontSize: 24.sp),
          ),
          centerTitle: true,
        ),
        backgroundColor: whites,
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 100.h,
                        width: 450.w,
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              _speak(currentWord);
                            },
                            icon: const Icon(Icons.keyboard_voice),
                            iconSize: 55.sp,
                            color: hardgreen,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 300.w,
                        top: 12.h,
                        child: Text(
                          combinedListWordsCard[currentIndex].list,
                          style: TextStyle(color: orange, fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 15.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 5.h,
                      spacing: 5.w,
                      children: _generateLetterBoxes(currentWord),
                    ),
                    SizedBox(height: 175.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 5.h,
                      children: _generateLetterButtons(),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '*${combinedListWordsCard[currentIndex].answer}*',
                      style: TextStyle(
                        color: hardgreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 30.h,
              left: 10.w,
              right: 10.w,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$totalQuests/',
                          style: TextStyle(
                            color: hardgreen,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: (countIndex - 1).toString(),
                          style: TextStyle(
                            color: orange,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: hardgreen,
                    indent: 160.w,
                    endIndent: 157.w,
                    thickness: 4.h,
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        alignment: Alignment.centerLeft,
                        style:
                            ElevatedButton.styleFrom(backgroundColor: yellow),
                        onPressed: _goToNextQuestion,
                        icon: Icon(
                          Icons.arrow_right,
                          size: 35.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Text('No more questions available.'),
      ),
    );
  }
}
