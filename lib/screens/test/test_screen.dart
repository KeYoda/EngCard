import 'dart:math';

import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TestScreenState();
  }
}

class _TestScreenState extends State<TestScreen> {
  final List<Words> combinedListWords = [];
  String? selectedAnswer;

  int currentIndex = 0;

  final List<String> answers = [];

  @override
  void initState() {
    super.initState();
    generateAnswers();
  }

  void generateAnswers() {
    // Combine words from all lists
    combinedListWords.addAll(wordsList);
    combinedListWords.addAll(wordsList2);
    combinedListWords.addAll(wordsList3);
    combinedListWords.addAll(wordsList4);
    combinedListWords.addAll(wordsList5);

    // Shuffle the combined list
    combinedListWords.shuffle();

    // Extract the correct answer and shuffle it with 4 random answers
    String correctAnswer = combinedListWords[currentIndex].quest;
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

  void checkAnswer() {
    if (selectedAnswer == combinedListWords[currentIndex].answer) {
      print("Correct!");
    } else {
      print("Incorrect!");
    }

    setState(() {
      if (currentIndex < combinedListWords.length - 1) {
        currentIndex++;
        selectedAnswer = null; // Clear selected answer for the next question
        generateAnswers(); // Generate new answers with a new correct answer
      } else {
        print("Test completed!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Uygulaması"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _getFormattedQuestion(combinedListWords[currentIndex].front,
                  combinedListWords[currentIndex].quest),
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                  answers.length,
                  (index) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedAnswer = answers[index];
                          });
                          checkAnswer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedAnswer == answers[index]
                              ? Colors.green
                              : null,
                        ),
                        child: Text(answers[index].trim()),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedQuestion(String question, String correctAnswer) {
    // Split the question into words
    List<String> words = question.split(' ');

    // Find the index of the correct answer word (case-insensitive)
    int correctAnswerIndex = -1;
    for (int i = 0; i < words.length; i++) {
      if (words[i].toLowerCase() == correctAnswer.toLowerCase()) {
        correctAnswerIndex = i;
        break; // Stop searching once the word is found
      }
    }

    // Replace the correct answer word with "..."
    if (correctAnswerIndex != -1) {
      words[correctAnswerIndex] = '.....';
    }

    // Join the words back together
    return words.join(' '); // Implicitly returns null if words is empty
  }
}
