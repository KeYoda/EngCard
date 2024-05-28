class SaveWords {
  static List<String> savedQuestions = [];
  static List<String> savedAnswers = [];
  static List<String> savedLvClass = [];
}

class SavedItem {
  String question;
  String answer;
  String lvClass;
  SavedItem(
      {required this.answer, required this.question, required this.lvClass});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedItem &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer &&
          lvClass == other.lvClass;

  @override
  int get hashCode => question.hashCode ^ answer.hashCode ^ lvClass.hashCode;
}
