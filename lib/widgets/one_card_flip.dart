// import 'package:eng_card/provider/wordshare_prov.dart';
// import 'package:eng_card/screens/six_screen.dart';
// import 'package:flip_card/flip_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class OneCardFlip extends StatelessWidget {
//   const OneCardFlip({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var flipWords = Provider.of<WordProvider>(context);

//     return FlipCard(
//       front: Container(
//         padding: const EdgeInsets.all(30),
//         decoration: BoxDecoration(
//           color: whites,
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0.0, 0.4),
//               blurRadius: 0.5,
//             ),
//           ],
//           borderRadius: BorderRadius.circular(36),
//         ),
//         height: 180,
//         width: 310,
//         child: Stack(
//           children: [
//             Positioned(
//               bottom: 91,
//               child: Text(
//                 '"',
//                 style: TextStyle(fontSize: 25, color: hardgreen),
//               ),
//             ),
//             Center(
//               child: Text(
//                 '${flipWords.wordsListOne[flipWords.lastIndex].front} ',
//                 maxLines: 3,
//                 style: TextStyle(fontSize: 18, color: yellow),
//               ),
//             ),
//             Positioned(
//               right: 8,
//               top: 105,
//               child: Text(
//                 '"',
//                 style: TextStyle(fontSize: 25, color: hardgreen),
//               ),
//             )
//           ],
//         ),
//       ),
//       back: Container(
//         padding: const EdgeInsets.all(30),
//         decoration: BoxDecoration(
//           color: whites,
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0.0, 0.4),
//               blurRadius: 0.5,
//             ),
//           ],
//           borderRadius: BorderRadius.circular(36),
//         ),
//         height: 180,
//         width: 310,
//         child: Stack(
//           children: [
//             Positioned(
//               bottom: 91,
//               child: Text(
//                 '"',
//                 style: TextStyle(fontSize: 25, color: hardgreen),
//               ),
//             ),
//             Center(
//               child: Text(
//                 '${flipWords.wordsListOne[flipWords.lastIndex].back} ',
//                 maxLines: 3,
//                 style: TextStyle(fontSize: 18, color: yellow),
//               ),
//             ),
//             Positioned(
//               right: 8,
//               top: 105,
//               child: Text(
//                 '"',
//                 style: TextStyle(fontSize: 25, color: hardgreen),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
