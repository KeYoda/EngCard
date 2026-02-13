import 'dart:math';

import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/settings.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TestWord extends StatefulWidget {
  final List<Words> words;
  final String level;
  final VoidCallback onComplete;

  const TestWord({
    super.key,
    required this.words,
    required this.level,
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() {
    return _TestWordState();
  }
}

class _TestWordState extends State<TestWord> {
  // --- MODERN RENK PALETİ ---
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);
  final Color accentTurquoise = const Color(0xFF2EC4B6);
  final Color correctColor = const Color(0xFF2EC4B6); // Yeşil/Turkuaz
  final Color wrongColor = const Color(0xFFEF476F); // Kırmızı

  List<Words> combinedListWords = [];
  String? selectedAnswer;
  int remainingQuestsDisplay = 15; // Toplam soru sayısı
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
    combinedListWords = List.from(widget.words);
    if (combinedListWords.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }
    generateAnswers();
  }

  void generateAnswers() {
    if (currentIndex == 0) {
      combinedListWords.shuffle();
    }

    String correctAnswer = combinedListWords[currentIndex].answer;

    if (remainingQuestsDisplay > 0) remainingQuestsDisplay--;

    answers.clear();
    answers.add(correctAnswer);

    int attemptCount = 0;
    while (answers.length < 4 && attemptCount < 100) {
      String randomAnswer =
          combinedListWords[Random.secure().nextInt(combinedListWords.length)]
              .answer;
      if (randomAnswer != correctAnswer && !answers.contains(randomAnswer)) {
        answers.add(randomAnswer);
      }
      attemptCount++;
    }
    answers.shuffle();
  }

  void checkAnswer(bool isCorrect) {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      isDisabled = true;
      showCorrectAnswer = true;

      if (isCorrect) {
        progressProv.increaseLinearProgress(widget.level);
        progressProv.completeQuestion(widget.level);
        scoreBlanc += 10;
        correctAnswersCount++;
      }

      if (currentIndex < combinedListWords.length) {
        answeredQuestionsTest.add(QuestionAnswer(
          question: combinedListWords[currentIndex].quest,
          answer: combinedListWords[currentIndex].answer,
          list: widget.level,
        ));
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            if (currentIndex < 14 &&
                currentIndex < combinedListWords.length - 1) {
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
                    level: widget.level,
                    totalScore: scoreBlanc,
                    correctAnswer: correctAnswersCount,
                    totalQuestions: currentIndex + 1,
                    answeredQuestions: answeredQuestionsTest,
                  ),
                ),
              );
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (combinedListWords.isEmpty || currentIndex >= combinedListWords.length) {
      return const SizedBox();
    }

    // İlerleme Yüzdesi
    double progressPercent = (currentIndex + 1) / 15;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          "Kelime Anlamı - ${widget.level}",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. İLERLEME ÇUBUĞU ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Soru ${currentIndex + 1}/15",
                          style: GoogleFonts.poppins(
                              color: accentTurquoise,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "$scoreBlanc Puan",
                          style: GoogleFonts.poppins(
                              color: accentOrange, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8.h,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(accentTurquoise),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. SORU KARTI (İngilizce Kelime) ---
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Seviye Etiketi
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: accentOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: accentOrange.withOpacity(0.5)),
                        ),
                        child: Text(
                          widget.level,
                          style: GoogleFonts.poppins(
                            color: accentOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // --- DÜZELTME BURADA: FittedBox Eklendi ---
                      // Uzun kelime gelirse otomatik küçülecek
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            combinedListWords[currentIndex].quest,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36.sp, // Başlangıç boyutu
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        "Bu kelimenin anlamı nedir?",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 14.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // --- 3. CEVAP ŞIKLARI (Liste) ---
              Expanded(
                flex: 5,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    final isCorrectAnswer =
                        answer == combinedListWords[currentIndex].answer;

                    return _buildModernAnswerButton(
                      text: answer,
                      isCorrectAnswer: isCorrectAnswer,
                      onTap: () {
                        if (!isDisabled) {
                          setState(() {
                            selectedAnswerText = answer;
                          });
                          checkAnswer(isCorrectAnswer);
                        }
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODERN BUTON TASARIMI ---
  Widget _buildModernAnswerButton({
    required String text,
    required bool isCorrectAnswer,
    required VoidCallback onTap,
  }) {
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.white;

    if (showCorrectAnswer) {
      if (isCorrectAnswer) {
        bgColor = correctColor;
        textColor = Colors.white;
        borderColor = correctColor;
      } else if (selectedAnswerText == text) {
        bgColor = wrongColor;
        textColor = Colors.white;
        borderColor = wrongColor;
      } else {
        bgColor = Colors.white.withOpacity(0.5);
        textColor = Colors.black38;
      }
    } else {
      bgColor = Colors.white;
      textColor = const Color(0xFF203A43);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- DÜZELTME BURADA: Expanded ---
            // Cevap şıkkı uzun olursa alt satıra geçsin
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Sonuç İkonu
            if (showCorrectAnswer && isCorrectAnswer)
              const Icon(Icons.check_circle, color: Colors.white)
            else if (showCorrectAnswer && selectedAnswerText == text)
              const Icon(Icons.cancel, color: Colors.white)
            else if (!isDisabled)
              Icon(Icons.circle_outlined, color: Colors.grey.shade300)
          ],
        ),
      ),
    );
  }
}
