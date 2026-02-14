import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/streak_prov.dart'; // EKLENDİ
import 'package:eng_card/widgets/floating_score.dart'; // EKLENDİ
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCardScreen extends StatefulWidget {
  final String level;

  const FlashCardScreen({super.key, required this.level});

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  List<Words> shuffledWords = [];
  FlutterTts flutterTts = FlutterTts();
  final CardSwiperController controller = CardSwiperController();
  final GlobalKey<FloatingScoreOverlayState> _scoreKey =
      GlobalKey<FloatingScoreOverlayState>();

  // --- RENK PALETİ ---
  final Color bgGradientStart = const Color(0xFF0F2027);
  final Color bgGradientEnd = const Color(0xFF203A43);
  final Color cardBg = Colors.white;
  final Color accentColor = const Color(0xFFFF9F1C);
  final Color highlightColor = const Color(0xFFFFBF69);
  final Color textColorMain = const Color(0xFF2EC4B6);
  final Color textColorSub = const Color(0xFF2C3E50);

  bool isIconVisible = false;
  static const String isIconVisibleKey = 'isIconVisible';
  bool isInitialized = false;

  // --- SERİ KONTROL DEĞİŞKENİ ---
  bool _hasStreakIncreasedSession = false;

  @override
  void initState() {
    super.initState();
    _loadIsIconVisible();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wordProvider = Provider.of<WordProvider>(context, listen: false);
      final originalWords = wordProvider.getWords(widget.level);

      setState(() {
        shuffledWords = List.from(originalWords);
        shuffledWords.shuffle();
        isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadIsIconVisible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isIconVisible = prefs.getBool(isIconVisibleKey) ?? false;
      });
    }
  }

  Future<void> _saveIsIconVisible(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isIconVisibleKey, value);
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  int _getFixedTotalCount(String level) {
    return wordsListOne.where((element) => element.list == level).length;
  }

  // --- SWIPE MANTIĞI ---
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    WordProvider wordProvider,
    ProgressProvider progressProvider,
    ScoreProvider scoreProvider,
    StreakProvider streakProvider,
    List<Words> localList,
  ) {
    if (direction == CardSwiperDirection.right) {
      scoreProvider.incrementScore(10);
      progressProvider.increaseLinearProgress(widget.level);

      // --- SAYAÇ VE HEDEF KONTROLÜ (DÜZELTİLDİ) ---
      // Şu anki sayaç 9 ise ve hedef 10 ise, bu işlemle 10 olacak demektir.
      // Bu yüzden arttırmadan ÖNCE kontrol ediyoruz.
      if (streakProvider.dailyCount == 9) {
        _hasStreakIncreasedSession = true;
      }

      streakProvider.incrementDailyProgress();
      // -------------------------------------------

      // Animasyonu Tetikle
      _scoreKey.currentState?.showScore(
        position: Offset(MediaQuery.of(context).size.width / 2 - 30,
            MediaQuery.of(context).size.height / 2 - 100),
        points: 10,
      );

      // Listeden silme işlemi
      Future.delayed(Duration.zero, () {
        if (mounted && localList.isNotEmpty) {
          wordProvider.deleteWord(widget.level, 0, context);
          setState(() {
            shuffledWords.removeAt(0);
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      Future.delayed(Duration.zero, () {
        if (mounted && localList.isNotEmpty) {
          wordProvider.sendToBack(widget.level, 0);
          setState(() {
            Words movedWord = shuffledWords.removeAt(0);
            shuffledWords.add(movedWord);
          });
        }
      });
    }
    return true;
  }

  void _toggleFavorite(WordProvider wordProvider, List<Words> words) {
    if (words.isEmpty) return;
    var favoriteList = Provider.of<FavoriteList>(context, listen: false);
    Words currentWord = words[0];

    SavedItem newFavorite = SavedItem(
      question: currentWord.quest,
      answer: currentWord.answer,
      lvClass: currentWord.list,
    );

    if (favoriteList.favorites.contains(newFavorite)) {
      favoriteList.deleteFavorite(favoriteList.favorites.indexOf(newFavorite));
    } else {
      favoriteList.addFavorite(newFavorite);
    }
    favoriteList.saveFavorites();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var wordProvider = Provider.of<WordProvider>(context);
    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var streakProvider = Provider.of<StreakProvider>(context);
    var favoriteList = Provider.of<FavoriteList>(context);

    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (shuffledWords.isEmpty) {
      return _buildEmptyState();
    }

    // --- POPSCOPE İLE GERİ TUŞUNU YAKALAMA ---
    return PopScope(
      canPop: false, // Otomatik çıkışı engelle, biz yöneteceğiz
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Seri arttı mı bilgisini ana ekrana gönder
        Navigator.pop(context, _hasStreakIncreasedSession);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgGradientStart, bgGradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ÜST BAR
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // OK TUŞU İLE ÇIKIŞ
                              Navigator.pop(
                                  context, _hasStreakIncreasedSession);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 18.sp),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Level ${widget.level}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 12.sp),
                                ),
                                SizedBox(height: 5.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _getFixedTotalCount(widget.level) > 0
                                        ? (_getFixedTotalCount(widget.level) -
                                                shuffledWords.length) /
                                            _getFixedTotalCount(widget.level)
                                        : 0,
                                    minHeight: 8,
                                    backgroundColor: Colors.white12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accentColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '${shuffledWords.length}',
                              style: GoogleFonts.poppins(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // KART ALANI
                    Expanded(
                      flex: 10,
                      child: CardSwiper(
                        controller: controller,
                        cardsCount: shuffledWords.length,
                        key: ValueKey(
                            "${shuffledWords.length}_${shuffledWords.isNotEmpty ? shuffledWords.first.quest : 'empty'}"),
                        numberOfCardsDisplayed:
                            shuffledWords.length < 3 ? shuffledWords.length : 3,
                        backCardOffset: const Offset(0, 35),
                        padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 40.h),
                        cardBuilder:
                            (context, index, horizontalOffset, verticalOffset) {
                          if (index >= shuffledWords.length) return Container();
                          return _buildFlipCard(shuffledWords[index]);
                        },
                        onSwipe: (previousIndex, currentIndex, direction) {
                          return _onSwipe(
                              previousIndex,
                              currentIndex,
                              direction,
                              wordProvider,
                              progressProvider,
                              scoreProvider,
                              streakProvider,
                              shuffledWords);
                        },
                        allowedSwipeDirection: const AllowedSwipeDirection.only(
                            right: true, left: true),
                      ),
                    ),

                    // ALT BUTONLAR
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 30.h, left: 30.w, right: 30.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(
                            icon: Icons.favorite,
                            isActive: shuffledWords.isNotEmpty &&
                                favoriteList.favorites.any((item) =>
                                    item.question == shuffledWords[0].quest),
                            activeColor: Colors.redAccent,
                            onTap: () =>
                                _toggleFavorite(wordProvider, shuffledWords),
                          ),
                          _buildCircleButton(
                            icon: Icons.volume_up_rounded,
                            size: 70.w,
                            isActive: true,
                            activeColor: textColorMain,
                            iconSize: 35.sp,
                            onTap: () {
                              if (shuffledWords.isNotEmpty)
                                _speak(shuffledWords[0].quest);
                            },
                          ),
                          _buildCircleButton(
                            icon: isIconVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            isActive: isIconVisible,
                            activeColor: accentColor,
                            onTap: () {
                              setState(() {
                                isIconVisible = !isIconVisible;
                                _saveIsIconVisible(isIconVisible);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ANIMASYON KATMANI
            FloatingScoreOverlay(key: _scoreKey),
          ],
        ),
      ),
    );
  }

  // --- BOŞ DURUM (BİTİNCE) ---
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [bgGradientStart, bgGradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration, color: accentColor, size: 80.sp),
            ),
            SizedBox(height: 30.h),
            Text("Harika İş!",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Text("Bu seviyedeki tüm kelimeleri bitirdin.",
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 16.sp)),
            SizedBox(height: 40.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                var wordProvider =
                    Provider.of<WordProvider>(context, listen: false);
                await wordProvider.resetList(widget.level); // await eklendi
                var originalWords = wordProvider.getWords(widget.level);
                setState(() {
                  shuffledWords = List.from(originalWords);
                  shuffledWords.shuffle();
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text("Seviyeyi Sıfırla & Tekrar Oyna",
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _hasStreakIncreasedSession),
              child: Text("Listeye Dön",
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.blue,
    double? size,
    double? iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? 55.w,
        height: size ?? 55.w,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: Offset(0, 5))
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : Colors.white60,
          size: iconSize ?? 28.sp,
        ),
      ),
    );
  }

  Widget _buildFlipCard(Words word) {
    FlipCardController localController = FlipCardController();
    return FlipCard(
      controller: localController,
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      speed: 500,
      front: _buildCardFace(word: word, isFront: true),
      back: _buildCardFace(word: word, isFront: false),
    );
  }

  Widget _buildCardFace({required Words word, required bool isFront}) {
    String mainText = isFront ? word.quest : word.answer;
    String subText = isFront ? word.front : word.back;
    String hintText = word.answer;

    Widget sentenceWidget;
    if (isFront) {
      String lowerSubText = subText.toLowerCase();
      String lowerMainText = mainText.toLowerCase();
      int startIndex = lowerSubText.indexOf(lowerMainText);

      if (startIndex != -1) {
        sentenceWidget = Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(
                text: subText.substring(0, startIndex),
                style: GoogleFonts.poppins(
                    fontSize: 18.sp, color: textColorSub, height: 1.5),
              ),
              TextSpan(
                text:
                    subText.substring(startIndex, startIndex + mainText.length),
                style: GoogleFonts.poppins(
                  fontSize: 19.sp,
                  color: Colors.black,
                  backgroundColor: highlightColor,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              TextSpan(
                text: subText.substring(startIndex + mainText.length),
                style: GoogleFonts.poppins(
                    fontSize: 18.sp, color: textColorSub, height: 1.5),
              ),
            ],
          ),
        );
      } else {
        sentenceWidget = Text(subText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 18.sp, color: textColorSub, height: 1.5));
      }
    } else {
      sentenceWidget = Text(subText,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 18.sp, color: textColorSub, height: 1.5));
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: textColorMain.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isFront
                          ? textColorMain.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFront ? "ENGLISH" : "TURKISH",
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: isFront ? textColorMain : Colors.grey,
                          letterSpacing: 1.2),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      mainText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36.sp,
                        color: isFront ? textColorMain : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: sentenceWidget,
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
          if (isFront && isIconVisible)
            Positioned(
              bottom: 40.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb, color: accentColor, size: 20.sp),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        hintText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 15.h,
            left: 0,
            right: 0,
            child: Text(
              isFront ? "Çeviriyi görmek için dokun" : "Geri dönmek için dokun",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
