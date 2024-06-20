import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FourCard extends StatefulWidget {
  const FourCard({super.key});
  @override
  State<FourCard> createState() => _FourCardState();
}

class _FourCardState extends State<FourCard> {
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
    var wordProvider4 = Provider.of<WordProvider4>(context, listen: false);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: wordProvider4.wordsListFour[wordProvider4.lastIndex].quest,
      answer: wordProvider4.wordsListFour[wordProvider4.lastIndex].answer,
      lvClass: wordProvider4.wordsListFour[wordProvider4.lastIndex].list,
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
    var wordProvider4 = Provider.of<WordProvider4>(context, listen: false);

    setState(() {
      if (wordProvider4.lastIndex + 1 < wordProvider4.wordsListFour.length) {
        wordProvider4.lastIndex++;
      } else {
        // Eğer son kartta ise ilk karta git
        wordProvider4.lastIndex = 0;
      }
      _showQuestion = true;
      _showAnswer = false;
      wordProvider4.setLastIndex(wordProvider4.lastIndex);
    });
  }

  void _previousCard() {
    var wordProvider4 = Provider.of<WordProvider4>(context, listen: false);

    setState(() {
      if (wordProvider4.lastIndex - 1 >= 0) {
        wordProvider4.lastIndex--;
      } else {
        wordProvider4.lastIndex = wordProvider4.wordsListFour.length - 1;
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
    FlipCardController cardController = FlipCardController();

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordProvider4 = Provider.of<WordProvider4>(context);

    if (wordProvider4.wordsListFour.isEmpty) {
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
        wordProvider4.wordsListFour[wordProvider4.lastIndex].front;
    String targetWord =
        wordProvider4.wordsListFour[wordProvider4.lastIndex].quest;

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
                        wordProvider4
                            .wordsListFour[wordProvider4.lastIndex].quest
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
            const Text(
              'WordCard',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 570.h,
              width: 337.w,
              child: Card(
                color: whites,
                child: Column(
                  children: [
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _speak(wordProvider4
                                .wordsListFour[wordProvider4.lastIndex].quest);
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
                              Future.delayed(const Duration(milliseconds: 500),
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
                                    wordProvider4
                                        .wordsListFour[wordProvider4.lastIndex]
                                        .quest &&
                                item.answer ==
                                    wordProvider4
                                        .wordsListFour[wordProvider4.lastIndex]
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
                            ? wordProvider4
                                .wordsListFour[wordProvider4.lastIndex].quest
                            : wordProvider4
                                .wordsListFour[wordProvider4.lastIndex].answer,
                        style: TextStyle(fontSize: 30.sp, color: orange),
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 55, 150, 111),
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
                              ? wordProvider4
                                  .wordsListFour[wordProvider4.lastIndex].quest
                              : wordProvider4
                                  .wordsListFour[wordProvider4.lastIndex]
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
                        height: 160.h,
                        width: 310.w,
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
                        height: 160.h,
                        width: 310.w,
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
                                '${wordProvider4.wordsListFour[wordProvider4.lastIndex].back} ',
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
                          '680/ ${wordProvider4.wordsListFour.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 65.w),
                        IconButton(
                          onPressed: () {
                            progressProvider.increaseProgress3();
                            if (wordProvider4.wordsListFour.isNotEmpty) {
                              wordProvider4.deleteWord4(
                                  wordProvider4.lastIndex, context);

                              scoreProvider.incrementScore(25);
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
                  height: 40.h,
                  width: 100.w,
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
                  height: 40.h,
                  width: 100.w,
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
