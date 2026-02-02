import 'package:eng_card/data/gridview.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/test/test_word_screen.dart';
import 'package:flutter/material.dart';
import 'package:eng_card/data/fivewords_data.dart';
import 'package:eng_card/data/fourwords_data.dart';
import 'package:eng_card/data/words_data.dart';
import 'package:eng_card/data/secwords_data.dart';
import 'package:eng_card/data/thirdwords_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:eng_card/provider/progres_prov.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  List<Words> filterWordsByLevel(List<Words> allWords, String level) {
    return allWords.where((word) => word.list == level).toList();
  }

  @override
  Widget build(BuildContext context) {
    var progressProv = Provider.of<ProgressProvider>(context);
    var listProgressProv = Provider.of<ListProgressProvider>(context);

    BoxDecoration createCircularBox(String imagePath) {
      return BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            alignment: Alignment.center),
      );
    }

    final List<Words> allWords = []
      ..addAll(wordsList)
      ..addAll(wordsList2)
      ..addAll(wordsList3)
      ..addAll(wordsList4)
      ..addAll(wordsList5);

    Widget _listTile(BuildContext context, String level, double progressValue,
        BoxDecoration decoration, Widget navigate, int length) {
      return Container(
        decoration: BoxDecoration(
          gradient: SweepGradient(
            colors: [yellow, whites],
          ),
        ),
        margin: const EdgeInsets.only(top: 60),
        child: ListTile(
          title: Text(
            '                      $level',
            style: TextStyle(
              color: orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '                      $length/${progressProv.remainingQuestions[level]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => navigate,
                ),
              );
            },
            child: Icon(
              Icons.arrow_forward_ios,
              color: whites,
            ),
          ),
          leading: Container(
            decoration: decoration,
            height: 55.h,
            width: 55.w,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              value: progressValue,
              backgroundColor: medgreen,
              valueColor: AlwaysStoppedAnimation<Color>(yellow),
            ),
          ),
        ),
      );
    }

    Widget _columnTile(
      BuildContext context,
      ProgressProvider progressProvider,
      ListProgressProvider listProgressProvider,
    ) {
      return Column(
        children: [
          _listTile(
              context,
              'A1',
              progressProvider.getCircleProgress('A1'),
              createCircularBox('assets/a1.webp'),
              TestWord(
                level: 'A1',
                words: filterWordsByLevel(allWords, 'A1'),
                onComplete: () {
                  progressProvider.completeQuestion('A1');
                  listProgressProv.decreaseProgress('A1');
                },
              ),
              wordsList.length),
          _listTile(
              context,
              'A2',
              progressProvider.getCircleProgress('A2'),
              createCircularBox('assets/a2.webp'),
              TestWord(
                level: 'A2',
                words: filterWordsByLevel(allWords, 'A2'),
                onComplete: () {
                  progressProvider.completeQuestion('A2');
                  listProgressProv.decreaseProgress('A2');
                },
              ),
              wordsList2.length),
          _listTile(
              context,
              'B1',
              progressProvider.getCircleProgress('B1'),
              createCircularBox('assets/a3.webp'),
              TestWord(
                level: 'B1',
                words: filterWordsByLevel(allWords, 'B1'),
                onComplete: () {
                  progressProvider.completeQuestion('B1');
                  listProgressProv.decreaseProgress('B1');
                },
              ),
              wordsList3.length),
          _listTile(
              context,
              'B2',
              progressProvider.getCircleProgress('B2'),
              createCircularBox('assets/a4.webp'),
              TestWord(
                level: 'B2',
                words: filterWordsByLevel(allWords, 'B2'),
                onComplete: () {
                  progressProvider.completeQuestion('B2');
                  listProgressProv.decreaseProgress('B2');
                },
              ),
              wordsList4.length),
          _listTile(
            context,
            'C1',
            progressProvider.getCircleProgress('C1'),
            createCircularBox('assets/a5.webp'),
            TestWord(
              level: 'C1',
              words: filterWordsByLevel(allWords, 'C1'),
              onComplete: () {
                progressProvider.completeQuestion('C1');
                listProgressProv.decreaseProgress('C1');
              },
            ),
            wordsList5.length,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: whites,
      appBar: AppBar(
        title: const Text('Test Ayarları'),
        centerTitle: true,
        iconTheme: IconThemeData(color: orange),
        backgroundColor: whites,
      ),
      body: Center(
        child: _columnTile(context, progressProv, listProgressProv),
      ),
    );
  }
}
