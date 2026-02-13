import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int _correctAnswers = 0;
  int _totalQuest = 15;
  double _testProgressValue = 0.0;

  // Başlangıçta 0 atıyoruz, Constructor içinde doğrusunu yükleyeceğiz
  final Map<String, int> _remainingQuestions = {
    'A1': 0,
    'A2': 0,
    'B1': 0,
    'B2': 0,
    'C1': 0,
  };

  Map<String, double> circleProgress = {
    'A1': 0.0,
    'A2': 0.0,
    'B1': 0.0,
    'B2': 0.0,
    'C1': 0.0,
  };

  final Map<String, double> _linearProgress = {
    'A1': 0.0,
    'A2': 0.0,
    'B1': 0.0,
    'B2': 0.0,
    'C1': 0.0,
  };

  // Artış miktarları (Dinamik hesaplanacak, sabit değer yerine)
  // 1 / ToplamSoruSayısı formülü ile
  final Map<String, double> incrementValues = {};

  Map<String, int> get remainingQuestions => _remainingQuestions;
  int get correctAnswers => _correctAnswers;
  int get totalQuest => _totalQuest;
  double get testProgressValue => _testProgressValue;

  double getLinearProgress(String level) {
    return _linearProgress[level] ?? 0.0;
  }

  SharedPreferences? _prefs;

  ProgressProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Increment değerlerini dinamik hesapla (wordsListOne kullanarak)
    _calculateIncrementValues();

    _loadAllValues();
  }

  // --- DİNAMİK ARTIŞ DEĞERİ HESAPLAMA ---
  void _calculateIncrementValues() {
    // Her seviyenin toplam kelime sayısını bulup, 1'i o sayıya bölüyoruz.
    // Örn: A1'de 400 kelime varsa, her doğru cevapta bar 1/400 oranında artar.
    for (String level in ['A1', 'A2', 'B1', 'B2', 'C1']) {
      int total = _totalQuestions(level);
      if (total > 0) {
        incrementValues[level] = 1.0 / total;
      } else {
        incrementValues[level] = 0.0;
      }
    }
  }

  void _loadAllValues() {
    if (_prefs == null) return;

    _remainingQuestions.forEach((key, _) {
      _remainingQuestions[key] =
          _prefs!.getInt('${key}_remainingQuestions') ?? _totalQuestions(key);
    });

    _linearProgress.forEach((key, _) {
      _linearProgress[key] = _prefs!.getDouble('${key}_progressValue') ?? 0.0;
    });

    // Circle Progress Hesaplama
    _remainingQuestions.forEach((key, val) {
      int total = _totalQuestions(key);
      if (total > 0) {
        circleProgress[key] = 1 - (val / total);
      } else {
        circleProgress[key] = 0.0;
      }
    });

    _testProgressValue = _prefs!.getDouble('testProgressValue') ?? 0.0;
    notifyListeners();
  }

  void increaseLinearProgress(String level) {
    // Eğer hesaplanmadıysa tekrar hesapla
    if (incrementValues.isEmpty) _calculateIncrementValues();

    if (_linearProgress.containsKey(level) &&
        incrementValues.containsKey(level)) {
      double current = _linearProgress[level]!;
      double increment = incrementValues[level]!;

      double newValue = current + increment;
      if (newValue > 1.0) newValue = 1.0;

      _linearProgress[level] = newValue;
      _prefs?.setDouble('${level}_progressValue', newValue);
      notifyListeners();
    }
  }

  void completeQuestion(String level) {
    if (_remainingQuestions.containsKey(level) &&
        _remainingQuestions[level] != null &&
        _remainingQuestions[level]! > 0) {
      _remainingQuestions[level] = _remainingQuestions[level]! - 1;

      int total = _totalQuestions(level);
      if (total > 0) {
        circleProgress[level] = 1 - (_remainingQuestions[level]! / total);
      }

      _prefs?.setInt(
          '${level}_remainingQuestions', _remainingQuestions[level]!);
      notifyListeners();
    }
  }

  // --- DÜZELTME: wordsListOne KULLANIMI ---
  int _totalQuestions(String level) {
    // wordsListOne global listesinden, level'ı eşleşenleri say
    return wordsListOne.where((w) => w.list == level).length;
  }

  double getCircleProgress(String level) {
    return circleProgress[level] ?? 0.0;
  }

  void resetAllProgress() {
    _linearProgress.updateAll((key, value) => 0.0);

    // Remaining'i full sayıya eşitle
    for (String level in ['A1', 'A2', 'B1', 'B2', 'C1']) {
      _remainingQuestions[level] = _totalQuestions(level);
    }

    circleProgress.updateAll((key, value) => 0.0);
    _saveAllToPrefs();
    notifyListeners();
  }

  void _saveAllToPrefs() {
    if (_prefs == null) return;
    _remainingQuestions.forEach((key, val) {
      _prefs!.setInt('${key}_remainingQuestions', val);
    });
    _linearProgress.forEach((key, val) {
      _prefs!.setDouble('${key}_progressValue', val);
    });
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

// --- LIST PROGRESS PROVIDER ---
class ListProgressProvider extends ChangeNotifier {
  final Map<String, int> _cardWordCounts = {
    'A1': 0,
    'A2': 0,
    'B1': 0,
    'B2': 0,
    'C1': 0,
  };

  Map<String, int> get cardWordCounts => _cardWordCounts;
  SharedPreferences? _prefs;

  ListProgressProvider() {
    _loadWordsValues();
  }

  Future<void> _loadWordsValues() async {
    _prefs = await SharedPreferences.getInstance();

    // Eğer kayıtlı veri yoksa, varsayılan olarak full listeyi al
    for (var level in _cardWordCounts.keys) {
      int? savedCount = _prefs?.getInt('${level}_CardWords');
      if (savedCount != null) {
        _cardWordCounts[level] = savedCount;
      } else {
        // İlk açılışta full sayı
        _cardWordCounts[level] =
            wordsListOne.where((w) => w.list == level).length;
      }
    }
    notifyListeners();
  }

  Future<void> saveWordsValues() async {
    for (var entry in _cardWordCounts.entries) {
      await _prefs?.setInt('${entry.key}_CardWords', entry.value);
    }
  }

  void resetWordsProgress({required WordProvider wordProvider}) {
    for (var level in _cardWordCounts.keys) {
      // Kelime sayısını wordsListOne üzerinden veya WordProvider üzerinden alabilirsin
      // WordProvider daha güvenlidir çünkü güncel listeyi tutar
      _cardWordCounts[level] = wordProvider.getWords(level).length;
    }
    saveWordsValues();
    notifyListeners();
  }

  void decreaseProgress(String level) {
    if (_cardWordCounts.containsKey(level) && _cardWordCounts[level]! > 0) {
      _cardWordCounts[level] = _cardWordCounts[level]! - 1;
      saveWordsValues();
      notifyListeners();
    }
  }

  int getProgress(String level) {
    return _cardWordCounts[level] ?? 0;
  }
}
