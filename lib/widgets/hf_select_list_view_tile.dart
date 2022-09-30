import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';

import 'hf_image.dart';

class HFSelectListViewTile extends StatefulWidget {
  const HFSelectListViewTile({
    Key? key,
    this.name = 'John Doe',
    this.email = 'example@gmail.com',
    this.useSpacerBottom = false,
    this.useImage = true,
    this.isSelected = false,
    this.imageSize = 34,
    this.headingMargin = 4,
    this.showAvailable = true,
    this.available = false,
    this.isLoading = '',
    this.onTap,
    this.tags = const [],
    this.showTags = false,
    this.icon = CupertinoIcons.check_mark_circled,
    this.imageUrl = '',
    this.videoRef = '',
    this.id = '',
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
    this.child = const SizedBox(
      height: 0,
      width: 0,
    ),
  }) : super(key: key);

  final String name;
  final String email;
  final String imageUrl;
  final String id;
  final String videoRef;
  final double imageSize;
  final double headingMargin;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showAvailable;
  final bool available;
  final bool isSelected;
  final bool showTags;
  final List<dynamic> tags;
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;
  final String isLoading;

  @override
  State<HFSelectListViewTile> createState() => _HFSelectListViewTileState();
}

class _HFSelectListViewTileState extends State<HFSelectListViewTile> {
  String _imageUrl = '';

  @override
  void initState() {
    if (widget.videoRef != '') {
      getVideoById(widget.videoRef).get().then((value) {
        setState(() {
          _imageUrl = value['thumbnail'];
        });
      });
    } else {
      _imageUrl = widget.imageUrl;
    }

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
            onTap: widget.onTap,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.useImage)
                        SizedBox(
                          height: widget.imageSize,
                          width: widget.imageSize,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(widget.imageSize / 6),
                            child: HFImage(imageUrl: _imageUrl),
                          ),
                        ),
                      if (widget.useImage)
                        const SizedBox(
                          width: 12,
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 32 - 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HFHeading(
                              text: widget.name,
                              size: 2,
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
                                      backgroundColor:
                                          HFColors().primaryColor(),
                                      color: HFColors().secondaryColor(),
                                    );
                                  })
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: widget.isLoading == widget.id
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: HFColors().primaryColor(),
                              ))
                          : Icon(
                              widget.isSelected
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.check_mark_circled,
                              color: HFColors().primaryColor(),
                            ),
                    ),
                  )
                ],
              ),
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
