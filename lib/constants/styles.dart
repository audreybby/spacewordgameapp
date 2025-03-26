import 'package:flutter/material.dart';

// Colors
const Color customButtonColor = Color(0xFFFFF50B);
const Color customButtonBgColor = Color(0xFFAE0AFB);
const Color customButtonBorderColor = Color(0xFFD1BEDA);

const Color brandColorPurple = Color(0xFFAE0AFB);
const Color brandColorYellow = Color(0xFFFFC700);
const Color brandColorGreen = Color(0xFF18F513);
const Color brandColorRed = Color(0xFFF82609);

// Gradients
const gradient_1 = [Color(0xFF0D006F), Color(0xFF9614D0)];
const gradient_2 = [Color(0xFF0D006F), Color(0xFF7509FE), Color(0xFF9614D0)];

// Text Styles
const TextStyle welcomeTextStyle = TextStyle(
  fontFamily: 'FontdinerSwanky',
  color: customButtonColor,
  fontSize: 50.0,
  fontWeight: FontWeight.bold,
  shadows: [
    Shadow(
      offset: Offset(2.0, 2.0),
      blurRadius: 3.0,
      color: Colors.black45,
    ),
  ],
);
