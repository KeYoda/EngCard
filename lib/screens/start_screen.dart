import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  void _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasStarted = prefs.getBool('hasStarted');

    if (hasStarted == null || !hasStarted) {
      setState(() {
        _isFirstRun = true;
      });
    } else {
      setState(() {
        _isFirstRun = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    var wordLists = Provider.of<WordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hoşgeldin',
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 30,
            // fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.white,
        toolbarHeight: 130,
        backgroundColor: yellow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(150, 30),
            bottomRight: Radius.elliptical(150, 30),
          ),
        ),
      ),
      backgroundColor: whites,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SizedBox(
                height: 300.h,
                child: Image.asset('assets/logoback.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Eğitim, hayat boyu süren bir serüven ve keşif yolculuğudur. Bu yolculuğa beni de dahil etmek için aşağıdaki butona basarak başlayalım.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    color: yellow,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 35.h),
            Padding(
              padding: EdgeInsets.all(20.0.w),
              child: SizedBox(
                height: 65,
                width: 220,
                child: ElevatedButton(
                  onPressed: () async {
                    wordLists.resetList('C1');
                    wordLists.resetList('B2');
                    wordLists.resetList('B1');
                    wordLists.resetList('A2');
                    wordLists.resetList('A1');

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('hasStarted', true);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SixScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    backgroundColor: hardgreen,
                    foregroundColor: whites,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0.r),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Hadi başlayalım',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
