import 'package:flutter/material.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../hf_heading.dart';

class HFEventTile extends StatelessWidget {
  const HFEventTile(
      {Key? key,
      this.offset = 0,
      this.title = 'Event title',
      this.startTime = '',
      this.endTime = '',
      this.client = const {'name': 'John Doe'},
      this.color = '',
      this.exercises = const [],
      this.id = '',
      this.notes = '',
      this.location = 'Strojarska',
      this.useSpacerBottom = false,
      this.onTap})
      : super(key: key);

  final double offset;
  final String title;
  final String startTime;
  final String endTime;
  final Map<String, dynamic> client;
  final String color;
  final List<dynamic> exercises;
  final String id;
  final String notes;
  final String location;
  final bool useSpacerBottom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    print(client);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: HFColors().secondaryColor(opacity: 1),
                offset: Offset(3, 3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width - 32 - offset,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: getColor(color),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HFHeading(
                    text: title,
                    size: 4,
                    color: getTextColor(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  HFParagrpah(
                    text: '$startTime - $endTime',
                    size: 7,
                    color: getTextColor(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      if (client.containsKey('name') &&
                          context.read<HFGlobalState>().userAccessLevel ==
                              accessLevels.trainer)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HFParagrpah(
                              size: 6,
                              text: 'Client:',
                              color: getTextColor(),
                            ),
                            HFHeading(
                              size: 2,
                              text: client['name'],
                              color: getTextColor(),
                            ),
                          ],
                        ),
                      if (client.containsKey('name') &&
                          context.read<HFGlobalState>().userAccessLevel ==
                              accessLevels.trainer)
                        SizedBox(
                          width: 20,
                        ),
                      if (location != '')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HFParagrpah(
                              size: 6,
                              text: 'Location:',
                              color: getTextColor(),
                            ),
                            HFHeading(
                              size: 2,
                              text: location,
                              color: getTextColor(),
                            ),
                          ],
                        )
                    ],
                  )
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

  Color getColor(color) {
    switch (color) {
      case 'primaryColor':
        return HFColors().primaryColor();

      case 'redColor':
        return HFColors().redColor();

      case 'greenColor':
        return HFColors().greenColor();

      case 'yellowColor':
        return HFColors().yellowColor();

      case 'whiteColor':
        return HFColors().whiteColor();

      case 'purpleColor':
        return HFColors().purpleColor();

      case 'pinkColor':
        return HFColors().pinkColor();

      case 'blueColor':
        return HFColors().blueColor();
      default:
        return HFColors().primaryColor();
    }
  }

  Color getTextColor() {
    return getColor(color).computeLuminance() >= 0.5
        ? HFColors().secondaryColor()
        : HFColors().whiteColor();
  }
}
