import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool padding;

  const AppLogo({
    super.key,
    this.size = 40,
    this.padding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(size * 0.4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
