import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class YaplucaLogo extends StatelessWidget {
  final double height;

  const YaplucaLogo({
    Key? key,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logowhite2.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
