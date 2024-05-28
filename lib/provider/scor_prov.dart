import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreProvider extends ChangeNotifier {
  int _dailyScore = 0;
  int _totalScore = 0;
  int _knownScore = 0;

  int get dailyScore => _dailyScore;
  int get totalScore => _totalScore;
  int get knownScore => _knownScore;

  static const String _keyDailyScore = 'dailyScore';
  static const String _keyKnownScore = 'knownScore';

  static const String _keyTotalScore = 'totalScore';
  static const String _keyLastDate = 'lastDate';

  SharedPreferences? _prefs;

  ScoreProvider() {
    _loadScore();
  }

  Future<void> _loadScore() async {
    _prefs = await SharedPreferences.getInstance();

    // Günlük skoru kontrol et
    DateTime lastDate = DateTime.parse(_prefs?.getString(_keyLastDate) ?? '');
    DateTime now = DateTime.now();
    if (lastDate.day != now.day ||
        lastDate.month != now.month ||
        lastDate.year != now.year) {
      // Eğer günler değişmişse, günlük skoru sıfırla
      _dailyScore = 0;
    } else {
      _dailyScore = _prefs?.getInt(_keyDailyScore) ?? 0;
    }

    // Toplam skoru yükle
    _totalScore = _prefs?.getInt(_keyTotalScore) ?? 0;
    _knownScore = _prefs?.getInt(_keyKnownScore) ?? 0;

    notifyListeners();
  }

  Future<void> _saveScore() async {
    await _prefs?.setInt(_keyDailyScore, _dailyScore);
    await _prefs?.setInt(_keyTotalScore, _totalScore);
    await _prefs?.setInt(_keyKnownScore, _knownScore);

    await _prefs?.setString(_keyLastDate, DateTime.now().toIso8601String());
  }

  Future<void> incrementScore(int value) async {
    _dailyScore += value;
    _totalScore += value;
    _knownScore += 1;

    await _saveScore();
    notifyListeners();
  }

  Future<void> resetTotalScore() async {
    _totalScore = 0;
    _knownScore = 0;
    _dailyScore = 0;
    await _saveScore();
    notifyListeners();
  }
}
