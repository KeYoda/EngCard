import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/drawer.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/streak_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/flash_card.dart';
import 'package:eng_card/widgets/streak_celebration.dart'; // YENİ WIDGET
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SixScreen extends StatefulWidget {
  const SixScreen({super.key});
  @override
  State<SixScreen> createState() => _SixScreenState();
}

Color hardgreen = const Color(0xFF0F2027);
Color medgreen = const Color(0xFF203A43);
Color easgreen = const Color(0xFF2EC4B6);
Color orange = const Color(0xFFFF9F1C);
Color yellow = const Color(0xFFFFBF69);
Color whites = Colors.white;

class _SixScreenState extends State<SixScreen> {
  // Animasyon durumu kontrolü
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    // Provider tanımları
    final favoriteList = Provider.of<FavoriteList>(context);
    favoriteList.loadFavorites();

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordListProvider = Provider.of<WordProvider>(context);

    // YENİ EKLENEN STREAK PROVIDER
    var streakProvider = Provider.of<StreakProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: whites),
        title: Text(
          'WordCard',
          style: GoogleFonts.poppins(
              color: whites, fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const MainDrawer(),

      // --- STACK YAPISI GÜNCELLENDİ ---
      body: Stack(
        children: [
          // 1. MEVCUT ARKA PLAN VE LİSTE
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [hardgreen, medgreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                children: [
                  _buildStatsPanel(
                      scoreProvider, streakProvider), // Parametre Eklendi
                  SizedBox(height: 30.h),
                  Text(
                    "Seviyeler",
                    style: GoogleFonts.poppins(
                      color: whites,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Seviye Kartları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildModernLevelCard(
                        context: context,
                        level: 'A1',
                        imagePath: 'assets/a1.webp',
                        isEmpty: wordListProvider.getWords('A1').isEmpty,
                        nextPage: const FlashCardScreen(level: 'A1'),
                        progressValue: progressProvider.getLinearProgress('A1'),
                      ),
                      _buildModernLevelCard(
                        context: context,
                        level: 'A2',
                        imagePath: 'assets/a2.webp',
                        isEmpty: wordListProvider.getWords('A2').isEmpty,
                        nextPage: const FlashCardScreen(level: 'A2'),
                        progressValue: progressProvider.getLinearProgress('A2'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildModernLevelCard(
                        context: context,
                        level: 'B1',
                        imagePath: 'assets/a3.webp',
                        isEmpty: wordListProvider.getWords('B1').isEmpty,
                        nextPage: const FlashCardScreen(level: 'B1'),
                        progressValue: progressProvider.getLinearProgress('B1'),
                      ),
                      _buildModernLevelCard(
                        context: context,
                        level: 'B2',
                        imagePath: 'assets/a4.webp',
                        isEmpty: wordListProvider.getWords('B2').isEmpty,
                        nextPage: const FlashCardScreen(level: 'B2'),
                        progressValue: progressProvider.getLinearProgress('B2'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildModernLevelCard(
                    context: context,
                    level: 'C1',
                    imagePath: 'assets/a5.webp',
                    isEmpty: wordListProvider.getWords('C1').isEmpty,
                    nextPage: const FlashCardScreen(level: 'C1'),
                    progressValue: progressProvider.getLinearProgress('C1'),
                    isFullWidth: true,
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // 2. KUTLAMA KATMANI (EN ÜSTTE)
          if (_showCelebration)
            Positioned.fill(
              child: Container(
                color: Colors.black54, // Arkayı hafif karart
                child: StreakCelebrationOverlay(
                  onAnimationComplete: () {
                    setState(() {
                      _showCelebration = false; // Animasyon bitince kapat
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- İSTATİSTİK PANELİ (GÜNCELLENDİ) ---
  Widget _buildStatsPanel(
      ScoreProvider scoreProvider, StreakProvider streakProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: whites.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: whites.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Toplam Puan", scoreProvider.totalScore.toString(),
              Icons.emoji_events),
          Container(
              width: 1, height: 40.h, color: whites.withValues(alpha: 0.2)),
          _buildStatItem("Günlük Puan", scoreProvider.dailyScore.toString(),
              Icons.calendar_today),
          Container(
              width: 1, height: 40.h, color: whites.withValues(alpha: 0.2)),
          _buildStatItem(
              'Günlük Seri',
              streakProvider.isTargetReached
                  ? "${streakProvider.streakCount} Gün 🔥"
                  : "${streakProvider.dailyCount} / 10",
              Icons.local_fire_department_rounded,
              color: streakProvider.isTargetReached
                  ? Colors.deepOrangeAccent
                  : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? orange, size: 24.sp),
        SizedBox(height: 5.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: whites,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: whites.withValues(alpha: 0.7),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildModernLevelCard({
    required BuildContext context,
    required String level,
    required String imagePath,
    required bool isEmpty,
    required Widget nextPage,
    required double progressValue,
    bool isFullWidth = false,
  }) {
    double cardWidth = isFullWidth
        ? ScreenUtil().screenWidth - 40.w
        : (ScreenUtil().screenWidth - 55.w) / 2;

    return GestureDetector(
      onTap: () async {
        // async Eklendi
        if (isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: easgreen,
              content: Text(
                'Bu bölümü tamamladınız! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: whites),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          // İsterseniz burada da resetleme sayfasına yönlendirebilirsiniz
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => nextPage));
        } else {
          final bool? result = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => nextPage));

          if (result == true) {
            setState(() {
              _showCelebration = true;
            });
          }
        }
      },
      child: Container(
        width: cardWidth,
        height: 190.h,
        decoration: BoxDecoration(
          color: whites,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                    if (isEmpty)
                      Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
                          child: Icon(Icons.check_circle,
                              color: orange, size: 40.sp),
                        ),
                      )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Seviye $level",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (progressValue > 0)
                          Text(
                            "%${(progressValue * 100).toInt()}",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 6, // .h kaldırıldı (Hata önlemi)
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isEmpty ? easgreen : orange,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isEmpty ? "Tamamlandı" : "Devam et",
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: isEmpty ? easgreen : Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
