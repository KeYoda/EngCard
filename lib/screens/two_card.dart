import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoCard extends StatefulWidget {
  const TwoCard({super.key});
  @override
  State<TwoCard> createState() => _TwoCardState();
}

class _TwoCardState extends State<TwoCard> {
  FavoriteList favoriteList = FavoriteList();

  int currentIndex = 0;

  FlutterTts flutterTts = FlutterTts();
  bool _showQuestion = true;
  bool isIconVisible = true;
  bool _showAnswer = false;
  Color iconColor = easgreen;

  static const String isIconVisibleKey = 'isIconVisible';

  void changeIcon() {
    setState(() {
      isIconVisible = !isIconVisible;
      _saveIsIconVisible(isIconVisible);
    });
  }

  void _toggleFavorite() {
    var favoriteList = Provider.of<FavoriteList>(context, listen: false);
    var wordProvider2 = Provider.of<WordProvider2>(context, listen: false);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: wordProvider2.wordsListTwo[wordProvider2.lastIndex2].quest,
      answer: wordProvider2.wordsListTwo[wordProvider2.lastIndex2].answer,
      lvClass: wordProvider2.wordsListTwo[wordProvider2.lastIndex2].list,
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

  @override
  void initState() {
    super.initState();
    _loadIsIconVisible();
    _initTts();
  }

  void _nextCard() {
    var wordProvider2 = Provider.of<WordProvider2>(context, listen: false);

    setState(() {
      if (wordProvider2.lastIndex2 + 1 < wordProvider2.wordsListTwo.length) {
        wordProvider2.lastIndex2++;
      } else {
        // Eğer son kartta ise ilk karta git
        wordProvider2.lastIndex2 = 0;
      }
      _showQuestion = true;
      _showAnswer = false;
      wordProvider2.setLastIndex(wordProvider2.lastIndex2);
    });
  }

  void _previousCard() {
    var wordProvider2 = Provider.of<WordProvider2>(context, listen: false);

    setState(() {
      if (wordProvider2.lastIndex2 - 1 >= 0) {
        wordProvider2.lastIndex2--;
      } else {
        wordProvider2.lastIndex2 = wordProvider2.wordsListTwo.length - 1;
      }
      _showQuestion = true;
      _showAnswer = false;
      wordProvider2.setLastIndex(wordProvider2.lastIndex2);
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
    var wordProvider2 = Provider.of<WordProvider2>(context);

    if (wordProvider2.wordsListTwo.isEmpty) {
      return Scaffold(
        backgroundColor: medgreen,
        body: Center(
          child: Text(
            'Tüm kelimeler tamamlandı!',
            style: TextStyle(fontSize: 24.sp, color: Colors.white),
          ),
        ),
      );
    }

    String fullText =
        wordProvider2.wordsListTwo[wordProvider2.lastIndex2].front;
    String targetWord =
        wordProvider2.wordsListTwo[wordProvider2.lastIndex2].quest;

    int startIndex = fullText.indexOf(targetWord);

    Widget resultWidget;

    if (startIndex != -1) {
      resultWidget = Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: fullText.substring(0, startIndex),
              style: TextStyle(fontSize: 11.sp, color: Colors.black45),
            ),
            TextSpan(
              text: targetWord,
              style: TextStyle(
                fontSize: 12.sp,
                color: targetWord ==
                        wordProvider2
                            .wordsListTwo[wordProvider2.lastIndex2].quest
                    ? yellow // Renk quest kelimesine göre değişecek
                    : Colors.black45,
              ),
            ),
            TextSpan(
              text: fullText.substring(startIndex + targetWord.length),
              style: TextStyle(fontSize: 11.sp, color: Colors.black45),
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
          style: TextStyle(fontSize: 12.sp, color: Colors.black45),
          maxLines: 3,
        ),
      );
    }

    return Scaffold(
      backgroundColor: medgreen,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: medgreen, // Bu ekran için farklı bir renk
          // İkonların rengi
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 18.h),
            Text(
              'WordCard',
              style: TextStyle(color: whites),
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
                            _speak(wordProvider2
                                .wordsListTwo[wordProvider2.lastIndex2].quest);
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
                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                setState(() {
                                  iconColor = easgreen; // Beyaza geri dön
                                });
                              });
                            });
                          },
                          icon: const Icon(Icons.favorite),
                          iconSize: 30.w,
                          color: favoriteList.favorites.any(
                            (item) =>
                                item.question ==
                                    wordProvider2
                                        .wordsListTwo[wordProvider2.lastIndex2]
                                        .quest &&
                                item.answer ==
                                    wordProvider2
                                        .wordsListTwo[wordProvider2.lastIndex2]
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
                            ? wordProvider2
                                .wordsListTwo[wordProvider2.lastIndex2].quest
                            : wordProvider2
                                .wordsListTwo[wordProvider2.lastIndex2].answer,
                        style: TextStyle(fontSize: 30.sp, color: orange),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(35),
                    ),
                    Divider(
                      color: easgreen,
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
                              ? wordProvider2
                                  .wordsListTwo[wordProvider2.lastIndex2].quest
                              : wordProvider2
                                  .wordsListTwo[wordProvider2.lastIndex2]
                                  .answer,
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
                        height: ScreenUtil().setHeight(160),
                        width: ScreenUtil().setWidth(310),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 91.sp,
                              child: Text(
                                '"',
                                style: TextStyle(
                                    fontSize: 19.sp, color: hardgreen),
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
                                    fontSize: 19.sp, color: hardgreen),
                              ),
                            )
                          ],
                        ),
                      ),
                      back: Container(
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
                                    fontSize: 19.sp, color: hardgreen),
                              ),
                            ),
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                '${wordProvider2.wordsListTwo[wordProvider2.lastIndex2].back} ',
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 11.sp,
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
                                    fontSize: 19.sp, color: hardgreen),
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
                          '465/ ${wordProvider2.wordsListTwo.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(65)),
                        IconButton(
                          onPressed: () {
                            progressProvider.increaseProgress1();
                            if (wordProvider2.wordsListTwo.isNotEmpty) {
                              wordProvider2.deleteWord2(
                                  wordProvider2.lastIndex2, context);

                              scoreProvider.incrementScore(15);
                            } else {
                              const SnackBar(
                                content: Text('Congrats'),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.check_circle,
                            color: easgreen,
                            size: 36.w,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                    ),
                    onPressed: _nextCard,
                    child:
                        Icon(Icons.arrow_circle_right_outlined, color: whites),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
