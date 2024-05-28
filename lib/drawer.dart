import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/test_screen.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenUtil().screenHeight;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
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
                  width: 160.sp,
                  height: 200.sp,
                  child: Image.asset('assets/TestLog1.png'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.home,
                    size: 19,
                    color: yellow,
                  ),
                  title: Text(
                    '  Ana Sayfa',
                    style: TextStyle(color: yellow, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                //
                ListTile(
                  leading: Icon(
                    Icons.favorite,
                    size: 19,
                    color: yellow,
                  ),
                  title: Text(
                    '  Favoriler',
                    style: TextStyle(color: yellow, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.popAndPushNamed(context, routeName)
                  },
                ),
                ListTile(
                    leading: Icon(
                      Icons.restore_from_trash_rounded,
                      size: 19,
                      color: yellow,
                    ),
                    title: Text(
                      '  İlerlemeyi Sil',
                      style: TextStyle(color: yellow, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteConfirmationDialog(context);
                    }),
                ExpansionTile(
                  leading: Icon(
                    Icons.perm_device_information,
                    color: yellow,
                    size: 19,
                  ),
                  title: Text(
                    '  Test',
                    style: TextStyle(color: yellow, fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.arrow_drop_down,
                    color: yellow,
                  ),
                  children: <Widget>[
                    ListTile(
                      title: const Text(
                        'Cümle tamamlama',
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TestScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Kelime anlamı',
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const TestWord(),
                        ));
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Kurumsal',
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, "/kurumsal");
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Divider(
                  thickness: 2,
                  color: easgreen,
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 18.5,
                    ),
                    Text(
                      'İletişim',
                      style: TextStyle(color: medgreen, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                ListTile(
                  leading: Icon(
                    Icons.mail,
                    size: 19,
                    color: yellow,
                  ),
                  title: Text(
                    '  Email',
                    style: TextStyle(color: yellow, fontSize: 14),
                  ),
                  onTap: () async {
                    String email = Uri.encodeComponent("keyodapp@gmail.com");
                    String subject = Uri.encodeComponent('Öneri ve Şikayet');
                    Uri mail = Uri.parse("mailto:$email?subject=$subject");
                    if (await launchUrl(mail)) {
                    } else {}
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.share,
                    size: 19,
                    color: yellow,
                  ),
                  title: Text(
                    '  Paylaş',
                    style: TextStyle(color: yellow, fontSize: 14),
                  ),
                  onTap: () {
                    _shareApp(context);
                  },
                ),
                SizedBox(
                  height: screenHeight * 0.20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showDeleteConfirmationDialog(BuildContext context) {
  var deleteProgress = Provider.of<ProgressProvider>(context, listen: false);
  var resetScore = Provider.of<ScoreProvider>(context, listen: false);
  var resetWords = Provider.of<WordProvider>(context, listen: false);
  var resetWords2 = Provider.of<WordProvider2>(context, listen: false);
  var resetWords3 = Provider.of<WordProvider3>(context, listen: false);
  var resetWords4 = Provider.of<WordProvider4>(context, listen: false);
  var resetWords5 = Provider.of<WordProvider5>(context, listen: false);

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
              deleteProgress.resetProgress();
              resetScore.resetTotalScore();
              resetWords.resetList();
              resetWords2.resetList2();
              resetWords3.resetList3();
              resetWords4.resetList4();
              resetWords5.resetList5();

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
