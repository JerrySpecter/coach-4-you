import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HFButton extends StatelessWidget {
  const HFButton({
    Key? key,
    this.onPressed,
    this.text = 'Button',
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.backgroundColor = const Color.fromRGBO(219, 203, 140, 1),
    this.textColor = Colors.black,
    this.borderRadius = 16.0,
    this.icon = const Icon(CupertinoIcons.alarm),
    this.useIcon = false,
  }) : super(key: key);

  final Function()? onPressed;
  final String text;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final dynamic icon;
  final bool useIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor,
        ),
        elevation: MaterialStateProperty.all<double>(4),
        padding: MaterialStateProperty.all<EdgeInsets>(padding),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all<Size>(Size.zero),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      child: useIcon
          ? icon
          : Text(
              text,
              style: GoogleFonts.getFont(
                'Manrope',
                textStyle: TextStyle(
                  color: textColor,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
