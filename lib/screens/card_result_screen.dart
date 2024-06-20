import 'package:flutter/material.dart';

class ReviewResultScreen extends StatelessWidget {
  final int reviewedCards;

  const ReviewResultScreen({Key? key, required this.reviewedCards})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Completed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have reviewed $reviewedCards cards!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Navigate back to the card review screen
              },
              child: Text('Back to Review'),
            ),
          ],
        ),
      ),
    );
  }
}
