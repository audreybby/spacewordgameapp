import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/navigation.dart';

// ignore: unused_import
import 'package:spacewordgameapp/page/character_customization_page.dart';
import 'package:spacewordgameapp/page/level_page.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/settings.dart';
import 'package:spacewordgameapp/soundefx.dart';

class GameLevelsPage extends StatefulWidget {
  const GameLevelsPage({super.key});

  @override
  State<GameLevelsPage> createState() => _GameLevelsPageState();
}

class _GameLevelsPageState extends State<GameLevelsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      coinProvider.loadCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NoBackPage(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Consumer<CoinProvider>(
                builder: (context, coinProvider, child) {
                  if (coinProvider.isLoading) {
                    return const SizedBox(
                      width: 80,
                      height: 44,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Text(
                        '${coinProvider.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.deepOrangeAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.asset("assets/image/coins.png"),
                        ),
                        onPressed: () {},
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
            image: DecorationImage(
              image: AssetImage("assets/image/LevelSelection.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/image/LogoSpaceword.png', width: 220),
                const SizedBox(height: 50),

                // Tombol level
                Column(
                  children: [
                    _buildLevelButton('EASY', Colors.green, const EasyLevel()),
                    const SizedBox(height: 20),
                    _buildLevelButton(
                        'MEDIUM', Colors.yellow, const MediumLevel()),
                    const SizedBox(height: 20),
                    _buildLevelButton('HARD', Colors.red, const HardLevel()),
                  ],
                ),

                const SizedBox(height: 45),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleIcon("assets/image/custom.png", () async {
                      await SoundEffects().pop();
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CharacterCustomizationPage()),
                      );
                    }, size: 110),
                    _buildCircleIcon("assets/image/home.png", () async {
                      await SoundEffects().pop();
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(builder: (_) => WelcomePage()),
                      );
                    }, size: 115),
                    _buildCircleIcon("assets/image/setting.png", () async {
                      await SoundEffects().pop();
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) => SettingsModal(),
                      );
                    }, size: 110),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(String label, Color color, Widget destination) {
    return GestureDetector(
      onTap: () async {
        await SoundEffects().click();
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'FontdinerSwanky',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon(String path, VoidCallback onTap, {double size = 90}) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
