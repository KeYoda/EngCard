import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/screens/test/test_button.dart';
import 'package:eng_card/screens/test/test_result.dart';
import 'package:flutter/material.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/fivewords_data.dart';
import 'package:provider/provider.dart';
import 'package:eng_card/screens/six_screen.dart';

class TestWord extends StatefulWidget {
  const TestWord({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TestWordState();
  }
}

class _TestWordState extends State<TestWord> {
  int currentIndex = 0;
  List<Words> combinedListWords = [];

  @override
  void initState() {
    super.initState();
    combinedListWords.addAll(wordsList);
    combinedListWords.addAll(wordsList2);
    combinedListWords.addAll(wordsList3);
    combinedListWords.addAll(wordsList4);
    combinedListWords.addAll(wordsList5);
  }

  @override
  Widget build(BuildContext context) {
    var counterWord = Provider.of<ProgressProvider>(context);
    combinedListWords.shuffle();

    final correctAnswer = combinedListWords[currentIndex].answer;

    List<String> answerList = [
      correctAnswer,
      combinedListWords[currentIndex + 1].answer,
      combinedListWords[currentIndex + 2].answer,
      combinedListWords[currentIndex + 3].answer,
      combinedListWords[currentIndex + 4].answer,
    ];
    answerList.shuffle();

    Future<void> nextQuest() async {
      await Future.delayed(Duration(seconds: 1)); // 1 saniye bekle
      setState(() {
        currentIndex++;

        if (currentIndex >= 15) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TestResult(
                totalQuestions: 15,
              ),
            ),
          );
          currentIndex = 0;
        }
      });
    }

    void _calculateCorrectAnswers(bool isCorrect) {
      if (isCorrect) {
        counterWord.incrementCorrectAnswers();
      }
      nextQuest();
    }

    void handleAnswer(bool isCorrect) {
      _calculateCorrectAnswers(isCorrect);
      nextQuest();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whites,
        title: Text(
          'Kelime Bulma',
          style: TextStyle(color: hardgreen),
        ),
        centerTitle: true,
      ),
      backgroundColor: whites,
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Stack(
              children: [
                Container(
                  color: hardgreen,
                  height: 150,
                  width: 500,
                  child: Center(
                    child: Text(
                      combinedListWords[currentIndex].quest,
                      style: TextStyle(color: whites, fontSize: 25),
                    ),
                  ),
                ),
                Positioned(
                  left: 330,
                  top: 10,
                  child: Text(
                    combinedListWords[currentIndex].list,
                    style: TextStyle(color: yellow, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ...answerList.map((answer) => AnswerButton(
                    answer: answer,
                    isCorrect: answer == correctAnswer,
                    onTap: handleAnswer,
                  )),
              const SizedBox(height: 20),
              Text(correctAnswer),
            ],
          ),
        ],
      ),
    );
  }
}
