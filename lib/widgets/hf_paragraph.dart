import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HFParagrpah extends StatelessWidget {
  const HFParagrpah({
    Key? key,
    this.text = 'Paragraph',
    this.size = 3,
    this.maxLines = 3,
    this.lineHeight = 1.2,
    this.textAlign = TextAlign.left,
    this.fontWeight = FontWeight.w400,
    this.color = const Color.fromRGBO(255, 255, 255, 1),
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final int size;
  final String text;
  final double lineHeight;
  final int maxLines;
  final TextAlign textAlign;
  final Color color;
  final Color backgroundColor;
  final FontWeight fontWeight;

  double _getSize(int size) {
    List<double> sizes = [
      0, // 0
      6.0, // 1
      7.0, // 2
      8.0, // 3
      9.0, // 4
      10.0, // 5
      11.0, // 6
      12.0, // 7
      13.0, // 8
      14.0, // 9
      15.0, // 10
      18.0, // 11
    ];

    return sizes[size];
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: GoogleFonts.manrope(
        textStyle: TextStyle(
          backgroundColor: backgroundColor,
          fontSize: _getSize(size),
          color: color,
          height: lineHeight,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
