import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_heading.dart';

class HFInputNumber extends StatelessWidget {
  const HFInputNumber({
    Key? key,
    required this.controller,
    this.showCursor = true,
    this.readOnly = false,
    this.isHidden = false,
    this.hintText = '',
    this.labelText = '',
    this.onChanged,
    this.onTap,
    this.verticalContentPadding = 16,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.toolbarOptions = const ToolbarOptions(
      copy: true,
      cut: true,
      paste: true,
      selectAll: true,
    ),
  }) : super(key: key);

  final TextEditingController controller;
  final bool showCursor;
  final bool readOnly;
  final bool isHidden;
  final String hintText;
  final String labelText;
  final double verticalContentPadding;
  final int minLines;
  final int maxLines;
  final ToolbarOptions toolbarOptions;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Container(
        height: 30,
        child: TextFormField(
          validator: validator,
          controller: controller,
          style: TextStyle(color: Colors.transparent),
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
            minLines: minLines,
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: verticalContentPadding,
              ),
              hintText: hintText,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            onTap: onTap,
            showCursor: showCursor,
            readOnly: readOnly,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text.replaceAll(',', '.'),
                ),
              ),
            ],
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
