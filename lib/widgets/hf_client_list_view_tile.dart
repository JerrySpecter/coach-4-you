import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFClientListViewTile extends StatelessWidget {
  const HFClientListViewTile({
    Key? key,
    this.name = 'John Doe',
    this.email = 'example@gmail.com',
    this.useSpacerBottom = false,
    this.useImage = true,
    this.imageUrl = '',
    this.imageSize = 72,
    this.headingMargin = 8,
    this.showAvailable = true,
    this.available = false,
    this.onTap,
    this.icon = CupertinoIcons.chevron_right,
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
    this.child = const SizedBox(
      height: 0,
      width: 0,
    ),
  }) : super(key: key);

  final String name;
  final String email;
  final String imageUrl;
  final double imageSize;
  final double headingMargin;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showAvailable;
  final bool available;
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: backgroundColor,
            boxShadow: getShadow(),
          ),
          child: InkWell(
            onTap: available ? onTap : () {},
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (useImage)
                  SizedBox(
                    height: imageSize,
                    width: imageSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageSize / 5),
                      child: imageUrl == ''
                          ? HFImage(imageUrl: imageUrl)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                if (useImage)
                  const SizedBox(
                    width: 12,
                  ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HFHeading(
                        text: name,
                        size: 4,
                        color: HFColors().whiteColor(),
                      ),
                      if (!available)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.circle_filled,
                              color: HFColors().redColor(),
                              size: 8,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            HFParagrpah(
                              size: 5,
                              color: HFColors().whiteColor(),
                              text: 'Not ready',
                            )
                          ],
                        ),
                      if (useImage)
                        SizedBox(
                          height: headingMargin,
                        ),
                      child,
                    ],
                  ),
                ),
                if (available)
                  Icon(
                    icon,
                    color: HFColors().primaryColor(),
                  )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
