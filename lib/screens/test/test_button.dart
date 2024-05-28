// answer_button.dart
import 'package:flutter/material.dart';

class AnswerButton extends StatefulWidget {
  final String answer;
  final bool isCorrect;
  final Function onTap;

  const AnswerButton({
    Key? key,
    required this.answer,
    required this.isCorrect,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnswerButtonState createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  Color buttonColor = Colors.yellow; // Default color

  void _handleTap() {
    setState(() {
      buttonColor = widget.isCorrect ? Colors.green : Colors.red;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        buttonColor = Colors.yellow; // Reset to default color
      });
    });

    widget.onTap(widget.isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: SizedBox(
        height: 40,
        width: 400, // Adjust the width as needed
        child: TextButton(
          style: TextButton.styleFrom(backgroundColor: buttonColor),
          onPressed: _handleTap,
          child: Text(
            widget.answer,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
