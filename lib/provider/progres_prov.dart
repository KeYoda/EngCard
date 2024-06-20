import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int _correctAnswers = 0;
  int _totalQuest = 0;
  double testProgressValue = 0.0;

  Map<String, int> _remainingQuestions = {
    'A1': wordsList.length,
    'A2': wordsList2.length,
    'B1': wordsList3.length,
    'B2': wordsList4.length,
    'C1': wordsList5.length,
  };

  Map<String, double> circleProgress = {
    'A1': 0.0,
    'A2': 0.0,
    'B1': 0.0,
    'B2': 0.0,
    'C1': 0.0,
  };

  final Map<String, double> incrementValues = {
    'A1': 0.0025,
    'A2': 0.0021505376344086,
    'B1': 0.0013071895424837,
    'B2': 0.0014705882,
    'C1': 0.0008547009,
  };

  void completeQuestion(String level) {
    if (_remainingQuestions.containsKey(level) &&
        _remainingQuestions[level] != null &&
        _remainingQuestions[level]! > 0) {
      _remainingQuestions[level] = _remainingQuestions[level]! - 1;
      circleProgress[level] =
          1 - (_remainingQuestions[level]! / _totalQuestions(level));
      _saveProgressSettings();
      notifyListeners();
    } else {
      print(
          'Error: Level $level not found in _remainingQuestions or it is null'); // Debugging için eklendi
    }
  }

  int _totalQuestions(String level) {
    switch (level) {
      case 'A1':
        return wordsList.length;
      case 'A2':
        return wordsList2.length;
      case 'B1':
        return wordsList3.length;
      case 'B2':
        return wordsList4.length;
      case 'C1':
        return wordsList5.length;
      default:
        return 0;
    }
  }

  double getCircleProgress(String level) {
    return circleProgress[level] ?? 0.0;
  }

  void resetProgressLength() {
    circleProgress = {
      'A1': 0.0,
      'A2': 0.0,
      'B1': 0.0,
      'B2': 0.0,
      'C1': 0.0,
    };
    _remainingQuestions = {
      'A1': wordsList.length,
      'A2': wordsList2.length,
      'B1': wordsList3.length,
      'B2': wordsList4.length,
      'C1': wordsList5.length,
    };
    _saveProgressSettings();
    notifyListeners();
  }

  double _progressValue = 0.0;
  double _progressValue1 = 0.0;
  double _progressValue2 = 0.0;
  double _progressValue3 = 0.0;
  double _progressValue4 = 0.0;
  double _testProgressValue = 0.0;

  double get progressValue => _progressValue;
  double get progressValue1 => _progressValue1;
  double get progressValue2 => _progressValue2;
  double get progressValue3 => _progressValue3;
  double get progressValue4 => _progressValue4;
  Map<String, int> get remainingQuestions => _remainingQuestions;

  int get correctAnswers => _correctAnswers;
  int get totalQuest => _totalQuest;

  // SharedPreferences anahtarları
  static const String _keyProgressValue = 'progressValue';
  static const String _keyProgressValue1 = 'progressValue1';
  static const String _keyProgressValue2 = 'progressValue2';
  static const String _keyProgressValue3 = 'progressValue3';
  static const String _keyProgressValue4 = 'progressValue4';
  static const String _keyTestProgressValue = 'testProgressValue';

  void _loadProgressSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    remainingQuestions['A1'] =
        prefs.getInt('A1_remainingQuestions') ?? wordsList.length;
    remainingQuestions['A2'] =
        prefs.getInt('A2_remainingQuestions') ?? wordsList2.length;
    remainingQuestions['B1'] =
        prefs.getInt('B1_remainingQuestions') ?? wordsList3.length;
    remainingQuestions['B2'] =
        prefs.getInt('B2_remainingQuestions') ?? wordsList4.length;
    remainingQuestions['C1'] =
        prefs.getInt('C1_remainingQuestions') ?? wordsList5.length;

    circleProgress['A1'] = 1 - (_remainingQuestions['A1']! / wordsList.length);
    circleProgress['A2'] = 1 - (_remainingQuestions['A2']! / wordsList2.length);
    circleProgress['B1'] = 1 - (_remainingQuestions['B1']! / wordsList3.length);
    circleProgress['B2'] = 1 - (_remainingQuestions['B2']! / wordsList4.length);
    circleProgress['C1'] = 1 - (_remainingQuestions['C1']! / wordsList5.length);

    notifyListeners();
  }

  void _saveProgressSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('A1_remainingQuestions', remainingQuestions['A1']!);
    prefs.setInt('A2_remainingQuestions', remainingQuestions['A2']!);
    prefs.setInt('B1_remainingQuestions', remainingQuestions['B1']!);
    prefs.setInt('B2_remainingQuestions', remainingQuestions['B2']!);
    prefs.setInt('C1_remainingQuestions', remainingQuestions['C1']!);
  }

  // SharedPreferences nesnesi
  SharedPreferences? _prefs;

  ProgressProvider() {
    _loadValues();
    _loadProgressSettings();
  }

  // SharedPreferences'ten değerleri yükle
  Future<void> _loadValues() async {
    _prefs = await SharedPreferences.getInstance();
    _progressValue = _prefs?.getDouble(_keyProgressValue) ?? 0.0;
    _progressValue1 = _prefs?.getDouble(_keyProgressValue1) ?? 0.0;
    _progressValue2 = _prefs?.getDouble(_keyProgressValue2) ?? 0.0;
    _progressValue3 = _prefs?.getDouble(_keyProgressValue3) ?? 0.0;
    _progressValue4 = _prefs?.getDouble(_keyProgressValue4) ?? 0.0;
    _testProgressValue = _prefs?.getDouble(_keyTestProgressValue) ?? 0.0;

    notifyListeners();
  }

  // SharedPreferences'e değerleri kaydet
  Future<void> _saveValues() async {
    await _prefs?.setDouble(_keyProgressValue, _progressValue);
    await _prefs?.setDouble(_keyProgressValue1, _progressValue1);
    await _prefs?.setDouble(_keyProgressValue2, _progressValue2);
    await _prefs?.setDouble(_keyProgressValue3, _progressValue3);
    await _prefs?.setDouble(_keyProgressValue4, _progressValue4);
    await _prefs?.setDouble(_keyTestProgressValue, _testProgressValue);
  }

  void increaseProgress() {
    //A1
    _progressValue += 0.0025;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress1() {
    //A2
    _progressValue1 += 0.0021505376344086;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress2() {
    //B1
    _progressValue2 += 0.0013071895424837;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress3() {
    //B2
    _progressValue3 += 0.0014705882;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress4() {
    //C1
    _progressValue4 += 0.0008547009;
    _saveValues();
    notifyListeners();
  }

  void increaseCircleProgress(String level) {
    circleProgress[level] =
        (circleProgress[level] ?? 0.0) + (incrementValues[level] ?? 0.0);
    _saveProgressSettings();
    notifyListeners();
  }

  void resetProgress() {
    _progressValue = 0.0;
    _progressValue1 = 0.0;
    _progressValue2 = 0.0;
    _progressValue3 = 0.0;
    _progressValue4 = 0.0;

    _saveValues();
    notifyListeners();
  }

  void incrementCorrectAnswers() {
    _correctAnswers++;
    notifyListeners();
  }

  void totalQuestCounter() {
    _totalQuest--;
    notifyListeners();
  }

  void resetCorrectAnswers() {
    _correctAnswers = 0;
    _totalQuest = 15;
    notifyListeners();
  }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class ListProgressProvider extends ChangeNotifier {
  int _oneCardWords = 0;
  int _twoCardWords = 0;
  int _threCardWords = 0;
  int _fourCardWords = 0;
  int _fiveCardWords = 0;

  int get oneCardWords => _oneCardWords;
  int get twoCardWords => _twoCardWords;
  int get threCardWords => _threCardWords;
  int get fourCardWords => _fourCardWords;
  int get fiveCardWords => _fiveCardWords;

  static const String _keyOneCardWords = 'OneCardWords';
  static const String _keyTwoCardWords = 'TwoCardWords';
  static const String _keyThreCardWords = 'ThreCardWords';
  static const String _keyFourCardWords = 'FourCardWords';
  static const String _keyFiveCardWords = 'FiveCardWords';

  SharedPreferences? _prefs;

  ListProgressProvider() {
    _loadWordsValues();
  }

  Future<void> _loadWordsValues() async {
    _prefs = await SharedPreferences.getInstance();

    _oneCardWords = _prefs?.getInt(_keyOneCardWords) ?? wordsList.length;
    _twoCardWords = _prefs?.getInt(_keyTwoCardWords) ?? wordsList2.length;
    _threCardWords = _prefs?.getInt(_keyThreCardWords) ?? wordsList3.length;
    _fourCardWords = _prefs?.getInt(_keyFourCardWords) ?? wordsList4.length;
    _fiveCardWords = _prefs?.getInt(_keyFiveCardWords) ?? wordsList5.length;

    notifyListeners();
  }

  Future<void> saveWordsValues() async {
    await _prefs?.setInt(_keyOneCardWords, _oneCardWords);
    await _prefs?.setInt(_keyTwoCardWords, _twoCardWords);
    await _prefs?.setInt(_keyThreCardWords, _threCardWords);
    await _prefs?.setInt(_keyFourCardWords, _fourCardWords);
    await _prefs?.setInt(_keyFiveCardWords, _fiveCardWords);
  }

  void resetWordsProgress() {
    _oneCardWords = wordsList.length;
    _twoCardWords = wordsList2.length;
    _threCardWords = wordsList3.length;
    _fourCardWords = wordsList4.length;
    _fiveCardWords = wordsList5.length;

    notifyListeners();
  }

  void listProgress() {
    //B2
    _oneCardWords -= 1;
    saveWordsValues();
    notifyListeners();
  }

  void listProgress1() {
    //B2
    _twoCardWords -= 1;
    saveWordsValues();
    notifyListeners();
  }

  void listProgress2() {
    //B2
    _threCardWords -= 1;
    saveWordsValues();
    notifyListeners();
  }

  void listProgress3() {
    //B2
    _fourCardWords -= 1;
    saveWordsValues();
    notifyListeners();
  }

  void listProgress4() {
    //B2
    _fiveCardWords -= 1;
    saveWordsValues();
    notifyListeners();
  }
}
