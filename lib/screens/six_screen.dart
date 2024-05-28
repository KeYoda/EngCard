import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/drawer.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/five_card.dart';
import 'package:eng_card/screens/four_card.dart';
import 'package:eng_card/screens/one_card.dart';
import 'package:eng_card/screens/thre_card.dart';
import 'package:eng_card/screens/two_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SixScreen extends StatefulWidget {
  const SixScreen({super.key});
  @override
  State<SixScreen> createState() => _SixScreenState();
}

BoxDecoration createCircularBox(String imagePath) {
  return BoxDecoration(
    shape: BoxShape.circle,
    image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        alignment: Alignment.center),
  );
}

String imagePath1 = 'assets/a1.webp';
String imagePath2 = 'assets/a2.webp';
String imagePath3 = 'assets/a3.webp';
String imagePath4 = 'assets/a4.webp';
String imagePath5 = 'assets/a5.webp';

BoxDecoration circulBox1 = createCircularBox(imagePath1);
BoxDecoration circulBox2 = createCircularBox(imagePath2);
BoxDecoration circulBox3 = createCircularBox(imagePath3);
BoxDecoration circulBox4 = createCircularBox(imagePath4);
BoxDecoration circulBox5 = createCircularBox(imagePath5);

Color orange = const Color.fromARGB(255, 253, 85, 35);
Color hardgreen = const Color.fromARGB(255, 35, 68, 59);
Color medgreen = const Color.fromARGB(255, 53, 104, 89);
Color easgreen = const Color.fromARGB(255, 55, 150, 111);
Color whites = const Color.fromARGB(255, 255, 251, 230);
Color yellow = const Color.fromARGB(255, 202, 162, 16);

class _SixScreenState extends State<SixScreen> {
  final TextStyle _textStyle = TextStyle(
      color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final favoriteList = Provider.of<FavoriteList>(context);
    favoriteList.loadFavorites();

    var progressProvider = Provider.of<ProgressProvider>(context);
    var scoreProvider = Provider.of<ScoreProvider>(context);
    var wordListProvider = Provider.of<WordProvider>(context);
    var wordListProvider1 = Provider.of<WordProvider2>(context);
    var wordListProvider2 = Provider.of<WordProvider3>(context);
    var wordListProvider3 = Provider.of<WordProvider4>(context);
    var wordListProvider4 = Provider.of<WordProvider5>(context);

    double screenWidth = ScreenUtil().screenWidth;
    double screenHeight = ScreenUtil().screenHeight;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: whites),
        title: Text(
          'OneWord',
          style: GoogleFonts.abel(color: whites, fontSize: 30.sp),
        ),
        backgroundColor: hardgreen,
        centerTitle: true,
      ),
      drawer: const MainDrawer(),
      body: Container(
        color: whites,
        child: ListView(
          children: [
            SizedBox(height: 17.sp),
            Row(
              children: [
                Flexible(
                  child: SizedBox(
                    width: screenWidth * 0.052.sp,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Toplam Skor',
                      style: TextStyle(color: medgreen, fontSize: 12.sp),
                    ),
                    Container(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${scoreProvider.totalScore}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: screenWidth * 0.12.sp,
                ),
                Column(
                  children: [
                    Text(
                      'Günlük Skor',
                      style: TextStyle(color: medgreen, fontSize: 12.sp),
                    ),
                    Container(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${scoreProvider.dailyScore}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    width: screenWidth * 0.10.sp,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Bilinen Kelimeler',
                      style: TextStyle(color: medgreen, fontSize: 12.sp),
                    ),
                    Container(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${scoreProvider.knownScore}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            ///////////////////////////////////////////////////////////
            SizedBox(
              height: screenHeight * 0.050,
            ),
            //
            Row(
              children: [
                SizedBox(width: screenWidth * 0.024),
                SizedBox(
                  width: screenWidth * 0.47,
                  height: screenHeight * 0.2,
                  child: InkWell(
                    onTap: () {
                      if (wordListProvider.wordsListOne.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: hardgreen,
                            content: Text(
                              '                      Bu bölümü tamamladınız',
                              style: TextStyle(color: whites),
                            ),
                            duration: const Duration(seconds: 2),
                            // action: SnackBarAction(
                            //     label: 'Sıfırlamak için tıklayın', onPressed: () {}),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OneCard(),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.179,
                            decoration: circulBox1,
                            child: CircularProgressIndicator(
                              strokeAlign: 2,
                              strokeWidth: 7,
                              value: progressProvider.progressValue,
                              backgroundColor: easgreen,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                yellow,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 65,
                            child: Text('A1', style: _textStyle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                SizedBox(
                  width: screenWidth * 0.47,
                  height: screenHeight * 0.2,
                  child: InkWell(
                    onTap: () {
                      if (wordListProvider1.wordsListTwo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bu bölümü tamamladınız.'),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TwoCard(),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            height: screenHeight * 0.179,
                            width: screenWidth * 0.4,
                            decoration: circulBox2,
                            child: CircularProgressIndicator(
                              strokeAlign: 2,
                              strokeWidth: 7,
                              value: progressProvider.progressValue1,
                              backgroundColor: easgreen,
                              valueColor: AlwaysStoppedAnimation<Color>(yellow),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 65,
                            child: Text('A2', style: _textStyle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //////////////////////////////////////////////////////////////////////
            SizedBox(height: screenHeight * 0.03),
            Row(
              children: [
                SizedBox(width: screenWidth * 0.024),
                SizedBox(
                  width: screenWidth * 0.47,
                  height: screenHeight * 0.2,
                  child: InkWell(
                    onTap: () {
                      if (wordListProvider2.wordsListThre.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bu bölümü tamamladınız.'),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ThreCard(),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.179,
                            decoration: circulBox3,
                            child: CircularProgressIndicator(
                              strokeAlign: 2,
                              strokeWidth: 7,
                              value: progressProvider.progressValue2,
                              backgroundColor: easgreen,
                              valueColor: AlwaysStoppedAnimation<Color>(yellow),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 65,
                            child: Text('B1', style: _textStyle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                SizedBox(
                  width: screenWidth * 0.47,
                  height: screenHeight * 0.179,
                  child: InkWell(
                    onTap: () {
                      if (wordListProvider3.wordsListFour.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bu bölümü tamamladınız.'),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FourCard(),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.179,
                            decoration: circulBox4,
                            child: CircularProgressIndicator(
                              strokeAlign: 2,
                              strokeWidth: 7,
                              value: progressProvider.progressValue3,
                              backgroundColor: easgreen,
                              valueColor: AlwaysStoppedAnimation<Color>(yellow),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 65,
                            child: Text('B2', style: _textStyle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ), /////////////////////////////////////////////////////
            SizedBox(height: screenHeight * 0.03),
            Row(
              children: [
                SizedBox(width: screenWidth * 0.25),
                SizedBox(
                  width: screenWidth * 0.47,
                  height: screenHeight * 0.2,
                  child: InkWell(
                    onTap: () {
                      if (wordListProvider4.wordsListFive.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bu bölümü tamamladınız.'),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FiveCard(),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.179,
                            decoration: circulBox5,
                            child: CircularProgressIndicator(
                              strokeAlign: 2,
                              strokeWidth: 7,
                              value: progressProvider.progressValue4,
                              backgroundColor: easgreen,
                              valueColor: AlwaysStoppedAnimation<Color>(yellow),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 65,
                            child: Text('C1', style: _textStyle),
                          ),
                        ],
                      ),
                    ),
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
