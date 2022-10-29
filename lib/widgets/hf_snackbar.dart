import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:another_flushbar/flushbar.dart';

class HFSnackbar extends StatelessWidget {
  const HFSnackbar({
    Key? key,
    this.text = 'Snackbar',
    this.size = 7,
    this.lineHeight = 1.2,
    this.maxLines = 1,
    this.textAlign = TextAlign.center,
    this.color = const Color.fromRGBO(219, 203, 140, 1),
  }) : super(key: key);

  final String text;
  final int size;
  final double lineHeight;
  final TextAlign textAlign;
  final int maxLines;
  final Color color;

  double _getSize(int size) {
    List<double> sizes = [
      0, // 0
      12.0, // 1
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
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color,
              boxShadow: getShadow(),
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            child: HFParagrpah(
              textAlign: TextAlign.center,
              text: text,
              size: size,
              maxLines: maxLines,
              color: HFColors().whiteColor(),
            ),
          ),
        ],
      ),
    );
  }
}

SnackBar getSnackBar({
  String text = 'Snackbar',
  int size = 7,
  double lineHeight = 1.2,
  TextAlign textAlign = TextAlign.center,
  int maxLines = 1,
  Color color = const Color.fromRGBO(219, 203, 140, 1),
}) {
  return SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: color,
            boxShadow: getShadow(),
            borderRadius: const BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          child: HFParagrpah(
            textAlign: TextAlign.center,
            text: text,
            size: size,
            maxLines: maxLines,
            color: HFColors().secondaryColor(),
          ),
        ),
      ],
    ),
  );
}

Flushbar getNotificationBar(text, message, onTap) {
  return Flushbar(
    title: text,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    titleColor: HFColors().whiteColor(),
    message: message,
    messageColor: HFColors().whiteColor(),
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    backgroundColor: HFColors().secondaryLightColor(),
    flushbarPosition: FlushbarPosition.TOP,
    duration: Duration(seconds: 5),
    forwardAnimationCurve: Curves.easeInOut,
    reverseAnimationCurve: Curves.easeInOut,
    animationDuration: Duration(milliseconds: 400),
  );
}
