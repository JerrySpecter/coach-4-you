import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFClientChatTile extends StatefulWidget {
  const HFClientChatTile({
    Key? key,
    this.name = 'John Doe',
    this.text = '',
    this.number = 0,
    this.date = '',
    this.useSpacerBottom = false,
    this.useImage = true,
    this.imageUrl = '',
    this.imageSize = 52,
    this.headingMargin = 4,
    this.showAvailable = false,
    this.available = false,
    this.onTap,
    this.isRead = false,
    this.icon = CupertinoIcons.chevron_right,
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
    this.child = const SizedBox(
      height: 0,
      width: 0,
    ),
  }) : super(key: key);

  final String name;
  final String text;
  final String date;
  final int number;
  final String imageUrl;
  final double imageSize;
  final double headingMargin;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showAvailable;
  final bool available;
  final bool isRead;
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;

  @override
  State<HFClientChatTile> createState() => _HFClientChatTileState();
}

class _HFClientChatTileState extends State<HFClientChatTile> {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.useImage)
                  SizedBox(
                    height: widget.imageSize,
                    width: widget.imageSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.imageSize / 6),
                      child: _imageUrl == ''
                          ? HFImage(imageUrl: _imageUrl)
                          : Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                            ),
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
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HFParagrpah(
                      text: widget.date == ''
                          ? ''
                          : DateFormat('HH:mm')
                              .format(DateTime.parse(widget.date)),
                      size: 8,
                      color: HFColors().whiteColor(),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      opacity: widget.number <= 0 ? 0 : 1,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HFColors().redColor(),
                        ),
                        child: HFParagrpah(
                          text: '${widget.number}',
                          size: 8,
                          color: HFColors().whiteColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
