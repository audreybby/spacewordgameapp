import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/page/character_selection.dart';
import 'package:spacewordgameapp/page/login_screen.dart';
import 'package:spacewordgameapp/page/splash_screen.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
// import 'package:spaceword/page/home_page.dart';

// import 'package:spacewordgameapp/page/auth_page.dart';
// import 'package:spacewordgameapp/page/character_customization_page.dart';
import 'package:spacewordgameapp/page/choose_level_page.dart';
import 'package:spacewordgameapp/provider.dart';
// import 'package:spacewordgameapp/audioplayers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final audioService = AudioService();
  // await audioService.playBackgroundMusic('audio/backsound.mp3');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (context) => CharacterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spaceword',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const WelcomePage(),
        '/login': (context) => GoogleLoginPage(),
        // '/custom': (context) => const CharacterCustomizationPage(),
        '/charselect': (context) => const CharacterSelectionPage(),
        '/level': (context) => const GameLevelsPage(),
      },
    );
  }
}
