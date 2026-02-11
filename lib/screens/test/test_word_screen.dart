import 'dart:math';

import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/settings.dart';
import 'package:eng_card/screens/six_screen.dart';
// import 'package:eng_card/screens/six_screen.dart'; // Kullanılmıyorsa kaldırın
import 'package:eng_card/screens/test/answer_button.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TestWord extends StatefulWidget {
  final List<Words> words;
  final String level; // EKLENDİ: Provider'ı güncellemek için gerekli
  final VoidCallback onComplete;

  const TestWord({
    super.key,
    required this.words,
    required this.level, // Constructor'a eklendi
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
  // Toplam soru sayısı (İsteğe göre 15 sabit kalabilir veya listenin uzunluğu olabilir)
  int remainingQuestsDisplay = 15;
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
    // Gelen listeyi bozmamak için kopyasını alıyoruz
    combinedListWords = List.from(widget.words);
    generateAnswers();
  }

  void generateAnswers() {
    // Listeyi karıştırıyoruz ama currentIndex'i korumamız lazım,
    // o yüzden sadece cevap şıklarını karıştırmak daha güvenli.
    // Ancak kelime sırası her testte farklı olsun istiyorsanız,
    // initState'de bir kere shuffle yapıp burada index ile ilerlemek daha iyidir.
    if (currentIndex == 0) {
      combinedListWords.shuffle();
    }

    String correctAnswer = combinedListWords[currentIndex].answer;

    // Sayaç mantığı
    if (remainingQuestsDisplay > 0) remainingQuestsDisplay--;

    answers.clear();
    answers.add(correctAnswer);

    // Yanlış şıkları ekle
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

    // Eğer liste çok kısaysa ve 4 şık çıkmıyorsa döngü sonsuza girmesin diye önlem aldık.
    answers.shuffle();
  }

  void checkAnswer(bool isCorrect) {
    var progressProv = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      isDisabled = true;
      showCorrectAnswer = true;

      if (isCorrect) {
        // YENİ PROVIDER YAPISINA GÖRE GÜNCELLENDİ:
        progressProv.increaseLinearProgress(widget.level);

        // Bu kelimenin ait olduğu listeye göre circle progress güncellemesi
        // (Genelde widget.level ile words[i].list aynıdır ama garanti olsun)
        progressProv.completeQuestion(widget.level);

        scoreBlanc = scoreBlanc + 10;
        correctAnswersCount++;
      }

      if (currentIndex < combinedListWords.length) {
        String question = combinedListWords[currentIndex].quest;
        String list = combinedListWords[currentIndex].list; // veya widget.level
        String answer = combinedListWords[currentIndex].answer;

        answeredQuestionsTest.add(QuestionAnswer(
          question: question,
          answer: answer,
          list: list,
        ));
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Ekranın hala açık olduğunu kontrol et
          setState(() {
            // 15 soruluk test veya liste bitene kadar
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
                    totalQuestions:
                        currentIndex + 1, // Gerçek çözülen soru sayısı
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
    // ScreenUtil init işlemini genelde main.dart'ta yapmak daha sağlıklıdır.
    // Ama burada kalmasında da bir sakınca yok.
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // Hata önleme: Liste boşsa veya index taştıysa
    if (combinedListWords.isEmpty || currentIndex >= combinedListWords.length) {
      return const Scaffold(
        body: Center(child: Text("Test için yeterli kelime yok.")),
      );
    }

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
        title: Text(
            "Test Uygulaması - ${widget.level}"), // Hangi level testi olduğu görünsün
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
                    widget.level, // Dinamik Level Gösterimi
                    style: TextStyle(
                        color: orange,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold),
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
                  // Kullanıcı zaten bir şıkkı seçtiyse tekrar tıklamasın
                  if (!isDisabled) {
                    setState(() {
                      selectedAnswer = answers[index];
                      selectedAnswerText = answers[index];
                    });
                    checkAnswer(isCorrect);
                  }
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
                      text: '$remainingQuestsDisplay',
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
