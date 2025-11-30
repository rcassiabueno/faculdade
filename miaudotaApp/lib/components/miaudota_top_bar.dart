import 'package:flutter/material.dart';

class MiaudotaTopBar extends StatelessWidget {
  final String titulo;
  final bool showBackButton;
  final int maxLines;

  const MiaudotaTopBar({
    super.key,
    required this.titulo,
    this.showBackButton = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final logoHeight = width <= 320 ? 36.0 : (width <= 400 ? 44.0 : 50.0);
    final titleFontSize = width <= 320 ? 14.0 : (width <= 400 ? 16.0 : 18.0);
    final titleFontWeight = width <= 320
        ? FontWeight.w400
        : (width <= 400 ? FontWeight.w500 : FontWeight.w600);
    final horizontalPadding = width <= 320
        ? 36.0
        : (width <= 400 ? 48.0 : 64.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFE0B5),
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left logo
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/images/logo.png', height: logoHeight),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PoetsenOne',
                    fontSize: titleFontSize,
                    fontWeight: titleFontWeight,
                    color: Color(0xFF1D274A),
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: showBackButton
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Color(0xFF1D274A),
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : const SizedBox(width: 48),
            ),
          ],
        ),
      ),
    );
  }
}
