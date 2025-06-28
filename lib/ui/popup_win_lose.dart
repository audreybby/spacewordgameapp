import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/page/character_customization_page.dart';

// import 'package:spacewordgameapp/page/character_customization_page.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/soundefx.dart';

enum PopupType { win, lose }

class PopupWinLose extends StatefulWidget {
  final int score;
  final PopupType type;
  final Widget retryPage;

  const PopupWinLose({
    super.key,
    required this.score,
    required this.type,
    required this.retryPage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<PopupWinLose>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type == PopupType.lose) {
        SoundEffects().lose();
      } else {
        SoundEffects().win();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        // <-- Tambahkan ini
        color: Colors.transparent, // penting untuk transparansi pop-up
        child: ScaleTransition(
          scale: _animation,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _popupBackground(),
              _banner(),
              _buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popupBackground() {
    return Container(
      width: 300,
      height: 320,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 251, 227, 255),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<CharacterProvider>(
            builder: (context, characterProvider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(characterProvider.selectedBody, width: 100),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            "Score: ${widget.score}",
            style: const TextStyle(
              fontSize: 25,
              color: Colors.purple,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _banner() {
    String bannerText = widget.type == PopupType.win ? "WIN" : "LOSE";
    Color bannerColor =
        widget.type == PopupType.win ? Colors.green : Colors.red;

    return Positioned(
      top: -30,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          bannerText,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Positioned(
      bottom: -25,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.checkroom,
            onPressed: () async {
              await SoundEffects().pop();
              _navigateTo(context, CharacterCustomizationPage());
            },
          ),
          const SizedBox(width: 8),
          _buildButton(
            text: widget.type == PopupType.win ? "PLAY AGAIN" : "RETRY",
            onPressed: () async {
              await SoundEffects().pop();
              _navigateTo(context, widget.retryPage);
            },
          ),
          const SizedBox(width: 8),
          _buildButton(
            icon: Icons.home,
            onPressed: () async {
              await SoundEffects().pop();
              _navigateTo(context, const WelcomePage());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    String? text,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: const Color.fromARGB(255, 156, 39, 176),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: text != null
          ? Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            )
          : Icon(
              icon,
              size: 25,
              color: Colors.white,
            ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
