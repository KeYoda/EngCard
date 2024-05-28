// import 'package:eng_card/provider/progres_prov.dart';
// import 'package:eng_card/provider/scor_prov.dart';
// import 'package:eng_card/provider/wordshare_fiveprov.dart';
// import 'package:eng_card/provider/wordshare_fourprov.dart';
// import 'package:eng_card/provider/wordshare_prov.dart';
// import 'package:eng_card/provider/wordshare_threprov.dart';
// import 'package:eng_card/provider/wordshare_twoprov.dart';
// import 'package:eng_card/screens/six_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Settings extends StatefulWidget {
//   const Settings({super.key});
//   @override
//   State<Settings> createState() => _SettingsState();
// }

// class _SettingsState extends State<Settings> {
//   bool switchList = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whites,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: orange),
//         backgroundColor: whites,
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Divider(
//               color: medgreen,
//             ),
//             ListTile(
//               title: Text(
//                 'İlerlemeyi sil',
//                 style: TextStyle(color: hardgreen),
//               ),
//               trailing: IconButton(
//                 onPressed: () {
//                   showDeleteConfirmationDialog(context);
//                 },
//                 icon: const Icon(Icons.delete),
//               ),
//             ),
//             Divider(
//               color: medgreen,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void showDeleteConfirmationDialog(BuildContext context) {
//     var deleteProgress = Provider.of<ProgressProvider>(context, listen: false);
//     var resetScore = Provider.of<ScoreProvider>(context, listen: false);
//     var resetWords = Provider.of<WordProvider>(context, listen: false);
//     var resetWords2 = Provider.of<WordProvider2>(context, listen: false);
//     var resetWords3 = Provider.of<WordProvider3>(context, listen: false);
//     var resetWords4 = Provider.of<WordProvider4>(context, listen: false);
//     var resetWords5 = Provider.of<WordProvider5>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: hardgreen,
//           content: Text(
//             'İlerlemeyi silmek istediğinizden emin misiniz?',
//             style: TextStyle(color: whites),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'İptal',
//                 style: TextStyle(color: whites),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteProgress.resetProgress();
//                 resetScore.resetTotalScore();
//                 resetWords.resetList();
//                 resetWords2.resetList2();
//                 resetWords3.resetList3();
//                 resetWords4.resetList4();
//                 resetWords5.resetList5();

//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Evet, Sil',
//                 style: TextStyle(color: orange),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
