import 'package:flutter/material.dart';

class NoBackPage extends StatelessWidget {
  final Widget child;

  const NoBackPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: child,
    );
  }
}
