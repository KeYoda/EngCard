import 'package:eng_card/data/save_words.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList extends ChangeNotifier {
  List<SavedItem> favorites = [];

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? favoriteQuestions = prefs.getStringList('favoriteQuestions');
    List<String>? favoriteAnswers = prefs.getStringList('favoriteAnswers');
    List<String>? favoriteLvClass = prefs.getStringList('favoriteLvClass');

    favorites.clear();

    if (favoriteQuestions != null &&
        favoriteAnswers != null &&
        favoriteLvClass != null &&
        favoriteQuestions.length == favoriteAnswers.length &&
        favoriteQuestions.length == favoriteLvClass.length) {
      for (int i = 0; i < favoriteQuestions.length; i++) {
        SavedItem favoriteItem = SavedItem(
          question: favoriteQuestions[i],
          answer: favoriteAnswers[i],
          lvClass: favoriteLvClass[i],
        );
        favorites.add(favoriteItem);
      }
    }
    notifyListeners();
  }

  Future<void> addFavorite(SavedItem favoriteItem) async {
    favorites.add(favoriteItem);
    await saveFavorites();
    notifyListeners();
  }

  void deleteFavorite(int index) {
    if (favorites.isNotEmpty && index >= 0 && index < favorites.length) {
      favorites.removeAt(index);

      // Update the index to ensure it stays within bounds after removal
      if (index == favorites.length) {
        index--;
      }

      // Save the favorites after deletion
      saveFavorites();
      notifyListeners();
    }
  }

  Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteQuestions =
        favorites.map((item) => item.question).toList();
    List<String> favoriteAnswers =
        favorites.map((item) => item.answer).toList();
    List<String> favoriteLvClass =
        favorites.map((item) => item.lvClass).toList();

    await prefs.setStringList('favoriteQuestions', favoriteQuestions);
    await prefs.setStringList('favoriteAnswers', favoriteAnswers);
    await prefs.setStringList('favoriteLvClass', favoriteLvClass);
  }
}
