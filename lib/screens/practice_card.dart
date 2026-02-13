import 'package:eng_card/data/gridview.dart'; // Ana veri kaynağı (wordsListOne)
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PracticeCard extends StatefulWidget {
  const PracticeCard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PracticeCardState();
  }
}

class _PracticeCardState extends State<PracticeCard> {
  List<Words> practiceList = [];

  // --- MODERN RENK PALETİ ---
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);

  @override
  void initState() {
    super.initState();
    _generateRandomList();
  }

  // Rastgele 15 kelime seçme fonksiyonu
  void _generateRandomList() {
    setState(() {
      // Ana listenin kopyasını al
      List<Words> tempList = List.from(wordsListOne);
      tempList.shuffle(); // Karıştır
      // İlk 15 tanesini al (Liste 15'ten küçükse hepsini al)
      practiceList = tempList.take(15).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Alıştırma',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Yüzen Yenileme Butonu (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateRandomList,
        backgroundColor: accentOrange,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        label: Text("Karıştır",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
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
              // Üst Bilgi Yazısı
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle, color: Colors.white70, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Rastgele 15 Kelime",
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),

              // GRID ALANI
              Expanded(
                child: practiceList.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(color: accentOrange))
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        // Key değiştiğinde animasyon tetiklenir
                        child: GridView.builder(
                          key: ValueKey<int>(practiceList.first.hashCode),
                          padding: EdgeInsets.fromLTRB(
                              15.w, 0, 15.w, 80.h), // FAB için alt boşluk
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Yan yana 3 kart
                            childAspectRatio: 0.85, // Kartların boy/en oranı
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                          ),
                          itemCount: practiceList.length,
                          itemBuilder: (context, index) {
                            return _buildPracticeItem(index);
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

  Widget _buildPracticeItem(int index) {
    final Words word = practiceList[index];
    final Color levelColor = _getColorForLevel(word.list);
    final FlipCardController flipCardController = FlipCardController();

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 400,
      controller: flipCardController,

      // --- ÖN YÜZ (SORU) ---
      front: Container(
        decoration: BoxDecoration(
          color: levelColor, // Seviye rengi
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Stack(
          children: [
            // Seviye Etiketi (Sağ üst)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word.list,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Kelime (Ortada)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  word.quest,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- ARKA YÜZ (CEVAP) ---
      back: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Arka yüz beyaz
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              word.answer,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFFE5989B); // Pastel Kırmızımsı
      case 'A2':
        return const Color(0xFFF4A261); // Pastel Turuncu
      case 'B1':
        return const Color(0xFF2A9D8F); // Pastel Yeşil
      case 'B2':
        return const Color(0xFF264653); // Koyu Mavi
      case 'C1':
        return const Color(0xFF6D6875); // Grimsi Mor
      default:
        return const Color(0xFFA5A58D);
    }
  }
}
