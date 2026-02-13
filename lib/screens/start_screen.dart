import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/six_screen.dart'; // Renkleri ve ana menüyü buradan alıyoruz
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() {
    return _StartScreenState();
  }
}

class _StartScreenState extends State<StartScreen> {
  bool _isFirstRun = true;
  bool _isLoading = true; // Yükleme durumu eklendi

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  void _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasStarted = prefs.getBool('hasStarted');

    setState(() {
      _isFirstRun = (hasStarted == null || !hasStarted);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          backgroundColor: Color(0xFF0F2027),
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: ConditionalBuilder(
        condition: _isFirstRun,
        builder: (context) => const CheckScreen(),
        fallback: (context) => const SixScreen(),
      ),
    );
  }
}

class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

  // Uygulama genelindeki renk paleti
  final Color gradientStart = const Color(0xFF0F2027);
  final Color gradientEnd = const Color(0xFF203A43);
  final Color accentOrange = const Color(0xFFFF9F1C);
  final Color accentTurquoise = const Color(0xFF2EC4B6);

  @override
  Widget build(BuildContext context) {
    var wordLists = Provider.of<WordProvider>(context, listen: false);
    var scoreProvider = Provider.of<ScoreProvider>(context, listen: false);
    var progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    return Scaffold(
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
              SizedBox(height: 40.h),

              // --- BAŞLIK ALANI ---
              Text(
                'Hoş Geldin',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 4.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: accentTurquoise,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Spacer(),

              // --- LOGO ALANI (Parlama Efektli) ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentTurquoise.withOpacity(0.05),
                    ),
                  ),
                  SizedBox(
                    height: 200.h,
                    child: Image.asset(
                      'assets/logoback.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // --- METİN ALANI ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  children: [
                    Text(
                      'Kelime Hazneni Genişlet',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Eğitim, hayat boyu süren bir serüven ve keşif yolculuğudur. İngilizce serüvenine bugün harika bir başlangıç yap.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 50.h),

              // --- BUTON ALANI ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
                child: Container(
                  width: double.infinity,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: accentOrange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Listeleri Resetle
                      wordLists.resetList('C1');
                      wordLists.resetList('B2');
                      wordLists.resetList('B1');
                      wordLists.resetList('A2');
                      wordLists.resetList('A1');

                      scoreProvider.resetTotalScore();
                      progressProvider.resetAllProgress();

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('hasStarted', true);

                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const SixScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hadi Başlayalım',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
