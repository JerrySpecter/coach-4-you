import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../constants/colors.dart';
import '../hf_heading.dart';
import '../hf_image.dart';
import 'package:intl/intl.dart';

class HFNewsTile extends StatelessWidget {
  const HFNewsTile({
    Key? key,
    this.title = 'Title',
    this.author = 'Author',
    this.likes = const [],
    this.excerpt =
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries,',
    this.date = '00:00',
    this.useSpacerBottom = false,
    this.onTap,
    this.imageUrl = '',
    this.id = '',
  }) : super(key: key);

  final String title;
  final String author;
  final List likes;
  final String excerpt;
  final String date;
  final String imageUrl;
  final String id;
  final bool useSpacerBottom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: getShadow(),
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 300,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: HFImage(imageUrl: imageUrl),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 6,
                      child: Container(
                        width: (MediaQuery.of(context).size.width * 0.7) - 12,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          color: HFColors().secondaryLightColor(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                HFParagrpah(
                                  text: author,
                                  size: 6,
                                  color: HFColors().whiteColor(),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                HFParagrpah(
                                  text: DateFormat('dd.MM.yyyy.')
                                      .format(DateTime.parse(date)),
                                  size: 6,
                                  color: HFColors().whiteColor(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            HFHeading(
                              text: title,
                              size: 5,
                              color: HFColors().whiteColor(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (useSpacerBottom)
          const SizedBox(
            width: 20,
          )
      ],
    );
  }
}
