import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiveCard extends StatefulWidget {
  const FiveCard({super.key});
  @override
  State<FiveCard> createState() => _FiveCardState();
}

class _FiveCardState extends State<FiveCard> {
  FavoriteList favoriteList = FavoriteList();

  FlutterTts flutterTts = FlutterTts();
  bool _showQuestion = true;
  bool _showAnswer = false;
  Color iconColor = easgreen;
  bool isIconVisible = true;

  static const String isIconVisibleKey = 'isIconVisible';

  void changeIcon() {
    setState(() {
      isIconVisible = !isIconVisible;
      _saveIsIconVisible(isIconVisible);
    });
  }

  Future<void> _loadIsIconVisible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // SharedPreferences'ten isIconVisible değerini oku
      isIconVisible = prefs.getBool(isIconVisibleKey) ?? true;
    });
  }

  Future<void> _saveIsIconVisible(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferences'e isIconVisible değerini kaydet
    await prefs.setBool(isIconVisibleKey, value);
  }

  void _toggleFavorite() {
    var favoriteList = Provider.of<FavoriteList>(context, listen: false);
    var wordProvider5 = Provider.of<WordProvider5>(context, listen: false);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: wordProvider5.wordsListFive[wordProvider5.lastIndex].quest,
      answer: wordProvider5.wordsListFive[wordProvider5.lastIndex].answer,
      lvClass: wordProvider5.wordsListFive[wordProvider5.lastIndex].list,
    );

    if (favoriteList.favorites.contains(newFavorite)) {
      favoriteList.deleteFavorite(
        favoriteList.favorites.indexOf(newFavorite),
      );
    } else {
      favoriteList.addFavorite(newFavorite);
    }
    favoriteList.saveFavorites();
  }

  @override
  void initState() {
    super.initState();
    _loadIsIconVisible();
    _initTts();
  }

  void _nextCard() {
    var wordProvider5 = Provider.of<WordProvider5>(context, listen: false);

    setState(() {
      if (wordProvider5.lastIndex + 1 < wordProvider5.wordsListFive.length) {
        wordProvider5.lastIndex++;
      } else {
        // Eğer son kartta ise ilk karta git
        wordProvider5.lastIndex = 0;
      }
      _showQuestion = true;
      _showAnswer = false;
      wordProvider5.setLastIndex(wordProvider5.lastIndex);
    });
  }

  void _previousCard() {
    var wordProvider5 = Provider.of<WordProvider5>(context, listen: false);

    setState(() {
      if (wordProvider5.lastIndex - 1 >= 0) {
        wordProvider5.lastIndex--;
      } else {
        wordProvider5.lastIndex = wordProvider5.wordsListFive.length - 1;
      }
      _showQuestion = true;
      _showAnswer = false;
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtil().screenWidth;
    double screenHeight = ScreenUtil().screenHeight;

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordProvider5 = Provider.of<WordProvider5>(context);

    FlipCardController cardController = FlipCardController();

    String fullText =
        wordProvider5.wordsListFive[wordProvider5.lastIndex].front;
    String targetWord =
        wordProvider5.wordsListFive[wordProvider5.lastIndex].quest;

    int startIndex = fullText.indexOf(targetWord);

    Widget resultWidget;

    if (startIndex != -1) {
      resultWidget = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: fullText.substring(0, startIndex),
              style: const TextStyle(fontSize: 15, color: Colors.black45),
            ),
            TextSpan(
              text: targetWord,
              style: TextStyle(
                fontSize: 16,
                color: yellow,
              ),
            ),
            TextSpan(
              text: fullText.substring(startIndex + targetWord.length),
              style: const TextStyle(fontSize: 15, color: Colors.black45),
            ),
          ],
        ),
        maxLines: 3,
      );
    } else {
      // Hedef kelime bulunamadı, bu durumu kontrol etmek için bir işlem yapabilirsiniz.
      // Örneğin, tüm metni aynı renkte göster veya başka bir işlem gerçekleştir.
      resultWidget = Center(
        child: Text(
          fullText,
          style: const TextStyle(fontSize: 15, color: Colors.black45),
          maxLines: 3,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 104, 89),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'KeYoda',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: screenHeight * 0.8,
            width: screenWidth * 0.93,
            child: Card(
              color: whites,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _speak(wordProvider5
                              .wordsListFive[wordProvider5.lastIndex].quest);
                        },
                        icon: Icon(
                          Icons.settings_voice_rounded,
                          color: orange,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.6),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            iconColor = Colors.red; // Kırmızıya geçiş
                            _toggleFavorite(); // Favoriye ekleme/çıkarma işlemi
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              setState(() {
                                iconColor = easgreen; // Beyaza geri dön
                              });
                            });
                          });
                        },
                        icon: const Icon(Icons.favorite),
                        iconSize: 30.sp,
                        color: favoriteList.favorites.any(
                          (item) =>
                              item.question ==
                                  wordProvider5
                                      .wordsListFive[wordProvider5.lastIndex]
                                      .quest &&
                              item.answer ==
                                  wordProvider5
                                      .wordsListFive[wordProvider5.lastIndex]
                                      .answer,
                        )
                            ? easgreen
                            : iconColor,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Center(
                    child: Text(
                      _showQuestion
                          ? wordProvider5
                              .wordsListFive[wordProvider5.lastIndex].quest
                          : wordProvider5
                              .wordsListFive[wordProvider5.lastIndex].answer,
                      style: TextStyle(fontSize: 30.sp, color: orange),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.06,
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 55, 150, 111),
                    endIndent: 17,
                    indent: 17,
                  ),
                  SizedBox(
                    height: screenHeight * 0.08,
                  ),
                  SizedBox(
                    height: isIconVisible ? null : 29.sp,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isIconVisible ? 1.0 : 0.0,
                      child: Text(
                        _showAnswer
                            ? wordProvider5
                                .wordsListFive[wordProvider5.lastIndex].quest
                            : wordProvider5
                                .wordsListFive[wordProvider5.lastIndex].answer,
                        style: TextStyle(color: orange, fontSize: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 85.sp,
                  ),
                  FlipCard(
                    controller: cardController,
                    speed: 500,
                    front: Container(
                      padding: const EdgeInsets.all(30),
                      color: whites,
                      height: 180.sp,
                      width: 310.sp,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 91.sp,
                            child: Text(
                              '"',
                              style:
                                  TextStyle(fontSize: 25.sp, color: hardgreen),
                            ),
                          ),
                          Center(
                            child: resultWidget,
                          ),
                          Positioned(
                            right: 8.sp,
                            top: 105.sp,
                            child: Text(
                              '"',
                              style:
                                  TextStyle(fontSize: 25.sp, color: hardgreen),
                            ),
                          )
                        ],
                      ),
                    ),
                    back: Container(
                      padding: const EdgeInsets.all(30),
                      color: whites,
                      height: 180.sp,
                      width: 310.sp,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 91.sp,
                            child: Text(
                              '"',
                              style:
                                  TextStyle(fontSize: 25.sp, color: hardgreen),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${wordProvider5.wordsListFive[wordProvider5.lastIndex].back} ',
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8.sp,
                            top: 105.sp,
                            child: Text(
                              '"',
                              style:
                                  TextStyle(fontSize: 25.sp, color: hardgreen),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(height: screenHeight * 0.23.sp),
                  ),
                  Divider(
                    endIndent: 17,
                    indent: 17,
                    color: easgreen,
                  ),
                  Row(
                    children: [
                      SizedBox(width: screenWidth * 0.03),
                      IconButton(
                        onPressed: () {
                          changeIcon();
                          _saveIsIconVisible(isIconVisible);
                        },
                        icon: isIconVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                      SizedBox(width: screenWidth * 0.22),
                      Text(
                        '1194/ ${wordProvider5.wordsListFive.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: screenWidth * 0.18),
                      IconButton(
                        onPressed: () {
                          progressProvider.increaseProgress4();
                          if (wordProvider5.wordsListFive.isNotEmpty) {
                            wordProvider5.deleteWord5(
                                wordProvider5.lastIndex, context);

                            scoreProvider.incrementScore(30);
                          } else {
                            const SnackBar(
                              content: Text('Congrats'),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.check_circle,
                          color: easgreen,
                          size: 36.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
                  onPressed: _previousCard,
                  child: Icon(
                    Icons.arrow_circle_left_outlined,
                    color: whites,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                  ),
                  onPressed: _nextCard,
                  child: Icon(Icons.arrow_circle_right_outlined, color: whites),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
