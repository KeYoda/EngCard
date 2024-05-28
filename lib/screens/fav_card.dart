import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FavouriteGrid();
  }
}

class _FavouriteGrid extends State<FavouritePage> {
  List<Words> combinedList = [];

  @override
  Widget build(BuildContext context) {
    combinedList.addAll(wordsList);
    combinedList.addAll(wordsList2);
    combinedList.addAll(wordsList3);
    combinedList.addAll(wordsList4);
    combinedList.addAll(wordsList5);
    combinedList.shuffle();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: medgreen,
        title: const Text(
          'Alıştırma',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      backgroundColor: whites,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Animasyon süresi
        child: GridView.count(
          key: ValueKey<int>(combinedList.length),
          mainAxisSpacing: 6,
          crossAxisCount: 3,
          children: List.generate(
            15,
            (index) {
              final Color color = _getColorForLevel(combinedList[index].list);
              final FlipCardController _flipCardController =
                  FlipCardController();
              return Stack(
                children: [
                  GestureDetector(
                    // onDoubleTap: () {
                    //   setState(() {});
                    // },
                    child: FlipCard(
                      speed: 400,
                      controller: _flipCardController,
                      front: Card(
                        color: color,
                        child: Column(
                          children: [
                            const SizedBox(height: 46),
                            Text(
                              combinedList[index].quest,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                const SizedBox(width: 96),
                                Text(
                                  combinedList[index].list,
                                  style: TextStyle(
                                    color: orange,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      back: Card(
                        color: Colors.black26,
                        child: Center(
                          child: Text(combinedList[index].answer),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Color _getColorForLevel(String level) {
  switch (level) {
    case 'A1':
      return Colors.blueGrey.shade200;
    case 'A2':
      return Colors.yellow.shade200;
    case 'B1':
      return Colors.lightBlue.shade100;
    case 'B2':
      return Colors.orange.shade200;
    case 'C1':
      return Colors.red.shade100;
    default:
      return Colors.white; // Varsayılan renk
  }
}
