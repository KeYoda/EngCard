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

class PracticeCard extends StatefulWidget {
  const PracticeCard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FavouriteGrid();
  }
}

class _FavouriteGrid extends State<PracticeCard> {
  List<Words> combinedList = [];

  @override
  void initState() {
    super.initState();
    combinedList.addAll(wordsList);
    combinedList.addAll(wordsList2);
    combinedList.addAll(wordsList3);
    combinedList.addAll(wordsList4);
    combinedList.addAll(wordsList5);
    combinedList.shuffle();
  }

  void _shuffleCards() {
    setState(() {
      combinedList.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: whites,
        title: Text(
          'Alıştırma',
          style: TextStyle(color: medgreen),
        ),
        centerTitle: true,
      ),
      backgroundColor: whites,
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: GridView.count(
                key: ValueKey<int>(combinedList.length),
                mainAxisSpacing: 0,
                padding: const EdgeInsets.only(top: 6),
                crossAxisCount: 3,
                children: List.generate(
                  15,
                  (index) {
                    final Color color =
                        _getColorForLevel(combinedList[index].list);
                    final FlipCardController _flipCardController =
                        FlipCardController();
                    return Stack(
                      children: [
                        GestureDetector(
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
                                    style: TextStyle(
                                      color: whites,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                child: Text(
                                  combinedList[index].answer,
                                  style: TextStyle(
                                      color: whites.withOpacity(0.8),
                                      fontWeight: FontWeight.bold),
                                ),
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
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: IconButton(
              onPressed: _shuffleCards,
              icon: const Icon(Icons.restart_alt),
              iconSize: 37,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getColorForLevel(String level) {
  switch (level) {
    case 'B2':
      return const Color.fromARGB(255, 181, 131, 141);
    case 'C1':
      return const Color.fromARGB(255, 109, 104, 117);
    case 'B1':
      return const Color.fromARGB(255, 229, 152, 155);
    case 'A2':
      return const Color.fromARGB(255, 255, 180, 162);
    case 'A1':
      return const Color.fromARGB(255, 255, 205, 178);
    default:
      return const Color.fromARGB(255, 165, 112, 112); // Varsayılan renk
  }
}
