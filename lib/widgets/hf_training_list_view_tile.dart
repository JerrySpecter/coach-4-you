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
    this.amount = '',
    this.repetitions = '',
    this.showDelete = true,
    this.onTap,
    this.onDelete,
    this.type = '',
    this.pauseTime = '',
    this.series = '',
    this.note = '',
    this.warmups = const [],
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
  final dynamic pauseTime;
  final String series;
  final String note;
  final double imageSize;
  final double headingMargin;
  final dynamic amount;
  final String repetitions;
  final bool useSpacerBottom;
  final bool useImage;
  final bool showDelete;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color backgroundColor;
  final Color longPressColor;
  final List<dynamic> warmups;

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
                if (widget.warmups.isEmpty)
                  const SizedBox(
                    height: 20,
                  ),
                Column(
                  children: [
                    if (widget.warmups.isNotEmpty)
                      Transform.translate(
                        offset: const Offset(0.0, 20.0),
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 24, top: 8),
                          decoration: BoxDecoration(
                              color: HFColors().grey3(),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const HFHeading(
                                text: 'Warmup:',
                                size: 2,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              for (var index = 0;
                                  index < widget.warmups.length;
                                  index += 1)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                          child: HFHeading(
                                            text: '${index + 1}.',
                                            size: 2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: HFColors()
                                                .whiteColor(opacity: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    HFParagrpah(
                                                      textAlign:
                                                          TextAlign.center,
                                                      text:
                                                          widget.type == 'time'
                                                              ? 'Time'
                                                              : 'Weight (kg)',
                                                    ),
                                                    HFHeading(
                                                      text: widget.type ==
                                                              'time'
                                                          ? widget.warmups[
                                                                      index]
                                                                  ['amount']
                                                              ['durationString']
                                                          : widget.warmups[
                                                              index]['amount'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      size: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 16,
                                                color: HFColors()
                                                    .whiteColor(opacity: 0.4),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const HFParagrpah(
                                                      textAlign:
                                                          TextAlign.center,
                                                      text: 'Reps.',
                                                    ),
                                                    HFHeading(
                                                      text:
                                                          widget.warmups[index]
                                                              ['reps'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      size: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: HFColors().grey4(),
                          borderRadius: BorderRadius.circular(12)),
                      child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          getField(
                              widget.type == 'weight'
                                  ? 'Weight (kg)'
                                  : widget.type == 'time'
                                      ? 'Time'
                                      : '',
                              '${widget.amount}'),
                          const FieldDivider(),
                          getField('Series', widget.series),
                          if (widget.type == 'weight') const FieldDivider(),
                          if (widget.type == 'weight')
                            getField('Reps.', widget.repetitions),
                          if (widget.pauseTime != '') const FieldDivider(),
                          if (widget.pauseTime != '')
                            getField('Rest', '${widget.pauseTime}')
                        ],
                      ),
                    ),
                  ],
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

  Widget getField(text, value) {
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          HFParagrpah(
            size: 5,
            text: text,
          ),
          const SizedBox(height: 5),
          HFHeading(
            text: value,
            size: 3,
            color: HFColors().whiteColor(),
          ),
        ],
      ),
    );
  }
}

class FieldDivider extends StatelessWidget {
  const FieldDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HFColors().whiteColor(opacity: 0.3),
      child: const SizedBox(
        height: 20,
        width: 1,
      ),
    );
  }
}
