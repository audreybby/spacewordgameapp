import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/page/splash_screen.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
// import 'package:spaceword/page/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spacewordgameapp/page/register_page.dart';
import 'package:spacewordgameapp/page/auth_page.dart';
import 'package:spacewordgameapp/page/character_customization_page.dart';
import 'package:spacewordgameapp/page/choose_level_page.dart';
import 'package:spacewordgameapp/provider.dart';
// import 'package:spacewordgameapp/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  String sbUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String sbKey = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: sbUrl, anonKey: sbKey);

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
        '/': (context) => const StartPage(),
        '/auth': (context) => const AuthPage(),
        '/custom': (context) => const CharacterCustomizationPage(),
        '/level': (context) => const GameLevelsPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
