import 'package:eng_card/data/gridview.dart';
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

class FiveCard extends StatefulWidget {
  const FiveCard({super.key, required this.level});
  final String level;
  @override
  State<FiveCard> createState() => _FiveCardState();
}

class _FiveCardState extends State<FiveCard> {
  FlutterTts flutterTts = FlutterTts();
  FavoriteList favoriteList = FavoriteList();

  bool _showQuestion = true;
  bool _showAnswer = false;
  bool isIconVisible = true;
  Color iconColor = easgreen;
  static const String isIconVisibleKey = 'isIconVisible';
  void changeIcon() {
    setState(() {
      isIconVisible = !isIconVisible;
      _saveIsIconVisible(isIconVisible);
    });
  }

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

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _nextCard(WordProvider wordProvider) {
    List<Words> words = wordProvider.getWords(widget.level);

    if (words.isEmpty) {
      _handleEmptyList();
      return;
    }

    int currentIndex = wordProvider.getLastIndex(widget.level);
    int newIndex = (currentIndex + 1) % words.length;

    wordProvider.setLastIndex(widget.level, newIndex);

    setState(() {
      _showQuestion = true;
      _showAnswer = false;
    });
  }

  void _previousCard(WordProvider wordProvider) {
    List<Words> words = wordProvider.getWords(widget.level);

    if (words.isEmpty) {
      _handleEmptyList();
      return;
    }

    int currentIndex = wordProvider.getLastIndex(widget.level);
    int newIndex = (currentIndex - 1 + words.length) % words.length;

    wordProvider.setLastIndex(widget.level, newIndex);

    setState(() {
      _showQuestion = true;
      _showAnswer = false;
    });
  }

  void _toggleFavorite() {
    var favoriteList = Provider.of<FavoriteList>(context, listen: false);
    var wordProvider2 = Provider.of<WordProvider>(context, listen: false);
    var oneWords = wordProvider2.getWords(widget.level);
    int index = wordProvider2.getLastIndex(widget.level);

    // Favori listesine eklemek ya da çıkarmak için gerekli işlemler burada yapılabilir
    // Örneğin:
    SavedItem newFavorite = SavedItem(
      question: oneWords[index].quest,
      answer: oneWords[index].answer,
      lvClass: oneWords[index].list,
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

  void _handleEmptyList() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var wordProvider = Provider.of<WordProvider>(context);
    List<Words> words = wordProvider.getWords(widget.level);
    FlipCardController cardController = FlipCardController();
    int index = wordProvider.getLastIndex(widget.level);

    if (index >= words.length) {
      index = 0;
      wordProvider.setLastIndex(widget.level, 0);

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

    Words currentWord = words[index];

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);

    String fullText = currentWord.front;
    String targetWord = currentWord.quest;
    int startIndex = fullText.indexOf(targetWord);

    Widget resultWidget;

    if (startIndex != -1) {
      resultWidget = Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
                text: fullText.substring(0, startIndex),
                style: TextStyle(fontSize: 11.sp, color: Colors.black45)),
            TextSpan(
                text: targetWord,
                style: TextStyle(fontSize: 12.sp, color: yellow)),
            TextSpan(
                text: fullText.substring(startIndex + targetWord.length),
                style: TextStyle(fontSize: 11.sp, color: Colors.black45)),
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
                            _speak(words[index].quest);
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
                                item.question == words[index].quest &&
                                item.answer == words[index].answer,
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
                            ? words[index].quest
                            : words[index].answer,
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
                              ? words[index].quest
                              : words[index].answer,
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
                                '${words[index].back} ',
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
                          '1170/ ${words.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 65.w),
                        IconButton(
                          onPressed: () {
                            progressProvider.increaseProgress4();
                            if (words.isNotEmpty) {
                              wordProvider.deleteWord('C1', index, context);

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
                    onPressed: () {
                      _previousCard(wordProvider);
                    },
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
                    onPressed: () {
                      _nextCard(wordProvider);
                    },
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
