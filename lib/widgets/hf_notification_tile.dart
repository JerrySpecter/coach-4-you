import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'hf_image.dart';

class HFNotificationTile extends StatelessWidget {
  const HFNotificationTile({
    Key? key,
    this.title = 'John Doe',
    this.text = 'example@gmail.com',
    this.isRead = false,
    this.onTap,
    this.imageUrl = '',
    this.date = '',
    this.backgroundColor = const Color.fromRGBO(34, 34, 34, 1),
  }) : super(key: key);

  final String title;
  final String text;
  final bool isRead;
  final VoidCallback? onTap;
  final String imageUrl;
  final Color backgroundColor;
  final String date;

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
            color: backgroundColor,
            boxShadow: getShadow(),
          ),
          child: InkWell(
            onTap: onTap,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60 / 6),
                    child: imageUrl == ''
                        ? HFImage(imageUrl: imageUrl)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: HFHeading(
                              text: title,
                              size: 3,
                              color: HFColors().whiteColor(),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 1,
                            child: HFParagrpah(
                              textAlign: TextAlign.right,
                              text: timeago.format(
                                  DateTime.now().subtract(DateTime.now()
                                      .difference(DateTime.parse(date))),
                                  locale: 'en_short'),
                              size: 6,
                              color: HFColors().whiteColor(opacity: 0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: HFParagrpah(
                              text: text,
                              size: 8,
                              color: HFColors().whiteColor(opacity: 0.7),
                            ),
                          ),
                          if (!isRead)
                            SizedBox(
                              width: 20,
                              child: Icon(
                                CupertinoIcons.circle_fill,
                                size: 10,
                                color: HFColors().primaryColor(),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
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
