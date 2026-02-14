import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider extends ChangeNotifier {
  int _streakCount = 0; // Toplam seri
  String _lastStreakDate = ""; // Seri en son ne zaman EKLENDİ?

  int _dailyCount = 0; // Bugün kaç kart kaydırdı?
  String _lastProgressDate = ""; // Bu sayaç hangi güne ait?

  // Hedef
  static const int dailyTarget = 10;

  // Getters
  int get streakCount => _streakCount;
  int get dailyCount => _dailyCount;
  bool get isTargetReached => _dailyCount >= dailyTarget;

  StreakProvider() {
    _loadData();
  }

  // Tarih formatlayıcı (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _streakCount = prefs.getInt('streakCount') ?? 0;
    _lastStreakDate = prefs.getString('lastStreakDate') ?? "";

    _dailyCount = prefs.getInt('dailyCount') ?? 0;
    _lastProgressDate = prefs.getString('lastProgressDate') ?? "";

    _checkDateReset(); // Gün değiştiyse sayacı sıfırla
  }

  // 1. GÜN KONTROLÜ: Yeni güne girdiysek sayacı (0/10) sıfırla
  Future<void> _checkDateReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayStr = _formatDate(DateTime.now());

    // Eğer son işlem tarihi bugüne eşit değilse, yeni bir gündür. Sayacı sıfırla.
    if (_lastProgressDate != todayStr) {
      _dailyCount = 0;
      _lastProgressDate = todayStr;
      await prefs.setInt('dailyCount', _dailyCount);
      await prefs.setString('lastProgressDate', _lastProgressDate);
      notifyListeners();
    }
  }

  // 2. İLERLEME KAYDET: Kart kaydırıldığında bu çağrılacak
  Future<void> incrementDailyProgress() async {
    await _checkDateReset(); // Güvenlik kontrolü

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayStr = _formatDate(DateTime.now());

    // Zaten bugün seri işlendi ise (hedef geçildi), sadece sayacı artır (görsellik için)
    if (_lastStreakDate == todayStr) {
      _dailyCount++;
      await prefs.setInt('dailyCount', _dailyCount);
      notifyListeners();
      return;
    }

    // Hedefe henüz ulaşılmadıysa artır
    _dailyCount++;
    await prefs.setInt('dailyCount', _dailyCount);

    // HEDEF KONTROLÜ (10 Oldu mu?)
    if (_dailyCount >= dailyTarget) {
      _updateStreakLogic(todayStr);
    }

    notifyListeners();
  }

  // 3. SERİ MANTIĞI (Sadece hedef tamamlanınca çalışır)
  Future<void> _updateStreakLogic(String todayStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    // Dünün tarihi
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String yesterdayStr = _formatDate(yesterday);

    if (_lastStreakDate == yesterdayStr) {
      // Dün yapmış, bugün de yaptı -> Seri Artar 🔥
      _streakCount++;
    } else {
      // Dün yapmamış (ara vermiş) -> Seri 1 olur
      _streakCount = 1;
    }

    _lastStreakDate = todayStr; // Bugünü "Yapıldı" olarak işaretle

    await prefs.setInt('streakCount', _streakCount);
    await prefs.setString('lastStreakDate', _lastStreakDate);
  }
}
