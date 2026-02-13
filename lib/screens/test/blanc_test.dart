import 'dart:math';

import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/test/blanc_settings.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BlancTestScreen extends StatefulWidget {
  final List<Words> words;
  final VoidCallback onComplete;
  final String level;

  const BlancTestScreen({
    super.key,
    required this.words,
    required this.onComplete,
    required this.level,
  });

  @override
  State<StatefulWidget> createState() {
    return _TestScreenState();
  }
}

class _TestScreenState extends State<BlancTestScreen> {
  // --- RENK PALETİ ---
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);
  final Color accentTurquoise = const Color(0xFF2EC4B6);
  final Color correctColor = const Color(0xFF2EC4B6); // Yeşil/Turkuaz
  final Color wrongColor = const Color(0xFFEF476F); // Kırmızı

  List<Words> combinedListWords = [];
  String? selectedAnswer;

  int totalQuestionsLimit = 10; // Toplam soru sayısı sabiti
  int currentQuestionIndex = 0; // Şu anki soru (0'dan başlar)
  int scoreBlanc = 0;

  List<QuestionAnswer> answeredQuestionsTest = [];
  int correctAnswersCount = 0;

  final List<String> answers = [];
  bool isDisabled = false;
  bool showCorrectAnswer = false;
  String? selectedAnswerText;

  @override
  void initState() {
    super.initState();
    combinedListWords = widget.words;
    if (combinedListWords.isEmpty) {
      // Hata önleyici: Liste boşsa geri at
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }
    generateAnswers();
  }

  void generateAnswers() {
    // Listeyi karıştır ama mevcut soruyu koru
    // Not: Mantığınızı korudum, sadece değişken isimlerini netleştirdim.

    // Güvenlik kontrolü
    if (currentQuestionIndex >= combinedListWords.length) {
      currentQuestionIndex = 0;
    }

    String correctAnswer = combinedListWords[currentQuestionIndex].quest;

    answers.clear();
    answers.add(correctAnswer);

    // Yanlış cevapları üret
    int attempts = 0;
    while (answers.length < 5 && attempts < 50) {
      String randomAnswer =
          combinedListWords[Random.secure().nextInt(combinedListWords.length)]
              .quest;
      if (!answers.contains(randomAnswer)) {
        answers.add(randomAnswer);
      }
      attempts++;
    }

    // Eğer yeterince kelime yoksa veya döngü bittiyse (listede az kelime varsa)
    // Olduğu kadarıyla devam eder.

    answers.shuffle();
  }

  void checkAnswer(bool isCorrect) {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      progressProv.increaseLinearProgress(widget.level);
      progressProv
          .completeQuestion(combinedListWords[currentQuestionIndex].list);

      isDisabled = true;
      showCorrectAnswer = true;

      if (isCorrect) {
        scoreBlanc += 10;
        correctAnswersCount++;
      }

      // İstatistik için kaydet
      if (currentQuestionIndex < combinedListWords.length) {
        answeredQuestionsTest.add(QuestionAnswer(
          question: combinedListWords[currentQuestionIndex].quest,
          answer: combinedListWords[currentQuestionIndex].answer,
          list: combinedListWords[currentQuestionIndex].list,
        ));
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        setState(() {
          if (currentQuestionIndex < totalQuestionsLimit - 1) {
            currentQuestionIndex++;
            selectedAnswer = null;
            isDisabled = false;
            showCorrectAnswer = false;
            selectedAnswerText = null;

            // Bir sonraki soru için listeyi tekrar karıştırmak isterseniz burayı açabilirsiniz
            // combinedListWords.shuffle();
            // Ancak sıralı gitmek daha mantıklı olabilir.

            generateAnswers();
          } else {
            // Test Bitti
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TestResult(
                  level: widget.level,
                  totalScore: scoreBlanc,
                  correctAnswer: correctAnswersCount,
                  totalQuestions: totalQuestionsLimit,
                  answeredQuestions: answeredQuestionsTest,
                ),
              ),
            );
          }
        });
      });
    });
  }

  String _getFormattedQuestion(String front) {
    // Soru cümlesindeki hedef kelimeyi "......" ile değiştir
    String target = combinedListWords[currentQuestionIndex].quest;
    // Büyük küçük harf duyarlılığı olmadan değiştirmek için regex kullanılabilir
    // Şimdilik basit replace kullanıyoruz
    return front.replaceAll(target, '......');
  }

  @override
  Widget build(BuildContext context) {
    if (combinedListWords.isEmpty) return const SizedBox();

    // İlerleme Yüzdesi
    double progressPercent = (currentQuestionIndex + 1) / totalQuestionsLimit;

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
          "Boşluk Doldurma",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlancSettings()),
              );
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
                          "Soru ${currentQuestionIndex + 1}/$totalQuestionsLimit",
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

              // --- 2. SORU KARTI (Glassmorphism) ---
              Expanded(
                flex: 3, // Üst kısım biraz daha geniş
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
                          combinedListWords[currentQuestionIndex].list,
                          style: GoogleFonts.poppins(
                            color: accentOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Soru Metni
                      Text(
                        _getFormattedQuestion(
                            combinedListWords[currentQuestionIndex].front),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        "Boşluğa hangi kelime gelmeli?",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12.sp,
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
                        answer == combinedListWords[currentQuestionIndex].quest;

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
    // Renk Durumları
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.white;

    if (showCorrectAnswer) {
      if (isCorrectAnswer) {
        // Doğru cevap her zaman yeşil yanar
        bgColor = correctColor;
        textColor = Colors.white;
        borderColor = correctColor;
      } else if (selectedAnswerText == text) {
        // Yanlış seçilen kırmızı yanar
        bgColor = wrongColor;
        textColor = Colors.white;
        borderColor = wrongColor;
      } else {
        // Diğerleri pasifleşir
        bgColor = Colors.white.withOpacity(0.5);
        textColor = Colors.black38;
      }
    } else {
      // Henüz seçilmedi
      bgColor = Colors.white;
      textColor = const Color(0xFF203A43);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
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
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),

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
