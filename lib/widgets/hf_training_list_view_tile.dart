import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';

class HFTrainingListViewTile extends StatefulWidget {
  const HFTrainingListViewTile({
    Key? key,
    this.name = 'John Doe',
    this.email = 'example@gmail.com',
    this.useSpacerBottom = false,
    this.useImage = true,
    this.imageSize = 72,
    this.headingMargin = 8,
    this.amount = 15,
    this.repetitions = 15,
    this.showDelete = true,
    this.onTap,
    this.onDelete,
    this.type = '',
    this.series = 0.0,
    this.note = '',
    this.icon = CupertinoIcons.chevron_right,
    this.imageUrl = '',
    this.id = '',
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
    this.longPressColor = const Color.fromRGBO(34, 34, 34, 1),
  }) : super(key: key);

  final String name;
  final String email;
  final String imageUrl;
  final String id;
  final String type;
  final double series;
  final String note;
  final double imageSize;
  final double headingMargin;
  final double amount;
  final double repetitions;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showDelete;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color backgroundColor;
  final Color longPressColor;

  @override
  State<HFTrainingListViewTile> createState() => _HFTrainingListViewTileState();
}

class _HFTrainingListViewTileState extends State<HFTrainingListViewTile> {
  final bool _isLongPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.series.toString().replaceAll(',', '.');
    widget.amount.toString().replaceAll(',', '.');
    widget.repetitions.toString().replaceAll(',', '.');

    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: _isLongPressed
                  ? widget.longPressColor
                  : widget.backgroundColor,
              boxShadow: getShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: HFHeading(
                        text: widget.name,
                        size: 5,
                        color: HFColors().whiteColor(),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    if (widget.showDelete)
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Icon(
                          CupertinoIcons.trash,
                          color: HFColors().redColor(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                HFParagrpah(
                  size: 7,
                  text: widget.note,
                  maxLines: 2,
                  color: HFColors().whiteColor(opacity: 0.7),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: HFColors().whiteColor(opacity: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            HFParagrpah(
                              size: 6,
                              text: widget.type == 'weight'
                                  ? 'kg'
                                  : widget.type == 'time'
                                      ? 'Minutes'
                                      : '',
                            ),
                            const SizedBox(height: 5),
                            HFHeading(
                              text:
                                  widget.amount.toString().split('.')[1] == '0'
                                      ? widget.amount.toString().split('.')[0]
                                      : '${widget.amount}',
                              size: 4,
                              color: HFColors().whiteColor(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: HFColors().whiteColor(opacity: 0.3),
                        child: const SizedBox(
                          height: 20,
                          width: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const HFParagrpah(
                              size: 6,
                              text: 'Reps.',
                            ),
                            const SizedBox(height: 5),
                            HFHeading(
                              text: widget.repetitions
                                          .toString()
                                          .split('.')[1] ==
                                      '0'
                                  ? widget.repetitions.toString().split('.')[0]
                                  : '${widget.repetitions}',
                              size: 4,
                              color: HFColors().whiteColor(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: HFColors().whiteColor(opacity: 0.3),
                        child: const SizedBox(
                          height: 20,
                          width: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const HFParagrpah(
                              size: 6,
                              text: 'Series',
                            ),
                            const SizedBox(height: 5),
                            HFHeading(
                              text:
                                  widget.series.toString().split('.')[1] == '0'
                                      ? widget.series.toString().split('.')[0]
                                      : '${widget.series}',
                              size: 4,
                              color: HFColors().whiteColor(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
