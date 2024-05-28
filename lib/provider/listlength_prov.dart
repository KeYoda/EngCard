// import 'package:eng_card/data/gridview.dart';
// import 'package:eng_card/data/save_words.dart';
// import 'package:flutter/material.dart';

// class UserActionsProvider extends ChangeNotifier {
//   List<SavedItem> favorites = [];
//   List<int> shownIndices = [];

//   void toggleFavorite(int currentIndex, List<Words> cardContents) {
//     SavedItem currentItem = SavedItem(
//       question: cardContents[currentIndex].quest,
//       answer: cardContents[currentIndex].answer,
//       lvClass: cardContents[currentIndex].list,
//     );

//     if (favorites.contains(currentItem)) {
//       favorites.remove(currentItem);
//     } else {
//       favorites.add(currentItem);
//       shownIndices.add(currentIndex);
//     }

//     notifyListeners();
//   }

//   void deleteCard(int currentIndex, List<Words> wordsList) {
//     if (wordsList.isNotEmpty) {
//       wordsList.removeAt(currentIndex);
//       shownIndices.remove(currentIndex);

//       if (currentIndex >= wordsList.length) {
//         currentIndex = wordsList.length - 1;
//       }

//       notifyListeners();
//     }
//   }
// }
