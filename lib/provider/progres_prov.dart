import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int _correctAnswers = 0;

  double _progressValue = 0.0;
  double _progressValue1 = 0.0;
  double _progressValue2 = 0.0;
  double _progressValue3 = 0.0;
  double _progressValue4 = 0.0;

  double get progressValue => _progressValue;
  double get progressValue1 => _progressValue1;
  double get progressValue2 => _progressValue2;
  double get progressValue3 => _progressValue3;
  double get progressValue4 => _progressValue4;
  int get correctAnswers => _correctAnswers;

  // SharedPreferences anahtarları
  static const String _keyProgressValue = 'progressValue';
  static const String _keyProgressValue1 = 'progressValue1';
  static const String _keyProgressValue2 = 'progressValue2';
  static const String _keyProgressValue3 = 'progressValue3';
  static const String _keyProgressValue4 = 'progressValue4';

  // SharedPreferences nesnesi
  SharedPreferences? _prefs;

  ProgressProvider() {
    _loadValues();
  }

  // SharedPreferences'ten değerleri yükle
  Future<void> _loadValues() async {
    _prefs = await SharedPreferences.getInstance();
    _progressValue = _prefs?.getDouble(_keyProgressValue) ?? 0.0;
    _progressValue1 = _prefs?.getDouble(_keyProgressValue1) ?? 0.0;
    _progressValue2 = _prefs?.getDouble(_keyProgressValue2) ?? 0.0;
    _progressValue3 = _prefs?.getDouble(_keyProgressValue3) ?? 0.0;
    _progressValue4 = _prefs?.getDouble(_keyProgressValue4) ?? 0.0;

    notifyListeners();
  }

  // SharedPreferences'e değerleri kaydet
  Future<void> _saveValues() async {
    await _prefs?.setDouble(_keyProgressValue, _progressValue);
    await _prefs?.setDouble(_keyProgressValue1, _progressValue1);
    await _prefs?.setDouble(_keyProgressValue2, _progressValue2);
    await _prefs?.setDouble(_keyProgressValue3, _progressValue3);
    await _prefs?.setDouble(_keyProgressValue4, _progressValue4);
  }

  void increaseProgress() {
    //A1
    _progressValue += 0.0024330900243309;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress1() {
    //A2
    _progressValue1 += 0.0021367521367521;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress2() {
    //B1
    _progressValue2 += 0.0012853470437018;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress3() {
    //B2
    _progressValue3 += 0.0014619883040936;
    _saveValues();
    notifyListeners();
  }

  void increaseProgress4() {
    //C1
    _progressValue4 += 0.0007788162;
    _saveValues();
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

  void resetCorrectAnswers() {
    _correctAnswers = 0;
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
