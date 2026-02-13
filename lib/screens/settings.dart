import 'package:eng_card/data/gridview.dart'; // wordsListOne buradan geliyor
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eng_card/provider/progres_prov.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // Renk Paleti
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentTurquoise = const Color(0xFF2EC4B6);
  final Color accentOrange = const Color(0xFFFF9F1C);

  // --- YARDIMCI FONKSİYONLAR (WordsListOne Kullanarak) ---

  // 1. İlgili seviyedeki toplam kelime sayısını bulur
  int _getTotalCount(String level) {
    return wordsListOne.where((w) => w.list == level).length;
  }

  // 2. Test sayfasına göndermek için sadece o seviyenin kelimelerini filtreler
  List<Words> _getWordsForLevel(String level) {
    return wordsListOne.where((w) => w.list == level).toList();
  }

  @override
  Widget build(BuildContext context) {
    var progressProv = Provider.of<ProgressProvider>(context);
    var listProgressProv = Provider.of<ListProgressProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          'Kelime Testi Ayarları',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
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
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            children: [
              // Bilgilendirme metni
              Padding(
                padding: EdgeInsets.only(bottom: 20.h, left: 5.w),
                child: Text(
                  "Seviyeni seç ve kelime bilgini test et!",
                  style: GoogleFonts.poppins(
                      color: Colors.white60, fontSize: 13.sp),
                ),
              ),

              // A1 KARTI
              _buildLevelSettingCard(
                context,
                level: 'A1',
                imagePath: 'assets/a1.webp',
                progressValue: progressProv.getCircleProgress('A1'),
                remaining: progressProv.remainingQuestions['A1'] ?? 0,
                total: _getTotalCount('A1'), // DİNAMİK
                navigate: TestWord(
                  level: 'A1',
                  words: _getWordsForLevel('A1'), // DİNAMİK
                  onComplete: () {
                    progressProv.completeQuestion('A1');
                    listProgressProv.decreaseProgress('A1');
                  },
                ),
              ),

              // A2 KARTI
              _buildLevelSettingCard(
                context,
                level: 'A2',
                imagePath: 'assets/a2.webp',
                progressValue: progressProv.getCircleProgress('A2'),
                remaining: progressProv.remainingQuestions['A2'] ?? 0,
                total: _getTotalCount('A2'), // DİNAMİK
                navigate: TestWord(
                  level: 'A2',
                  words: _getWordsForLevel('A2'), // DİNAMİK
                  onComplete: () {
                    progressProv.completeQuestion('A2');
                    listProgressProv.decreaseProgress('A2');
                  },
                ),
              ),

              // B1 KARTI
              _buildLevelSettingCard(
                context,
                level: 'B1',
                imagePath: 'assets/a3.webp',
                progressValue: progressProv.getCircleProgress('B1'),
                remaining: progressProv.remainingQuestions['B1'] ?? 0,
                total: _getTotalCount('B1'), // DİNAMİK
                navigate: TestWord(
                  level: 'B1',
                  words: _getWordsForLevel('B1'), // DİNAMİK
                  onComplete: () {
                    progressProv.completeQuestion('B1');
                    listProgressProv.decreaseProgress('B1');
                  },
                ),
              ),

              // B2 KARTI
              _buildLevelSettingCard(
                context,
                level: 'B2',
                imagePath: 'assets/a4.webp',
                progressValue: progressProv.getCircleProgress('B2'),
                remaining: progressProv.remainingQuestions['B2'] ?? 0,
                total: _getTotalCount('B2'), // DİNAMİK
                navigate: TestWord(
                  level: 'B2',
                  words: _getWordsForLevel('B2'), // DİNAMİK
                  onComplete: () {
                    progressProv.completeQuestion('B2');
                    listProgressProv.decreaseProgress('B2');
                  },
                ),
              ),

              // C1 KARTI
              _buildLevelSettingCard(
                context,
                level: 'C1',
                imagePath: 'assets/a5.webp',
                progressValue: progressProv.getCircleProgress('C1'),
                remaining: progressProv.remainingQuestions['C1'] ?? 0,
                total: _getTotalCount('C1'), // DİNAMİK
                navigate: TestWord(
                  level: 'C1',
                  words: _getWordsForLevel('C1'), // DİNAMİK
                  onComplete: () {
                    progressProv.completeQuestion('C1');
                    listProgressProv.decreaseProgress('C1');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSettingCard(
    BuildContext context, {
    required String level,
    required String imagePath,
    required double progressValue,
    required int remaining,
    required int total,
    required Widget navigate,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 55.w,
              height: 55.w,
              child: CircularProgressIndicator(
                value: progressValue,
                strokeWidth: 4,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(accentTurquoise),
              ),
            ),
            CircleAvatar(
              radius: 22.w,
              backgroundImage: AssetImage(imagePath),
            ),
          ],
        ),
        title: Text(
          "Seviye $level",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        // Tamamlanan mantığı: Toplam - Kalan
        subtitle: Text(
          "Kalan: $remaining / $total",
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 12.sp,
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentOrange,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(12.w),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => navigate),
            );
          },
          child: const Icon(Icons.translate_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
