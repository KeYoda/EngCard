import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThreCard extends StatefulWidget {
  const ThreCard({super.key});
  @override
  State<ThreCard> createState() => _ThreCardState();
}

class _ThreCardState extends State<ThreCard> {
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
    var wordProvider3 = Provider.of<WordProvider3>(context, listen: false);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: wordProvider3.wordsListThre[wordProvider3.lastIndex].quest,
      answer: wordProvider3.wordsListThre[wordProvider3.lastIndex].answer,
      lvClass: wordProvider3.wordsListThre[wordProvider3.lastIndex].list,
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
    var wordProvider3 = Provider.of<WordProvider3>(context, listen: false);

    setState(() {
      if (wordProvider3.lastIndex + 1 < wordProvider3.wordsListThre.length) {
        wordProvider3.lastIndex++;
      } else {
        // Eğer son kartta ise ilk karta git
        wordProvider3.lastIndex = 0;
      }
      _showQuestion = true;
      _showAnswer = false;
      wordProvider3.setLastIndex(wordProvider3.lastIndex);
    });
  }

  void _previousCard() {
    var wordProvider3 = Provider.of<WordProvider3>(context, listen: false);

    setState(() {
      if (wordProvider3.lastIndex - 1 >= 0) {
        wordProvider3.lastIndex--;
      } else {
        wordProvider3.lastIndex = wordProvider3.wordsListThre.length - 1;
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

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordProvider3 = Provider.of<WordProvider3>(context);

    FlipCardController cardController = FlipCardController();

    if (wordProvider3.wordsListThre.isEmpty) {
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
        wordProvider3.wordsListThre[wordProvider3.lastIndex].front;
    String targetWord =
        wordProvider3.wordsListThre[wordProvider3.lastIndex].quest;

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
                        wordProvider3
                            .wordsListThre[wordProvider3.lastIndex].quest
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
            systemNavigationBarColor: medgreen // İkonların rengi
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
                            _speak(wordProvider3
                                .wordsListThre[wordProvider3.lastIndex].quest);
                          },
                          icon: Icon(
                            Icons.settings_voice_rounded,
                            color: orange,
                          ),
                        ),
                        SizedBox(width: 223.w),
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
                                    wordProvider3
                                        .wordsListThre[wordProvider3.lastIndex]
                                        .quest &&
                                item.answer ==
                                    wordProvider3
                                        .wordsListThre[wordProvider3.lastIndex]
                                        .answer,
                          )
                              ? easgreen
                              : iconColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 13.h),
                    Center(
                      child: Text(
                        _showQuestion
                            ? wordProvider3
                                .wordsListThre[wordProvider3.lastIndex].quest
                            : wordProvider3
                                .wordsListThre[wordProvider3.lastIndex].answer,
                        style: TextStyle(fontSize: 30.sp, color: orange),
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    Divider(
                      color: easgreen,
                      endIndent: 17,
                      indent: 17,
                    ),
                    SizedBox(
                      height: 68.h,
                    ),
                    SizedBox(
                      height: isIconVisible ? null : 29.sp,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isIconVisible ? 1.0 : 0.0,
                        child: Text(
                          _showAnswer
                              ? wordProvider3
                                  .wordsListThre[wordProvider3.lastIndex].quest
                              : wordProvider3
                                  .wordsListThre[wordProvider3.lastIndex]
                                  .answer,
                          style: TextStyle(color: orange, fontSize: 20.sp),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 90.h,
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
                                '${wordProvider3.wordsListThre[wordProvider3.lastIndex].back} ',
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
                      child: SizedBox(height: 20.h),
                    ),
                    Divider(
                      endIndent: 17,
                      indent: 17,
                      color: easgreen,
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10.w),
                        IconButton(
                          onPressed: () {
                            changeIcon();
                            _saveIsIconVisible(isIconVisible);
                          },
                          icon: isIconVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                        SizedBox(width: 80.w),
                        Text(
                          '765/ ${wordProvider3.wordsListThre.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 65.w),
                        IconButton(
                          onPressed: () {
                            progressProvider.increaseProgress2();
                            if (wordProvider3.wordsListThre.isNotEmpty) {
                              wordProvider3.deleteWord3(
                                  wordProvider3.lastIndex, context);

                              scoreProvider.incrementScore(20);
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
            SizedBox(height: 15.h),
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
