import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:spacewordgameapp/soundefx.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SoundEffects().init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AudioPlayer.global.setAudioContext(
    AudioContext(
      android: AudioContextAndroid(
        // HAPUS isSpeakerphoneOn
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProxyProvider<UserAuthProvider, CoinProvider>(
          create: (_) => CoinProvider(''),
          update: (_, auth, previous) {
            final userId = auth.userId ?? '';
            if (previous == null || previous.userId != userId) {
              return CoinProvider(userId);
            }
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<UserAuthProvider, CharacterProvider>(
          create: (_) => CharacterProvider(''),
          update: (_, auth, previous) {
            final userId = auth.userId ?? '';
            if (previous == null || previous.userId != userId) {
              return CharacterProvider(userId);
            }
            return previous;
          },
        ),
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
