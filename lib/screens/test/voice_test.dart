import 'dart:math';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:eng_card/screens/test/voice_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VoiceTest extends StatefulWidget {
  final List<Words> words;
  final VoidCallback onComplete;
  final String level;

  const VoiceTest({
    super.key,
    required this.level,
    required this.onComplete,
    required this.words,
  });

  @override
  State<StatefulWidget> createState() => _StateVoiceTest();
}

class _StateVoiceTest extends State<VoiceTest> {
  // --- MODERN RENK PALETİ ---
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);
  final Color accentTurquoise = const Color(0xFF2EC4B6);

  List<Words> combinedListWordsCard = [];
  List<QuestionAnswer> answeredQuestionsCard = [];
  FlutterTts flutterTts = FlutterTts();

  int currentIndex = 0;
  int scoreVoice = 0;
  int correctAnswerCount = 0;
  int totalQuestsCount = 8; // Test soru sınırı

  List<String> userInput = [];
  List<String> shuffledCharacters = [];
  Set<int> pressedButtons = {};

  @override
  void initState() {
    super.initState();
    _initTts();
    combinedListWordsCard = List.from(widget.words);
    combinedListWordsCard.shuffle();
    _initializeUserInput();
  }

  void _initializeUserInput() {
    if (currentIndex < combinedListWordsCard.length) {
      String question = combinedListWordsCard[currentIndex].quest;
      userInput = List.filled(question.length, '');
      shuffledCharacters = question.split('');
      shuffledCharacters.shuffle(Random());
      pressedButtons.clear();

      // İlk seslendirmeyi otomatik yapabiliriz
      _speak(question);
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

  void _goToNextQuestion() {
    if (currentIndex < totalQuestsCount - 1) {
      // Mevcut soruyu cevaplanmış olarak kaydet (eğer daha önce eklenmediyse)
      _addCurrentToAnswered();

      setState(() {
        currentIndex++;
        _initializeUserInput();
      });
    }
  }

  void _addCurrentToAnswered() {
    // Aynı sorunun mükerrer eklenmesini önlemek için
    if (answeredQuestionsCard.length <= currentIndex) {
      answeredQuestionsCard.add(QuestionAnswer(
        question: combinedListWordsCard[currentIndex].quest,
        answer: combinedListWordsCard[currentIndex].answer,
        list: combinedListWordsCard[currentIndex].list,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= totalQuestsCount) {
      return const SizedBox(); // Navigator tetiklenecek
    }

    String currentWord = combinedListWordsCard[currentIndex].quest;
    double progressPercent = (currentIndex + 1) / totalQuestsCount;

    // Test Bitince Sonuç Ekranına Git
    if (currentIndex >= totalQuestsCount - 1 &&
        !userInput.contains('') &&
        userInput.join('') == currentWord) {
      // Bu mantık check aşamasında tetiklenecek
    }

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
          "Dinleme Testi",
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
                  MaterialPageRoute(
                      builder: (context) => const VoiceSettings()));
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
                          "Soru ${currentIndex + 1}/$totalQuestsCount",
                          style: GoogleFonts.poppins(
                              color: accentTurquoise,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "$scoreVoice Puan",
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

              // --- 2. SES ÇALMA ALANI (Glass Card) ---
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                padding: EdgeInsets.symmetric(vertical: 30.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () => _speak(currentWord),
                      icon: Icon(Icons.volume_up_rounded,
                          size: 60.sp, color: accentOrange),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Kelimeyi dinle ve yaz",
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),

              // --- 3. HARF KUTULARI (Kullanıcı Girişi) ---
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.w,
                  runSpacing: 10.h,
                  children: _buildLetterBoxes(),
                ),
              ),

              const Spacer(),

              // --- 4. İPUCU ALANI ---
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: accentOrange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        combinedListWordsCard[currentIndex].answer,
                        style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                            fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // --- 5. KLAVYE (Harf Butonları) ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _buildLetterButtons(),
                    ),
                    SizedBox(height: 20.h),

                    // Alt Kontroller (Geri Al & Pas Geç)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              if (pressedButtons.isNotEmpty) {
                                int lastIndex = pressedButtons.last;
                                pressedButtons.remove(lastIndex);
                                int lastEmpty = userInput.indexOf('');
                                if (lastEmpty == -1) {
                                  userInput[userInput.length - 1] = '';
                                } else if (lastEmpty > 0) {
                                  userInput[lastEmpty - 1] = '';
                                }
                              }
                            });
                          },
                          icon: const Icon(Icons.backspace_outlined,
                              color: Colors.white54),
                          label: Text("Geri",
                              style:
                                  GoogleFonts.poppins(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: _goToNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text("Pas Geç",
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLetterBoxes() {
    // Harf sayısına göre kutu genişliği azalır
    double boxWidth = userInput.length > 10 ? 25.w : 35.w;
    double fontSize = userInput.length > 10 ? 16.sp : 20.sp;

    return List.generate(userInput.length, (index) {
      return Container(
        width: boxWidth,
        height: 45.h,
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: userInput[index].isEmpty
                      ? Colors.white24
                      : accentTurquoise,
                  width: 2)),
        ),
        child: Center(
          child: Text(
            userInput[index].toUpperCase(),
            style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      );
    });
  }

  List<Widget> _buildLetterButtons() {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    // Dinamik Boyutlandırma: Harf sayısı arttıkça buton küçülür
    double buttonWidth = shuffledCharacters.length > 10 ? 35.w : 42.w;
    double buttonHeight = shuffledCharacters.length > 10 ? 40.h : 48.h;
    double fontSize = shuffledCharacters.length > 10 ? 14.sp : 18.sp;

    return List.generate(shuffledCharacters.length, (index) {
      bool isPressed = pressedButtons.contains(index);

      return GestureDetector(
        onTap: isPressed
            ? null
            : () {
                int firstEmptyIndex = userInput.indexOf('');
                if (firstEmptyIndex != -1) {
                  setState(() {
                    userInput[firstEmptyIndex] = shuffledCharacters[index];
                    pressedButtons.add(index);
                  });
                  _checkWordComplete(progressProv);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonWidth, // Dinamik genişlik
          height: buttonHeight, // Dinamik yükseklik
          decoration: BoxDecoration(
            color: isPressed ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isPressed
                ? []
                : [
                    const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
          ),
          child: Center(
            child: Text(
              shuffledCharacters[index].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: fontSize, // Dinamik font
                fontWeight: FontWeight.bold,
                color: isPressed ? Colors.white10 : const Color(0xFF203A43),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _checkWordComplete(ProgressProvider progressProv) {
    if (!userInput.contains('')) {
      _addCurrentToAnswered();

      String result = userInput.join('');
      String target = combinedListWordsCard[currentIndex].quest;

      if (result.toLowerCase() == target.toLowerCase()) {
        scoreVoice += 10;
        correctAnswerCount++;
        progressProv.increaseLinearProgress(widget.level);
        progressProv.completeQuestion(widget.level);

        // Doğru efekti/bekleme
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            if (currentIndex < totalQuestsCount - 1) {
              setState(() {
                currentIndex++;
                _initializeUserInput();
              });
            } else {
              _finishTest();
            }
          }
        });
      } else {
        // Hatalı Giriş: Titret veya Sıfırla
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              userInput = List.filled(
                  combinedListWordsCard[currentIndex].quest.length, '');
              pressedButtons.clear();
            });
          }
        });
      }
    }
  }

  void _finishTest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResult(
          level: widget.level,
          totalQuestions: totalQuestsCount,
          correctAnswer: correctAnswerCount,
          answeredQuestions: answeredQuestionsCard,
          totalScore: scoreVoice,
        ),
      ),
    );
  }
}
