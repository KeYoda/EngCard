import 'package:eng_card/provider/progres_prov.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestResult extends StatelessWidget {
  final int totalQuestions;

  const TestResult({
    Key? key,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var correctAnswerProvider = Provider.of<ProgressProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Test Sonucu',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test Tamamlandı!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Toplam Sorular: $totalQuestions',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Doğru Kelimeler: ${correctAnswerProvider.correctAnswers}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                correctAnswerProvider.resetCorrectAnswers();
                Navigator.pop(context);
              }, // Tetiklenen fonksiyonu çağır
              child: Text('Testi Tekrar Başlat'),
            ),
          ],
        ),
      ),
    );
  }
}
