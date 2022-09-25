import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_heading.dart';

class HFInput extends StatelessWidget {
  const HFInput({
    Key? key,
    required this.controller,
    this.obscureText = false,
    this.showCursor = true,
    this.readOnly = false,
    this.isHidden = false,
    this.hintText = '',
    this.labelText = '',
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.onEditingComplete,
    this.verticalContentPadding = 16,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.toolbarOptions = const ToolbarOptions(
      copy: true,
      cut: true,
      paste: true,
      selectAll: true,
    ),
  }) : super(key: key);

  final TextEditingController controller;
  final bool obscureText;
  final bool showCursor;
  final bool readOnly;
  final bool isHidden;
  final TextInputType keyboardType;
  final String hintText;
  final String labelText;
  final double verticalContentPadding;
  final int maxLines;
  final ToolbarOptions toolbarOptions;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Container(
        height: 30,
        child: TextFormField(
          validator: validator,
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: verticalContentPadding,
            ),
          ),
          showCursor: false,
          readOnly: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != '')
            Padding(
              padding: const EdgeInsets.only(left: 13.0),
              child: HFHeading(
                text: '$labelText:',
                size: 2,
              ),
            ),
          const SizedBox(
            height: 2,
          ),
          TextFormField(
            toolbarOptions: toolbarOptions,
            maxLines: maxLines,
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: verticalContentPadding,
              ),
              hintText: hintText,
            ),
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            onChanged: onChanged,
            onTap: onTap,
            onEditingComplete: onEditingComplete,
            showCursor: showCursor,
            readOnly: readOnly,
            style: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().whiteColor(),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
