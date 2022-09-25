import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFListViewTile extends StatefulWidget {
  const HFListViewTile({
    Key? key,
    this.name = 'John Doe',
    this.email = 'example@gmail.com',
    this.useSpacerBottom = false,
    this.useImage = true,
    this.imageSize = 72,
    this.headingMargin = 8,
    this.showAvailable = true,
    this.available = false,
    this.onTap,
    this.onLongPress,
    this.tags = const [],
    this.showTags = false,
    this.icon = CupertinoIcons.chevron_right,
    this.imageUrl = '',
    this.id = '',
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
    this.longPressColor = const Color.fromRGBO(34, 34, 34, 1),
    this.child = const SizedBox(
      height: 0,
      width: 0,
    ),
  }) : super(key: key);

  final String name;
  final String email;
  final String imageUrl;
  final String id;

  final double imageSize;
  final double headingMargin;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showAvailable;
  final bool available;
  final bool showTags;
  final List<dynamic> tags;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color backgroundColor;
  final Color longPressColor;
  final Widget child;

  @override
  State<HFListViewTile> createState() => _HFListViewTileState();
}

class _HFListViewTileState extends State<HFListViewTile> {
  String _imageUrl = '';
  bool _isLongPressed = false;

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
            color:
                _isLongPressed ? widget.longPressColor : widget.backgroundColor,
            boxShadow: getShadow(),
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
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
                      if (widget.showAvailable)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.circle_filled,
                              color: widget.available
                                  ? HFColors().greenColor()
                                  : HFColors().redColor(),
                              size: 8,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            HFParagrpah(
                              size: 5,
                              color: HFColors().whiteColor(),
                              text: widget.available
                                  ? 'Available'
                                  : 'Currently not available',
                            )
                          ],
                        ),
                      if (widget.useImage)
                        SizedBox(
                          height: widget.headingMargin,
                        ),
                      widget.child,
                      if (widget.tags.isNotEmpty)
                        SizedBox(
                          height: 20,
                        ),
                      if (widget.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: [
                            ...widget.tags.map((tag) {
                              return HFTag(
                                text: tag,
                                size: 6,
                                backgroundColor: HFColors().primaryColor(),
                                color: HFColors().secondaryColor(),
                              );
                            })
                          ],
                        )
                    ],
                  ),
                ),
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
