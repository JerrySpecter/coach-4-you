import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import "dart:math" show pi;

import '../../constants/colors.dart';
import '../hf_button.dart';
import '../hf_heading.dart';

class HFArchiveTile extends StatelessWidget {
  HFArchiveTile({
    Key? key,
    this.image = '',
    this.title = 'Title',
    this.onTap,
    this.onButtonTap,
    this.useChildren = false,
    this.isSvg = true,
    this.hideTitle = false,
    this.children = const Text(''),
    this.secondaryColor = Colors.amber,
    this.primaryColor = Colors.black,
  }) : super(key: key);

  String image;
  String title;
  Color secondaryColor;
  Color primaryColor;
  bool hideTitle;
  bool useChildren;
  bool isSvg;
  Widget children;
  Function()? onTap;
  Function()? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
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
                  left: -MediaQuery.of(context).size.width * 0.33,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isSvg)
                        Image.asset(
                          image,
                          width: MediaQuery.of(context).size.width * 0.3,
                        )
                      else
                        SvgPicture.asset(
                          image,
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (useChildren) children,
                          if (!hideTitle)
                            HFHeading(
                              text: title,
                              size: 8,
                              color: HFColors().whiteColor(opacity: 1),
                            ),
                        ],
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
