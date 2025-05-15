import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/drawer.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
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

    double screenWidth = ScreenUtil().screenWidth;
    double screenHeight = ScreenUtil().screenHeight;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: whites),
        title: Text(
          'WordCard',
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
            SizedBox(height: 20.sp),
            _buildScoreRow(scoreProvider, screenWidth, screenHeight),
            SizedBox(
              height: screenHeight * 0.050,
            ),
            _buildLevelRow(
              context,
              wordListProvider,
              progressProvider,
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildLevelRow1(
              context,
              wordListProvider,
              progressProvider,
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildFinalLevel(context, wordListProvider, progressProvider,
                screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(
      ScoreProvider scoreProvider, double screenWidth, double screenHeight) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.076),
        _buildScoreColumn(
            'Toplam Skor', scoreProvider.totalScore, screenHeight, screenWidth),
        SizedBox(width: screenWidth * 0.12),
        _buildScoreColumn(
            'Günlük Skor', scoreProvider.dailyScore, screenHeight, screenWidth),
        SizedBox(width: screenWidth * 0.10),
        _buildScoreColumn('Bilinen Kelimeler', scoreProvider.knownScore,
            screenHeight, screenWidth),
      ],
    );
  }

  Widget _buildScoreColumn(
      String label, int score, double screenHeight, double screenWidth) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: medgreen, fontSize: 11.sp),
        ),
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.2,
          decoration: BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$score',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelRow(
    BuildContext context,
    WordProvider wordListProvider,
    ProgressProvider progressProvider,
    double screenWidth,
    double screenHeight,
  ) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.024),
        _buildLevelCard(
          context,
          'A1',
          createCircularBox('assets/a1.webp'),
          wordListProvider.getWords('A1').isEmpty,
          const OneCard(
            level: 'A1',
          ),
          progressProvider.progressValue,
          screenWidth,
          screenHeight,
        ),
        SizedBox(width: screenWidth * 0.01),
        _buildLevelCard(
          context,
          'A2',
          createCircularBox('assets/a2.webp'),
          wordListProvider.getWords('A2').isEmpty,
          const TwoCard(
            level: 'A2',
          ),
          progressProvider.progressValue1,
          screenWidth,
          screenHeight,
        ),
      ],
    );
  }

  Widget _buildLevelRow1(
    BuildContext context,
    WordProvider wordListProvider,
    ProgressProvider progressProvider,
    double screenWidth,
    double screenHeight,
  ) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.024),
        _buildLevelCard(
          context,
          'B1',
          createCircularBox('assets/a3.webp'),
          wordListProvider.getWords('B1').isEmpty,
          const ThreCard(
            level: 'B1',
          ),
          progressProvider.progressValue2,
          screenWidth,
          screenHeight,
        ),
        SizedBox(width: screenWidth * 0.01),
        _buildLevelCard(
          context,
          'B2',
          createCircularBox('assets/a4.webp'),
          wordListProvider.getWords('B2').isEmpty,
          const FourCard(level: 'B2'),
          progressProvider.progressValue3,
          screenWidth,
          screenHeight,
        ),
      ],
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    String level,
    BoxDecoration decoration,
    bool isCompleted,
    Widget nextPage,
    double progressValue,
    double screenWidth,
    double screenHeight,
  ) {
    return SizedBox(
      width: screenWidth * 0.47,
      height: screenHeight * 0.2,
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: hardgreen,
                content: Text(
                  'Bu bölümü tamamladınız',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: whites),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => nextPage));
          }
        },
        child: Center(
          child: Stack(
            children: [
              Container(
                width: screenWidth * 0.4,
                height: screenHeight * 0.179,
                decoration: decoration,
                child: CircularProgressIndicator(
                  strokeAlign: 2,
                  strokeWidth: 7,
                  value: progressValue,
                  backgroundColor: easgreen,
                  valueColor: AlwaysStoppedAnimation<Color>(yellow),
                ),
              ),
              Positioned(
                right: 60,
                bottom: 65,
                child: Text(level, style: _textStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalLevel(
    BuildContext context,
    WordProvider wordListProvider,
    ProgressProvider progressProvider,
    double screenWidth,
    double screenHeight,
  ) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.25),
        _buildLevelCard(
          context,
          'C1',
          createCircularBox('assets/a5.webp'),
          wordListProvider.getWords('C1').isEmpty,
          const FiveCard(
            level: 'C1',
          ),
          progressProvider.progressValue4,
          screenWidth,
          screenHeight,
        ),
      ],
    );
  }
}
