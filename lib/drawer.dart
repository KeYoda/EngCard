import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/screens/ai_chat_screen.dart';
import 'package:eng_card/screens/fav_card.dart';
import 'package:eng_card/screens/practice_card.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/blanc_test.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:eng_card/screens/test/voice_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void _shareApp(BuildContext context) async {
  await Share.share(
    'Hey, check out this awesome app! https://example.com',
    subject: 'Check out this app!',
  );
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  List<Widget> buildListTiles(BuildContext context, List<Words> combinedWords) {
    final List<Widget> tiles = [
      _createDrawerTile(
        context,
        icon: Icons.home,
        text: ' Ana Sayfa',
        onTap: () => Navigator.pop(context),
      ),
      _createDrawerTile(
        context,
        icon: Icons.favorite,
        text: ' Favoriler',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FavouritePage()));
        },
      ),
      _createDrawerTile(
        context,
        icon: Icons.view_carousel_rounded,
        text: ' Alıştırma',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PracticeCard()));
        },
      ),
      _createExpansionTile(context, combinedWords),
      Divider(thickness: 1.h, color: easgreen),
      Padding(
        padding: EdgeInsets.only(left: 110.5.w),
        child: Text(
          'İletişim',
          style: TextStyle(
              color: Colors.orange,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold),
        ),
      ),
      Divider(thickness: 1.h, color: easgreen),
      _createDrawerTile(
        context,
        icon: Icons.mail,
        text: ' Email',
        onTap: () => _launchEmail(),
      ),
      _createDrawerTile(context, icon: Icons.person, text: 'ChatBot',
          onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      }),
      _createDrawerTile(
        context,
        icon: Icons.share,
        text: ' Paylaş',
        onTap: () => _shareApp(context),
      ),
      SizedBox(height: 115.h),
      ListTile(
        leading: Icon(
          Icons.delete,
          size: 17.sp,
          color: orange,
        ),
        title: Text(
          'İlerlemeyi Sil',
          style: TextStyle(
              color: orange, fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.pop(context);
          showDeleteConfirmationDialog(context);
        },
      ),
    ];
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    List<Words> combinedWords = []
      ..addAll(wordsList)
      ..addAll(wordsList2)
      ..addAll(wordsList3)
      ..addAll(wordsList4)
      ..addAll(wordsList5);

    // double screenHeight = ScreenUtil().screenHeight;

    return Drawer(
      child: Column(
        children: [
          _createDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: buildListTiles(context, combinedWords),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [medgreen, hardgreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 250.w,
            height: 300.h,
            child: Image.asset(
              'assets/logoback.png',
              height: 300.h,
              width: 300.w,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 19.sp,
        color: Colors.orange,
      ),
      title: Text(
        text,
        style: TextStyle(
            color: const Color.fromARGB(255, 8, 61, 17),
            fontSize: 13.sp,
            fontWeight: FontWeight.w400),
      ),
      onTap: onTap,
    );
  }

  Widget _createExpansionTile(
    BuildContext context,
    List<Words> combinedWords,
  ) {
    return ExpansionTile(
      backgroundColor: yellow.withOpacity(0.1),
      leading: Icon(
        Icons.perm_device_information,
        color: Colors.orange,
        size: 19.sp,
      ),
      title: Text(
        ' Test',
        style: TextStyle(
            color: const Color.fromARGB(255, 8, 61, 17),
            fontSize: 13.sp,
            fontWeight: FontWeight.bold),
      ),
      iconColor: yellow,
      children: <Widget>[
        _createExpansionTileItem(
          context,
          icon: Icons.question_answer,
          text: 'Boşluk Doldurma',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlancTestScreen(
                  level: '',
                  onComplete: () {},
                  words: combinedWords,
                ),
              ),
            );
          },
        ),
        _createExpansionTileItem(
          context,
          icon: Icons.question_mark,
          text: 'Kelime anlamı',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TestWord(
                  onComplete: () {},
                  words: combinedWords,
                ),
              ),
            );
          },
        ),
        _createExpansionTileItem(
          context,
          icon: Icons.record_voice_over,
          text: 'Dinleme',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VoiceTest(
                  level: '',
                  onComplete: () {},
                  words: combinedWords,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _createExpansionTileItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 13.sp,
        color: Colors.orange,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: const Color.fromARGB(255, 8, 61, 17),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
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

void showDeleteConfirmationDialog(BuildContext context) {
  final deleteProgress = context.read<ProgressProvider>();
  final resetScore = context.read<ScoreProvider>();
  final resetWords = context.read<WordProvider>();
  final resetTestList = context.read<ListProgressProvider>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: hardgreen,
        content: Text(
          'İlerlemeyi silmek istediğinizden emin misiniz?',
          style: TextStyle(color: whites),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'İptal',
              style: TextStyle(color: whites),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteProgress.resetProgressLength();
              resetTestList.resetWordsProgress(wordProvider: resetWords);
              deleteProgress.resetProgress();
              resetScore.resetTotalScore();
              resetWords.resetList('A1');
              resetWords.resetList('A2');
              resetWords.resetList('B1');
              resetWords.resetList('B2');
              resetWords.resetList('C1');

              Navigator.of(context).pop();
            },
            child: Text(
              'Evet, Sil',
              style: TextStyle(color: orange),
            ),
          ),
        ],
      );
    },
  );
}
