import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HFHeading extends StatelessWidget {
  const HFHeading({
    Key? key,
    this.text = 'Heading',
    this.size = 3,
    this.lineHeight = 1.2,
    this.maxLines = 2,
    this.textAlign = TextAlign.left,
    this.fontWeight = FontWeight.w800,
    this.color = const Color.fromRGBO(255, 255, 255, 1),
  }) : super(key: key);

  final String text;
  final int size;
  final FontWeight fontWeight;
  final double lineHeight;
  final TextAlign textAlign;
  final int maxLines;
  final Color color;

  double _getSize(int size) {
    List<double> sizes = [
      0, // 0
      11.0, // 1
      14.0, // 2
      16.0, // 3
      18.0, // 4
      20.0, // 5
      22.0, // 6
      24.0, // 7
      26.0, // 8
      28.0, // 9
      36.0, // 10
    ];

    return sizes[size];
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: true,
      style: GoogleFonts.getFont(
        'Manrope',
        textStyle: TextStyle(
          fontSize: _getSize(size),
          fontWeight: fontWeight,
          letterSpacing: -0.5,
          color: color,
          height: lineHeight,
        ),
      ),
    );
  }
}
