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

    // 1. Önce kayıtlı bir tarih var mı diye kontrol edelim
    String? savedDateString = _prefs?.getString(_keyLastDate);

    if (savedDateString != null && savedDateString.isNotEmpty) {
      // Kayıtlı tarih varsa, parse et ve kontrol et
      try {
        DateTime lastDate = DateTime.parse(savedDateString);
        DateTime now = DateTime.now();

        // Sadece YIL, AY ve GÜN aynı mı diye bakalım (saat farkı olmasın)
        bool isSameDay = lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day;

        if (!isSameDay) {
          _dailyScore = 0; // Gün değişmiş, günlük skoru sıfırla
          // Gün değiştiği için yeni tarihi kaydetmek gerekebilir,
          // ama incrementScore çağrıldığında zaten kaydedilecek.
        } else {
          _dailyScore = _prefs?.getInt(_keyDailyScore) ?? 0;
        }
      } catch (e) {
        // Tarih formatı bozuksa güvenli davranıp günlük skoru sıfırla
        _dailyScore = 0;
      }
    } else {
      // Hiç tarih yoksa (ilk yükleme), günlük skor 0'dır
      _dailyScore = 0;
    }

    // Toplam ve Bilinen skorları yükle (Bunlar tarihten bağımsız)
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
