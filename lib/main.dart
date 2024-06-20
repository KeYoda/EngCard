import 'package:eng_card/data/favorite_list.dart';
import 'package:eng_card/firebase_options.dart';
import 'package:eng_card/provider/progres_prov.dart';
import 'package:eng_card/provider/scor_prov.dart';
import 'package:eng_card/provider/wordshare_fiveprov.dart';
import 'package:eng_card/provider/wordshare_fourprov.dart';
import 'package:eng_card/provider/wordshare_prov.dart';
import 'package:eng_card/provider/wordshare_threprov.dart';
import 'package:eng_card/provider/wordshare_twoprov.dart';
import 'package:eng_card/screens/six_screen.dart';
import 'package:eng_card/screens/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

final theme = ThemeData(
  useMaterial3: true,
  drawerTheme: DrawerThemeData(
    backgroundColor: whites,
  ),
);

Future<void> checkAndRequestPermissions() async {
  var microphoneStatus = await Permission.microphone.request();
  var storageStatus = await Permission.storage.request();

  if (microphoneStatus.isGranted && storageStatus.isGranted) {
    // İzinler verilmiş durumda
  } else {
    Map<Permission, PermissionStatus> status = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (status[Permission.microphone] == PermissionStatus.granted &&
        status[Permission.storage] == PermissionStatus.granted) {
      // İzinler başarıyla verildi
    } else {
      // İzinler reddedildi
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    // Hata detaylarını loglama
    print(details.exceptionAsString());
    print(details.stack);

    // Kullanıcıya gösterilecek hata mesajını ayarlama
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bir Hata Oluştu'),
            content:
                const Text('Bir hata meydana geldi. Lütfen tekrar deneyin.'),
            actions: [
              TextButton(
                child: const Text('Kapat'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
        ChangeNotifierProvider(create: (_) => ListProgressProvider()),
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
    return ScreenUtilInit(
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                systemNavigationBarColor: whites,
              ),
              child: const StartScreen(),
            ),
          ),
        );
      },
    );
  }
}
