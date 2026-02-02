import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int _correctAnswers = 0;
  int _totalQuest = 15; // Varsayılan değer atandı
  // Test Progress
  double _testProgressValue = 0.0;

  // Kalan soruları takip eden map
  final Map<String, int> _remainingQuestions = {
    'A1': wordsList.length,
    'A2': wordsList2.length,
    'B1': wordsList3.length,
    'B2': wordsList4.length,
    'C1': wordsList5.length,
  };

  // Dairesel ilerlemeyi takip eden map
  Map<String, double> circleProgress = {
    'A1': 0.0,
    'A2': 0.0,
    'B1': 0.0,
    'B2': 0.0,
    'C1': 0.0,
  };

  // Lineer (çubuk) ilerlemeyi takip eden map (Eski _progressValue1, 2, 3 yerine)
  final Map<String, double> _linearProgress = {
    'A1': 0.0,
    'A2': 0.0,
    'B1': 0.0,
    'B2': 0.0,
    'C1': 0.0,
  };

  // Artış miktarları
  final Map<String, double> incrementValues = {
    'A1': 0.0025,
    'A2': 0.0021505376344086,
    'B1': 0.0013071895424837,
    'B2': 0.0014705882,
    'C1': 0.0008547009,
  };

  // Getterlar
  Map<String, int> get remainingQuestions => _remainingQuestions;
  int get correctAnswers => _correctAnswers;
  int get totalQuest => _totalQuest;
  double get testProgressValue => _testProgressValue;

  // Belirli bir level'ın lineer progress değerini getirmek için
  double getLinearProgress(String level) {
    return _linearProgress[level] ?? 0.0;
  }

  // SharedPreferences nesnesi
  SharedPreferences? _prefs;

  ProgressProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAllValues();
  }

  // Tüm değerleri yükle
  void _loadAllValues() {
    if (_prefs == null) return;

    // Remaining Questions Yükleme
    _remainingQuestions.forEach((key, _) {
      _remainingQuestions[key] =
          _prefs!.getInt('${key}_remainingQuestions') ?? _totalQuestions(key);
    });

    // Linear Progress Yükleme (Eski progressValue'lar)
    _linearProgress.forEach((key, _) {
      _linearProgress[key] = _prefs!.getDouble('${key}_progressValue') ?? 0.0;
    });

    // Circle Progress Hesaplama (Kalan sorulara göre)
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

  // --- İŞLEM FONKSİYONLARI ---

  // 1. Lineer Progress Artırma (FlashCardScreen için asıl lazım olan bu)
  void increaseLinearProgress(String level) {
    if (_linearProgress.containsKey(level) &&
        incrementValues.containsKey(level)) {
      double current = _linearProgress[level]!;
      double increment = incrementValues[level]!;

      // 1.0'ı (yani %100'ü) geçmesini engellemek için kontrol
      double newValue = current + increment;
      if (newValue > 1.0) newValue = 1.0;

      _linearProgress[level] = newValue;

      _prefs?.setDouble('${level}_progressValue', newValue);
      notifyListeners();
    }
  }

  // 2. Soru Tamamlama (Circle Progress için)
  void completeQuestion(String level) {
    if (_remainingQuestions.containsKey(level) &&
        _remainingQuestions[level] != null &&
        _remainingQuestions[level]! > 0) {
      _remainingQuestions[level] = _remainingQuestions[level]! - 1;

      // Circle update
      int total = _totalQuestions(level);
      if (total > 0) {
        circleProgress[level] = 1 - (_remainingQuestions[level]! / total);
      }

      // Kaydet
      _prefs?.setInt(
          '${level}_remainingQuestions', _remainingQuestions[level]!);
      notifyListeners();
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

  // --- RESET İŞLEMLERİ ---

  // Tüm level ilerlemelerini sıfırla
  void resetAllProgress() {
    // Linear sıfırla
    _linearProgress.updateAll((key, value) => 0.0);

    // Remaining (Kalan) sıfırla - Full listeye geri döner
    _remainingQuestions['A1'] = wordsList.length;
    _remainingQuestions['A2'] = wordsList2.length;
    _remainingQuestions['B1'] = wordsList3.length;
    _remainingQuestions['B2'] = wordsList4.length;
    _remainingQuestions['C1'] = wordsList5.length;

    // Circle sıfırla
    circleProgress.updateAll((key, value) => 0.0);

    // Kaydet
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

  // --- TEST İŞLEMLERİ ---
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
// LIST PROGRESS PROVIDER
////////////////////////////////////////////////////////////////////////////////

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

    for (var level in _cardWordCounts.keys) {
      _cardWordCounts[level] = _prefs?.getInt('${level}_CardWords') ?? 0;
    }
    notifyListeners();
  }

  Future<void> saveWordsValues() async {
    for (var entry in _cardWordCounts.entries) {
      await _prefs?.setInt('${entry.key}_CardWords', entry.value);
    }
  }

  // Burada WordProvider'a ihtiyaç duyuyoruz çünkü "Full" liste uzunluğunu bilmeli
  void resetWordsProgress({required WordProvider wordProvider}) {
    for (var level in _cardWordCounts.keys) {
      // Dinamik olarak ilgili level'ın kelime sayısını alıp resetler
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
