import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneCard extends StatefulWidget {
  const OneCard({super.key});
  @override
  State<OneCard> createState() => _OneCardState();
}

class _OneCardState extends State<OneCard> {
  FavoriteList favoriteList = FavoriteList();

  FlutterTts flutterTts = FlutterTts();
  bool _showQuestion = true;
  bool isIconVisible = true;
  bool _showAnswer = false;
  Color iconColor = easgreen;

  static const String isIconVisibleKey = 'isIconVisible';

  @override
  void initState() {
    super.initState();
    _loadIsIconVisible();
    _initTts();
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
    var wordProvider = Provider.of<WordProvider>(context, listen: false);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: wordProvider.wordsListOne[wordProvider.lastIndex].quest,
      answer: wordProvider.wordsListOne[wordProvider.lastIndex].answer,
      lvClass: wordProvider.wordsListOne[wordProvider.lastIndex].list,
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

  void _nextCard() {
    var wordProvider = Provider.of<WordProvider>(context, listen: false);

    if (wordProvider.wordsListOne.isEmpty) {
      return;
    }

    setState(() {
      if (wordProvider.lastIndex + 1 < wordProvider.wordsListOne.length) {
        wordProvider.lastIndex++;
      } else {
        wordProvider.lastIndex = 0;
      }
      _showQuestion = true;
      _showAnswer = false;
    });
  }

  void _previousCard() {
    var wordProvider = Provider.of<WordProvider>(context, listen: false);

    if (wordProvider.wordsListOne.isEmpty) {
      return;
    }

    setState(() {
      if (wordProvider.lastIndex - 1 >= 0) {
        wordProvider.lastIndex--;
      } else {
        wordProvider.lastIndex = wordProvider.wordsListOne.length - 1;
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
    ScreenUtil.init(context);

    FlipCardController cardController = FlipCardController();

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordProvider = Provider.of<WordProvider>(context);

    String fullText = wordProvider.wordsListOne[wordProvider.lastIndex].front;
    String targetWord = wordProvider.wordsListOne[wordProvider.lastIndex].quest;

    int startIndex = fullText.indexOf(targetWord);

    void changeIcon() {
      setState(() {
        isIconVisible = !isIconVisible;
        _saveIsIconVisible(isIconVisible);
      });
    }

    Widget resultWidget;

    if (startIndex != -1) {
      resultWidget = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: fullText.substring(0, startIndex),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(11), color: Colors.black45),
            ),
            TextSpan(
              text: targetWord,
              style: TextStyle(
                fontSize: 12.sp,
                color: yellow,
              ),
            ),
            TextSpan(
              text: fullText.substring(startIndex + targetWord.length),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(11), color: Colors.black45),
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
          style: TextStyle(
              fontSize: ScreenUtil().setSp(12), color: Colors.black45),
          maxLines: 3,
        ),
      );
    }
    return Scaffold(
      backgroundColor: medgreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'OneWord',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(570),
            width: ScreenUtil().setWidth(337),
            child: Card(
              color: whites,
              child: Column(
                children: [
                  SizedBox(height: ScreenUtil().setHeight(7)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _speak(wordProvider
                              .wordsListOne[wordProvider.lastIndex].quest);
                        },
                        icon: Icon(
                          Icons.settings_voice_rounded,
                          color: orange,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(223)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            iconColor = Colors.red; // Kırmızıya geçiş
                            _toggleFavorite(); // Favoriye ekleme/çıkarma işlemi

                            // Eğer işlem başarılıysa, belirli bir süre sonra eski rengine geri dön
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              setState(() {
                                iconColor = easgreen; // Beyaza geri dön
                              });
                            });
                          });
                        },
                        icon: const Icon(Icons.favorite),
                        iconSize: ScreenUtil().setWidth(30),
                        color: favoriteList.favorites.any(
                          (item) =>
                              item.question ==
                                  wordProvider
                                      .wordsListOne[wordProvider.lastIndex]
                                      .quest &&
                              item.answer ==
                                  wordProvider
                                      .wordsListOne[wordProvider.lastIndex]
                                      .answer,
                        )
                            ? easgreen
                            : iconColor,
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(13)),
                  Center(
                    child: Text(
                      _showQuestion
                          ? wordProvider
                              .wordsListOne[wordProvider.lastIndex].quest
                          : wordProvider
                              .wordsListOne[wordProvider.lastIndex].answer,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30), color: orange),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 55, 150, 111),
                    endIndent: 17,
                    indent: 17,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(68),
                  ),
                  SizedBox(
                    height: isIconVisible ? null : 29.sp,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isIconVisible ? 1.0 : 0.0,
                      child: Text(
                        _showAnswer
                            ? wordProvider
                                .wordsListOne[wordProvider.lastIndex].quest
                            : wordProvider
                                .wordsListOne[wordProvider.lastIndex].answer,
                        style: TextStyle(color: orange, fontSize: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(90),
                  ),
                  FlipCard(
                    controller: cardController,
                    speed: 500,
                    front: Container(
                      padding: const EdgeInsets.all(30),
                      color: whites,
                      height: ScreenUtil().setHeight(160),
                      width: ScreenUtil().setWidth(310),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 91.sp,
                            child: Text(
                              '"',
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(19),
                                  color: hardgreen),
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
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(19),
                                  color: hardgreen),
                            ),
                          )
                        ],
                      ),
                    ),
                    back: Container(
                      padding: const EdgeInsets.all(30),
                      height: ScreenUtil().setHeight(160),
                      width: ScreenUtil().setWidth(310),
                      color: whites,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 91.sp,
                            child: Text(
                              '"',
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(19),
                                  color: hardgreen),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${wordProvider.wordsListOne[wordProvider.lastIndex].back} ',
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(11),
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8.sp,
                            top: 105.sp,
                            child: Text(
                              '"',
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(19),
                                  color: hardgreen),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(height: ScreenUtil().setHeight(20)),
                  ),
                  Divider(
                    endIndent: 17,
                    indent: 17,
                    color: easgreen,
                  ),
                  Row(
                    children: [
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      IconButton(
                        onPressed: () {
                          changeIcon();
                          _saveIsIconVisible(isIconVisible);
                        },
                        icon: isIconVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(80)),
                      Text(
                        '384/ ${wordProvider.wordsListOne.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(65)),
                      IconButton(
                        onPressed: () {
                          progressProvider.increaseProgress();
                          if (wordProvider.wordsListOne.isNotEmpty) {
                            wordProvider.deleteWord(
                                wordProvider.lastIndex, context);

                            scoreProvider.incrementScore(10);
                          } else {
                            const SnackBar(
                              content: Text('Congrats'),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.check_circle,
                          color: easgreen,
                          size: ScreenUtil().setWidth(36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                height: ScreenUtil().setHeight(40),
                width: ScreenUtil().setWidth(100),
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
                height: ScreenUtil().setHeight(40),
                width: ScreenUtil().setWidth(100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
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
