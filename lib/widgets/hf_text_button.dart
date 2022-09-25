import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';

class HFTextButton extends StatelessWidget {
  const HFTextButton({
    Key? key,
    this.onPressed,
    this.text = 'Text Button',
  }) : super(key: key);

  final Function()? onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.getFont(
            'Manrope',
            textStyle: TextStyle(
              color: HFColors().primaryColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
