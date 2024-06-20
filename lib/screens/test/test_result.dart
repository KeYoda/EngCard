import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/blanc_test.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:eng_card/screens/test/voice_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestResult extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswer;
  final int totalScore;
  final List<QuestionAnswer> answeredQuestions;

  const TestResult({
    Key? key,
    required this.totalQuestions,
    required this.correctAnswer,
    required this.answeredQuestions,
    required this.totalScore,
  }) : super(key: key);

  @override
  _TestResultState createState() => _TestResultState();
}

class _TestResultState extends State<TestResult> {
  late List<Color> buttonCols;
  late FavoriteList favoriteList;

  @override
  void initState() {
    super.initState();
    buttonCols = List<Color>.filled(widget.answeredQuestions.length, hardgreen);
    favoriteList = Provider.of<FavoriteList>(context, listen: false);
  }

  void toggleFav(int index) {
    SavedItem newFavorite = SavedItem(
      answer: widget.answeredQuestions[index].answer,
      question: widget.answeredQuestions[index].question,
      lvClass: widget.answeredQuestions[index].list,
    );
    if (favoriteList.favorites.contains(newFavorite)) {
      favoriteList.deleteFavorite(
        favoriteList.favorites.indexOf(newFavorite),
      );
      setState(() {
        buttonCols[index] = hardgreen; // Favori kaldırıldığında rengi güncelle
      });
    } else {
      favoriteList.addFavorite(newFavorite);
      setState(() {
        buttonCols[index] = Colors.red; // Favori eklendiğinde rengi güncelle
      });
    }
    favoriteList.saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    var progressProv = Provider.of<ProgressProvider>(context);
    int indexLevel = 0;

    List<Words> combinedWords = []
      ..addAll(wordsList)
      ..addAll(wordsList2)
      ..addAll(wordsList3)
      ..addAll(wordsList4)
      ..addAll(wordsList5);
    int wrongWord = widget.totalQuestions - widget.correctAnswer;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Text(
          'Test Tamamlandı!',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 160.h,
                width: 400.w,
                child: Card(
                  color: hardgreen,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 100.h,
                        left: 30.w,
                        child: Text(
                          'Soru Sayısı:' '        ${widget.totalQuestions}',
                          style: TextStyle(color: whites, fontSize: 15.sp),
                        ),
                      ),
                      Positioned(
                        bottom: 70.h,
                        left: 30.w,
                        child: Text(
                          'Doğru Sayısı:  ' '     ${widget.correctAnswer}',
                          style: TextStyle(color: whites, fontSize: 15.sp),
                        ),
                      ),
                      Positioned(
                        bottom: 40.h,
                        left: 30.w,
                        child: Text(
                          'Yanlış Sayısı:  ' '     $wrongWord',
                          style: TextStyle(color: whites, fontSize: 15.sp),
                        ),
                      ),
                      Positioned(
                        bottom: 70.h,
                        left: 200.w,
                        child: Text(
                          'Puan:  ' '     ${widget.totalScore}',
                          style: TextStyle(color: whites, fontSize: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: hardgreen,
                endIndent: 24.w,
                indent: 24.w,
              ),
              SizedBox(
                height: 370.h,
                width: 370.w,
                child: Card(
                  elevation: 4,
                  color: yellow.withOpacity(0.9),
                  child: ListView.builder(
                    itemCount: widget.answeredQuestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          widget.answeredQuestions[index].question,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.answeredQuestions[index].answer),
                        leading: Text(
                          widget.answeredQuestions[index].list,
                          style: TextStyle(color: whites),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            toggleFav(index);
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: buttonCols[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              ElevatedButton(
                onPressed: () {
                  Provider.of<ScoreProvider>(context, listen: false)
                      .incrementScore(widget.totalScore);
                  Provider.of<ProgressProvider>(context, listen: false)
                      .resetCorrectAnswers();
                  Navigator.pop(context);
                  if (widget.totalQuestions == 15) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestWord(
                          onComplete: () {
                            if (progressProv.remainingQuestions == 0) {
                              progressProv.resetProgressLength();
                            }
                          },
                          words: combinedWords,
                        ),
                      ),
                    );
                  } else if (widget.totalQuestions == 10) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlancTestScreen(
                            level: widget.answeredQuestions[indexLevel].list,
                            onComplete: () {
                              if (progressProv.remainingQuestions == 0) {
                                progressProv.resetProgressLength();
                              }
                            },
                            words: combinedWords,
                          ),
                        ));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoiceTest(
                            level: widget.answeredQuestions[indexLevel].list,
                            onComplete: () {
                              if (progressProv.remainingQuestions == 0) {
                                progressProv.resetProgressLength();
                              }
                            },
                            words: combinedWords,
                          ),
                        ));
                  }
                },
                child: const Icon(Icons.restart_alt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
