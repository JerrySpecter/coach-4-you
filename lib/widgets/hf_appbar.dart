import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'hf_heading.dart';

AppBar getAppBar(String title, List<Widget>? actions) {
  return AppBar(
    backgroundColor: HFColors().backgroundColor(),
    foregroundColor: HFColors().primaryColor(),
    shadowColor: Colors.transparent,
    title: HFHeading(
      text: title,
      size: 6,
    ),
    actions: actions,
  );
}
