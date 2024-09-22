import 'package:flutter/material.dart';

import '../constants/colors/color_constants.dart';

class MeditoHugeIcon extends StatelessWidget {
  const MeditoHugeIcon({
    super.key,
    required this.icon,
    this.color = ColorConstants.white,
    this.size = 24,
  });

  final String icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}
