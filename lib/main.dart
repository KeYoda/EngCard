import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/firebase_options.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

final theme = ThemeData(
  useMaterial3: true,
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 255, 251, 230),
  ),
);

Future<void> checkAndRequestPermissions() async {
  var microphoneStatus = await Permission.microphone.request();
  var storageStatus = await Permission.storage.request();

  if (microphoneStatus.isGranted && storageStatus.isGranted) {
  } else {
    Map<Permission, PermissionStatus> status = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (status[Permission.microphone] == PermissionStatus.granted &&
        status[Permission.storage] == PermissionStatus.granted) {
    } else {}
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteList()),
        ChangeNotifierProvider(create: (_) => WordProvider()),
        ChangeNotifierProvider(create: (_) => WordProvider2()),
        ChangeNotifierProvider(create: (_) => WordProvider3()),
        ChangeNotifierProvider(create: (_) => WordProvider4()),
        ChangeNotifierProvider(create: (_) => WordProvider5()),
      ],
      child: const MyApp(),
    ),
  );
  await checkAndRequestPermissions();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromARGB(255, 255, 251, 230),
      ),
    );

    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const Scaffold(
          body: StartScreen(),
        ),
      ),
    );
  }
}
