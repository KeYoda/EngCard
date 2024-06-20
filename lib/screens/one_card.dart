import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int index2 = 0;
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
      isIconVisible = prefs.getBool(isIconVisibleKey) ?? true;
    });
  }

  Future<void> _saveIsIconVisible(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isIconVisibleKey, value);
  }

  void _toggleFavorite() {
    var favoriteList = Provider.of<FavoriteList>(context, listen: false);
    var wordProvider = Provider.of<WordProvider>(context, listen: false);

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
      _handleEmptyList();
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
      _handleEmptyList();
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

  void _handleEmptyList() {
    // Navigate back to the previous screen or handle the empty list scenario
    Navigator.pop(context);
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

    if (wordProvider.wordsListOne.isEmpty) {
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
                        wordProvider.wordsListOne[wordProvider.lastIndex].quest
                    ? yellow
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
        value: SystemUiOverlayStyle(systemNavigationBarColor: medgreen),
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
                            _speak(wordProvider
                                .wordsListOne[wordProvider.lastIndex].quest);
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
                              iconColor = Colors.red;
                              _toggleFavorite();
                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                setState(() {
                                  iconColor = easgreen;
                                });
                              });
                            });
                          },
                          icon: const Icon(Icons.favorite),
                          iconSize: 30.w,
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
                    SizedBox(height: 13.h),
                    Center(
                      child: Text(
                        _showQuestion
                            ? wordProvider
                                .wordsListOne[wordProvider.lastIndex].quest
                            : wordProvider
                                .wordsListOne[wordProvider.lastIndex].answer,
                        style: TextStyle(fontSize: 30.sp, color: orange),
                      ),
                    ),
                    SizedBox(height: 35.h),
                    const Divider(
                      color: Color.fromARGB(255, 55, 150, 111),
                      endIndent: 17,
                      indent: 17,
                    ),
                    SizedBox(height: 68.h),
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
                    SizedBox(height: 90.h),
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
                            Center(child: resultWidget),
                            Positioned(
                              right: 8.sp,
                              top: 105.sp,
                              child: Text(
                                '"',
                                style: TextStyle(
                                    fontSize: 19.sp, color: hardgreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                      back: Container(
                        padding: const EdgeInsets.all(30),
                        height: 160.h,
                        width: 310.w,
                        color: whites,
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
                                '${wordProvider.wordsListOne[wordProvider.lastIndex].back} ',
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.black45),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox(height: 20.h)),
                    Divider(endIndent: 17, indent: 17, color: easgreen),
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
                          '400/ ${wordProvider.wordsListOne.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 65.w),
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
                    style: ElevatedButton.styleFrom(backgroundColor: orange),
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
