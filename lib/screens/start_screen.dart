import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:flutter/material.dart';
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
    bool? isFirstRun = prefs.getBool('isFirstRun');

    if (isFirstRun == null || isFirstRun) {
      prefs.setBool('isFirstRun', false);
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
    var wordLists1 = Provider.of<WordProvider2>(context);
    var wordLists2 = Provider.of<WordProvider3>(context);
    var wordLists3 = Provider.of<WordProvider4>(context);
    var wordLists4 = Provider.of<WordProvider5>(context);

    return Scaffold(
      backgroundColor: whites,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 5),
            Text(
              'Hoş Geldiniz',
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, color: orange),
            ),
            Container(
              height: 300,
              child: Image.asset('assets/TestLog1.png'),
            ),
            // Açıklama metni
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Eğitim, hayat boyu süren bir serüven ve keşif yolculuğudur. Bu yolculuğa beni de dahil etmek için aşağıdaki butona basabilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: medgreen),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                wordLists4.resetList5();
                wordLists3.resetList4();
                wordLists2.resetList3();
                wordLists1.resetList2();
                wordLists.resetList();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SixScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                foregroundColor: Colors.white, // Buton rengi
                backgroundColor: hardgreen, // Yazı rengi
              ),
              child: const Text(
                'Başla',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
