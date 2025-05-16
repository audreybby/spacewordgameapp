import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spacewordgameapp/constants/styles.dart';
// ignore: unused_import
import 'package:spacewordgameapp/page/character_customization_page.dart';
import 'package:spacewordgameapp/page/level_page.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/settings.dart';

class GameLevelsPage extends StatelessWidget {
  const GameLevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            "assets/image/back.png",
            width: 50,
            height: 50,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Consumer<CoinProvider>(
              builder: (context, coinProvider, child) {
                return Row(
                  children: [
                    Text(
                      '${coinProvider.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          "assets/image/jam_coin.png",
                          fit: BoxFit.contain,
                          semanticLabel: "Ikon koin",
                        ),
                      ),
                      onPressed: () {
                        debugPrint('Coin icon pressed');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E0C5A), Color(0xFF631AC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/LogoSpaceword.png',
                width: 200,
              ),
              const SizedBox(height: 60),

              // Tombol level
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDifficultyButton(
                    context,
                    'EASY',
                    brandColorGreen,
                    100,
                    140,
                    const EasyLevel(),
                  ),
                  const SizedBox(width: 20),
                  _buildDifficultyButton(
                    context,
                    'MEDIUM',
                    brandColorYellow,
                    140,
                    180,
                    const MediumLevel(),
                  ),
                  const SizedBox(width: 20),
                  _buildDifficultyButton(
                    context,
                    'HARD',
                    brandColorRed,
                    100,
                    140,
                    const HardLevel(),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              // Ikon navigasi bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsModal()),
                      );
                    },
                    child: _buildCircleIcon("assets/image/Group.png"),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CharacterCustomizationPage()),
                      );
                    },
                    child: _buildCircleIcon(
                        "assets/image/material-symbols_home.png"),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsModal()),
                      );
                    },
                    child: _buildCircleIcon(
                        "assets/image/tdesign_setting-filled.png"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String text,
    Color color,
    double width,
    double height,
    Widget destinationPage,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey, width: 5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon(String imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey, width: 5),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          color: Colors.yellow,
        ),
      ),
    );
  }
}
