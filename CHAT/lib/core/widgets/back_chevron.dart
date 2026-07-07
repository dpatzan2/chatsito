import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BackChevron extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const BackChevron(this.onTap, {super.key, this.color = C.ink});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
    );
  }
}
