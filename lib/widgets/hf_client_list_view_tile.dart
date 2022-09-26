import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFClientListViewTile extends StatefulWidget {
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
  State<HFClientListViewTile> createState() => _HFClientListViewTileState();
}

class _HFClientListViewTileState extends State<HFClientListViewTile> {
  String _imageUrl = '';

  @override
  void initState() {
    _imageUrl = widget.imageUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: widget.backgroundColor,
            boxShadow: getShadow(),
          ),
          child: InkWell(
            onTap: widget.available ? widget.onTap : () {},
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.useImage)
                  SizedBox(
                    height: widget.imageSize,
                    width: widget.imageSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.imageSize / 6),
                      child: HFImage(imageUrl: _imageUrl),
                    ),
                  ),
                if (widget.useImage)
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
                        text: widget.name,
                        size: 4,
                        color: HFColors().whiteColor(),
                      ),
                      if (!widget.available)
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
                      if (widget.useImage)
                        SizedBox(
                          height: widget.headingMargin,
                        ),
                      widget.child,
                    ],
                  ),
                ),
                if (widget.available)
                  Icon(
                    widget.icon,
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
