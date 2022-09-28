import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/routes.dart';
import 'hf_event_tile.dart';
import '../hf_heading.dart';

class HFCalendarSection extends StatelessWidget {
  const HFCalendarSection({Key? key}) : super(key: key);

  final double dateOffset = 60;

  @override
  Widget build(BuildContext context) {
    var events = context.watch<HFGlobalState>().calendarEvents[DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 00:00:00.000Z')] ??
        [];

    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            HFHeading(
              text: 'Upcoming trainings',
              size: 8,
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: dateOffset - 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HFHeading(
                    text: DateTime.now().day.toString(),
                    size: 10,
                    lineHeight: 1,
                    textAlign: TextAlign.center,
                  ),
                  HFParagrpah(
                    text: DateFormat("MMM").format(DateTime.now()).toString(),
                    size: 10,
                    lineHeight: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            events.where((event) {
              DateTime eventStart = DateTime.parse(
                  '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${event.startTime}:00.000Z');
              DateTime now = DateTime.parse(
                  '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}:00.000Z');

              return eventStart.isAfter(now);
            }).isEmpty
                ? const SizedBox(
                    height: 150,
                    child: HFParagrpah(
                      text: 'No events today',
                      size: 10,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      ...events
                          .where((event) {
                            DateTime eventStart = DateTime.parse(
                                '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${event.startTime}:00.000Z');
                            DateTime now = DateTime.parse(
                                '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}:00.000Z');

                            return eventStart.isAfter(now);
                          })
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (eventData) {
                              var key = eventData.key;
                              var value = eventData.value;

                              return HFEventTile(
                                offset: dateOffset,
                                title: value.title,
                                startTime: value.startTime,
                                endTime: value.endTime,
                                color: value.color,
                                location: value.location,
                                client: value.client,
                                isDone: value.isDone,
                                useSpacerBottom: events.length >= key + 1,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    eventRoute,
                                    arguments: value,
                                  );
                                },
                              );
                            },
                          )
                    ],
                  )
          ],
        )
      ],
    );
  }
}
