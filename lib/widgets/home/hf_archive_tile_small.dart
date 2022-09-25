import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import "dart:math" show pi;

import '../../constants/colors.dart';
import '../hf_button.dart';
import '../hf_heading.dart';

class HFArchiveTileSmall extends StatelessWidget {
  HFArchiveTileSmall({
    Key? key,
    this.image = '',
    this.title = 'Title',
    this.onTap,
    this.onButtonTap,
    this.secondaryColor = Colors.amber,
    this.primaryColor = Colors.black,
    this.icon = Icons.icecream_outlined,
  }) : super(key: key);

  String image;
  String title;
  Color secondaryColor;
  Color primaryColor;
  IconData icon;
  Function()? onTap;
  Function()? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: getShadow(),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: onTap,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 1,
                  left: -MediaQuery.of(context).size.width * 0.53,
                  child: Transform(
                    transform: Matrix4.rotationZ(-pi * 12.1),
                    child: Container(
                      color: secondaryColor,
                      height: 300,
                      width: ((MediaQuery.of(context).size.width / 2) - 16) +
                          MediaQuery.of(context).size.width * 0.25,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24, left: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        icon,
                        size: 40,
                        color: HFColors().whiteColor(),
                      ),
                      HFHeading(
                        text: title,
                        size: 8,
                        color: HFColors().whiteColor(opacity: 1),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
