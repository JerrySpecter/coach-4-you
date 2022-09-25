import 'package:flutter/material.dart';

class HFColors {
  Color primaryColor({double opacity = 1}) {
    return Color.fromRGBO(219, 203, 140, opacity);
  }

  Color primaryDarkColor({double opacity = 1}) {
    return Color.fromRGBO(0, 0, 0, opacity);
  }

  Color secondaryColor({double opacity = 1}) {
    return Color.fromRGBO(17, 17, 17, opacity);
  }

  Color secondaryLightColor({double opacity = 1}) {
    return Color.fromRGBO(34, 34, 34, opacity);
  }

  Color backgroundColor() {
    return const Color.fromARGB(255, 17, 17, 17);
  }

  Color whiteColor({double opacity = 1}) {
    return Color.fromRGBO(255, 252, 255, opacity);
  }

  Color greenColor({double opacity = 1}) {
    return Color.fromRGBO(100, 255, 97, opacity);
  }

  Color blueColor({double opacity = 1}) {
    return Color.fromRGBO(97, 246, 255, opacity);
  }

  Color yellowColor({double opacity = 1}) {
    return Color.fromRGBO(255, 220, 97, opacity);
  }

  Color redColor({double opacity = 1}) {
    return Color.fromRGBO(255, 97, 97, opacity);
  }

  Color pinkColor({double opacity = 1}) {
    return Color.fromRGBO(244, 59, 134, opacity);
  }

  Color purpleColor({double opacity = 1}) {
    return Color.fromRGBO(61, 8, 123, opacity);
  }
}

List<BoxShadow> getShadow() {
  return [
    BoxShadow(
      color: HFColors().primaryDarkColor(opacity: 0.3),
      offset: const Offset(2, 2),
      blurRadius: 6,
      spreadRadius: 1,
    ),
  ];
}
