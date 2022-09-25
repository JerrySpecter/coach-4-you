import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFRequestTile extends StatelessWidget {
  const HFRequestTile({
    Key? key,
    this.name = 'John Doe',
    this.email = 'example@gmail.com',
    this.useSpacerBottom = false,
    this.onTap,
    this.content = '',
  }) : super(key: key);

  final String name;
  final String email;
  final String content;
  final bool useSpacerBottom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: HFColors().primaryColor(),
            boxShadow: [
              BoxShadow(
                color: HFColors().primaryColor(opacity: 0.3),
                offset: const Offset(5, 5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 45,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HFHeading(
                        text: name,
                        size: 4,
                        color: HFColors().whiteColor(),
                      ),
                      HFParagrpah(
                        text: email,
                        size: 6,
                        color: HFColors().whiteColor(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (useSpacerBottom)
          const SizedBox(
            height: 10,
          )
      ],
    );
  }
}
