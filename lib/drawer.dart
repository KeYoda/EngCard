import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/fav_card.dart';
import 'package:eng_card/screens/practice_card.dart';
import 'package:eng_card/screens/test/blanc_test.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:eng_card/screens/test/voice_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// --- RENKLER ---
// Eğer SixScreen'den geliyorsa oradaki değişkenleri kullanır,
// yoksa buradaki fallback değerleri kullanır.
const Color drawerGradientStart = Color(0xFF0F2027);
const Color drawerGradientEnd = Color(0xFF203A43);
const Color accentOrange = Color(0xFFFF9F1C);
const Color accentTurquoise = Color(0xFF2EC4B6);
const Color whiteText = Colors.white;

void _shareApp(BuildContext context) async {
  await Share.share(
    'Hey, check out this awesome app! https://example.com',
    subject: 'Check out this app!',
  );
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    List<Words> _getWordsForLevel(String level) {
      return wordsListOne.where((w) => w.list == level).toList();
    }

    return Drawer(
      child: Container(
        // Arka planı Container'a veriyoruz ki tüm ekranı (status bar dahil) kaplasın
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [drawerGradientStart, drawerGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // --- DÜZELTME BURADA: SafeArea ---
        // İçeriği SafeArea içine alıyoruz ki çentikli telefonlarda taşma yapmasın
        child: SafeArea(
          child: Column(
            children: [
              _createDrawerHeader(),

              // Orta Kısım (Liste)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildListTiles(context, [
                    ..._getWordsForLevel('A1'),
                    ..._getWordsForLevel('A2'),
                    ..._getWordsForLevel('B1'),
                    ..._getWordsForLevel('B2'),
                    ..._getWordsForLevel('C1'),
                  ]),
                ),
              ),

              // Alt Kısım (Versiyon)
              // SafeArea olduğu için alt boşluğu biraz azalttım (20.h -> 10.h)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                child: Text(
                  "WordCard v1.0",
                  style: GoogleFonts.poppins(
                      color: Colors.white24, fontSize: 10.sp),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: accentTurquoise.withValues(alpha: 0.5)),
            ),
            child: Image.asset(
              'assets/logoback.png',
              height: 80.h,
              width: 80.h,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            "WordCard",
            style: GoogleFonts.poppins(
                color: whiteText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListTiles(
      BuildContext context, List<Words> combinedWords) {
    return [
      SizedBox(height: 10.h),
      _createModernTile(
        context,
        icon: Icons.home_rounded,
        text: 'Ana Sayfa',
        onTap: () => Navigator.pop(context),
      ),
      _createModernTile(
        context,
        icon: Icons.favorite_rounded,
        text: 'Favoriler',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FavouritePage()));
        },
      ),
      _createModernTile(
        context,
        icon: Icons.view_carousel_rounded,
        text: 'Alıştırma Kartları',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PracticeCard()));
        },
      ),

      _createModernExpansionTile(context, combinedWords),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: const Divider(color: Colors.white12, thickness: 1),
      ),

      Padding(
        padding: EdgeInsets.only(left: 20.w, bottom: 5.h),
        child: Text(
          'İLETİŞİM & AYARLAR',
          style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5),
        ),
      ),

      _createModernTile(
        context,
        icon: Icons.mail_outline_rounded,
        text: 'Bize Ulaşın',
        onTap: () => _launchEmail(),
      ),
      _createModernTile(
        context,
        icon: Icons.share_rounded,
        text: 'Uygulamayı Paylaş',
        onTap: () => _shareApp(context),
      ),

      SizedBox(height: 20.h),

      // SİLME BUTONU
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          leading: Icon(Icons.delete_forever_rounded,
              color: Colors.redAccent, size: 22.sp),
          title: Text(
            'İlerlemeyi Sıfırla',
            style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600),
          ),
          onTap: () {
            Navigator.pop(context);
            showDeleteConfirmationDialog(context);
          },
        ),
      ),
    ];
  }

  Widget _createModernTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: accentOrange, size: 22.sp),
      title: Text(
        text,
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
      hoverColor: Colors.white.withValues(alpha: 0.05),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
      horizontalTitleGap: 10.w,
    );
  }

  Widget _createModernExpansionTile(
    BuildContext context,
    List<Words> combinedWords,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.quiz_rounded, color: accentOrange, size: 22.sp),
        title: Text(
          'Testler',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500),
        ),
        iconColor: accentTurquoise,
        collapsedIconColor: Colors.white54,
        childrenPadding: EdgeInsets.only(left: 20.w),
        children: [
          _createSubTile(context,
              icon: Icons.edit_note_rounded,
              text: 'Boşluk Doldurma', onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlancTestScreen(
                level: 'Mix',
                onComplete: () {},
                words: combinedWords,
              ),
            ));
          }),
          _createSubTile(context,
              icon: Icons.translate_rounded, text: 'Kelime Anlamı', onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TestWord(
                level: 'Mix',
                onComplete: () {},
                words: combinedWords,
              ),
            ));
          }),
          _createSubTile(context,
              icon: Icons.headphones_rounded, text: 'Dinleme Testi', onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VoiceTest(
                level: 'Mix',
                onComplete: () {},
                words: combinedWords,
              ),
            ));
          }),
        ],
      ),
    );
  }

  Widget _createSubTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 18.sp, color: accentTurquoise),
      title: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w400),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.only(left: 30.w),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _launchEmail() async {
    final String email = Uri.encodeComponent("keyodapp@gmail.com");
    final String subject = Uri.encodeComponent('Öneri ve Şikayet');
    final Uri mail = Uri.parse("mailto:$email?subject=$subject");
    if (await launchUrl(mail)) {
    } else {
      throw 'Could not launch $mail';
    }
  }
}

// --- DİYALOG KUTUSU TASARIMI ---
void showDeleteConfirmationDialog(BuildContext context) {
  final deleteProgress = context.read<ProgressProvider>();
  final resetScore = context.read<ScoreProvider>();
  final resetWords = context.read<WordProvider>();
  final resetTestList = context.read<ListProgressProvider>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 28.sp),
            SizedBox(width: 10.w),
            Text("Dikkat", style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        content: Text(
          'Tüm ilerlemeniz, skorlarınız ve öğrendiğiniz kelimeler sıfırlanacak.\n\nBu işlem geri alınamaz!',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vazgeç',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              // async eklemeyi unutmayın

              // 1. Diğer verileri sıfırla
              deleteProgress.resetAllProgress();
              resetScore.resetTotalScore();
              resetTestList.resetWordsProgress(wordProvider: resetWords);

              // 2. KELİMELERİ SIFIRLA VE BEKLE (await çok önemli)
              await resetWords.restoreAllWords();

              if (context.mounted) {
                Navigator.of(context).pop(); // Diyaloğu kapat

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: accentTurquoise,
                    content: Text('Tüm veriler başarıyla sıfırlandı.',
                        style: GoogleFonts.poppins()),
                  ),
                );
              }
            },
            child: Text('Evet, Sil',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
