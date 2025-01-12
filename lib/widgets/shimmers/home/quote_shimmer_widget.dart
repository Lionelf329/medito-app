import 'package:medito/constants/constants.dart';
import 'package:flutter/material.dart';

import '../widgets/box_shimmer_widget.dart';

class QuoteShimmerWidget extends StatelessWidget {
  const QuoteShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding16),
      child: BoxShimmerWidget(
        height: 150,
        width: size.width,
        borderRadius: 14,
      ),
    );
  }
}
