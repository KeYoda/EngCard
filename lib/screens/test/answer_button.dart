import 'package:eng_card/screens/six_screen.dart';
import 'package:flutter/material.dart';

class AnswerButton extends StatefulWidget {
  final String answer;
  final bool isCorrect;
  final Function(bool) onTap;
  final bool isDisabled;
  final bool showCorrectAnswer;
  final bool isSelected;

  const AnswerButton(
      {Key? key,
      required this.answer,
      required this.isCorrect,
      required this.onTap,
      required this.isDisabled,
      required this.showCorrectAnswer,
      required this.isSelected})
      : super(key: key);

  @override
  _AnswerButtonState createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  Color buttonColor = yellow;

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isDisabled) {
      setState(() {
        buttonColor = yellow;
      });
    } else if (widget.showCorrectAnswer) {
      setState(() {
        if (widget.isCorrect) {
          buttonColor = Colors.green;
        } else if (widget.isSelected) {
          buttonColor = Colors.red;
        }
      });
    }
  }

  void _handleTap() {
    if (!widget.isDisabled) {
      setState(() {
        if (widget.isCorrect) {
          buttonColor = Colors.green;
        } else {
          buttonColor = Colors.red;
        }
      });

      widget.onTap(widget.isCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: SizedBox(
        height: 50,
        width: 380,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: widget.isDisabled ? null : _handleTap,
          child: Text(
            widget.answer,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
