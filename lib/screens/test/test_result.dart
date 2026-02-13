import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/data/save_words.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/test/test_data.dart';
import 'package:eng_card/screens/test/blanc_test.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:eng_card/screens/test/voice_test.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestResult extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswer;
  final int totalScore;
  final List<QuestionAnswer> answeredQuestions;
  final String level;

  const TestResult({
    Key? key,
    required this.totalQuestions,
    required this.correctAnswer,
    required this.answeredQuestions,
    required this.totalScore,
    required this.level,
  }) : super(key: key);

  @override
  _TestResultState createState() => _TestResultState();
}

class _TestResultState extends State<TestResult> {
  // --- RENK PALETİ ---
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);
  final Color accentTurquoise = const Color(0xFF2EC4B6);
  final Color whiteText = Colors.white;

  late FavoriteList favoriteList;

  @override
  void initState() {
    super.initState();
    favoriteList = Provider.of<FavoriteList>(context, listen: false);
  }

  void toggleFav(int index) {
    if (widget.answeredQuestions.isEmpty) return;

    SavedItem newFavorite = SavedItem(
      answer: widget.answeredQuestions[index].answer,
      question: widget.answeredQuestions[index].question,
      lvClass: widget.answeredQuestions[index].list,
    );

    if (favoriteList.favorites.contains(newFavorite)) {
      favoriteList.deleteFavorite(favoriteList.favorites.indexOf(newFavorite));
    } else {
      favoriteList.addFavorite(newFavorite);
    }
    favoriteList.saveFavorites();
    setState(() {}); // İkonu güncellemek için
  }

  @override
  Widget build(BuildContext context) {
    var progressProv = Provider.of<ProgressProvider>(context);

    // Kelimeleri birleştir (Yeniden başlatma için)
    List<Words> _getWordsForLevel(String level) {
      return wordsListOne.where((w) => w.list == level).toList();
    }

    int wrongWord = widget.totalQuestions - widget.correctAnswer;
    double successRate = (widget.correctAnswer / widget.totalQuestions);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Test Sonucu',
          style: GoogleFonts.poppins(
            color: whiteText,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. ÖZET KARTI (Score Card) ---
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Dairesel İlerleme (Başarı Oranı)
                    SizedBox(
                      height: 100.w,
                      width: 100.w,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: successRate,
                            strokeWidth: 8.w,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              successRate >= 0.5
                                  ? accentTurquoise
                                  : Colors.redAccent,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "%${(successRate * 100).toInt()}",
                                  style: GoogleFonts.poppins(
                                    color: whiteText,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Başarı",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white60, fontSize: 10.sp),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // İstatistikler (Doğru, Yanlış, Puan)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(Icons.check_circle, "Doğru",
                            "${widget.correctAnswer}", accentTurquoise),
                        SizedBox(height: 10.h),
                        _buildStatRow(Icons.cancel, "Yanlış", "$wrongWord",
                            Colors.redAccent),
                        SizedBox(height: 10.h),
                        _buildStatRow(Icons.emoji_events, "Puan",
                            "${widget.totalScore}", accentOrange),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. AYIRICI ÇİZGİ VE BAŞLIK ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Row(
                  children: [
                    Text("Detaylı Rapor",
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 14.sp)),
                    SizedBox(width: 10.w),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // --- 3. CEVAP LİSTESİ ---
              Expanded(
                child: widget.answeredQuestions.isEmpty
                    ? Center(
                        child: Text("Henüz cevap yok.",
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: widget.answeredQuestions.length,
                        itemBuilder: (context, index) {
                          final item = widget.answeredQuestions[index];
                          final isFav = favoriteList.favorites
                              .any((fav) => fav.question == item.question);

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white, // Kartlar beyaz
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 4.h),

                              // Seviye Etiketi (Sol)
                              leading: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: accentTurquoise.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.list,
                                  style: GoogleFonts.poppins(
                                    color: accentTurquoise,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),

                              // Soru ve Cevap
                              title: Text(
                                item.question,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 14.sp,
                                ),
                              ),
                              subtitle: Text(
                                item.answer,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),

                              // Favori Butonu (Sağ)
                              trailing: IconButton(
                                onPressed: () => toggleFav(index),
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // --- 4. YENİDEN BAŞLAT BUTONU ---
              Padding(
                padding: EdgeInsets.all(20.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: Text(
                      "Yeni Teste Başla",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Skoru güncelle ve temizle
                      Provider.of<ScoreProvider>(context, listen: false)
                          .incrementScore(widget.totalScore);
                      Provider.of<ProgressProvider>(context, listen: false)
                          .resetCorrectAnswers();

                      Navigator.pop(context);

                      // İlgili testi yeniden başlatma mantığı
                      _restartTest(context, progressProv,
                          _getWordsForLevel(widget.level));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // İstatistik Satırı Tasarımı
  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp),
        ),
      ],
    );
  }

  // Testi yeniden başlatma mantığı (Kod tekrarını azalttık)
  void _restartTest(BuildContext context, ProgressProvider progressProv,
      List<Words> combinedWords) {
    Widget nextScreen;

    if (widget.totalQuestions == 15) {
      // Kelime Anlamı Testi
      nextScreen = TestWord(
        level: widget.level,
        words: combinedWords,
        onComplete: () => _checkCompletion(progressProv),
      );
    } else if (widget.totalQuestions == 10) {
      // Boşluk Doldurma Testi
      nextScreen = BlancTestScreen(
        level: widget.level,
        words: combinedWords,
        onComplete: () => _checkCompletion(progressProv),
      );
    } else {
      // Ses Testi
      nextScreen = VoiceTest(
        level: widget.level,
        words: combinedWords,
        onComplete: () => _checkCompletion(progressProv),
      );
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  void _checkCompletion(ProgressProvider progressProv) {
    if (progressProv.remainingQuestions[widget.level] == 0) {
      progressProv.resetCorrectAnswers();
    }
  }
}
