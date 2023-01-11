import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../../constants/colors.dart';
import 'package:intl/intl.dart';

import '../../utils/event.dart';
import '../../widgets/home/hf_event_tile.dart';

class ClientsUpcomingTrainings extends StatelessWidget {
  const ClientsUpcomingTrainings({
    Key? key,
    this.id = '',
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: 'Upcoming workouts',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 30,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(COLLECTION_CLIENTS)
                    .doc(id)
                    .collection(COLLECTION_DAYS)
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No upcoming workouts.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  var data = snapshot.data as QuerySnapshot;

                  if (data.docs.isEmpty) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No upcoming workouts.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ...data.docs.map(
                        (day) {
                          DateTime dayStart = DateTime.parse(day.id);

                          DateTime now = DateTime.parse(
                              '${DateFormat('yyyy-MM-dd').format(DateTime.now())}');

                          if (!dayStart.isAfter(now)) {
                            return const SizedBox(
                              height: 0,
                            );
                          }

                          DocumentReference dayRef = day.reference;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HFHeading(
                                size: 6,
                                text: DateFormat('EEE, d/M/y').format(dayStart),
                              ),
                              Divider(
                                thickness: 2,
                                color: HFColors().primaryColor(opacity: 0.3),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              StreamBuilder(
                                stream: dayRef
                                    .collection(COLLECTION_EVENTS)
                                    .orderBy('startTime')
                                    .snapshots(),
                                builder: ((context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: HFParagrpah(
                                        text: 'No events.',
                                        size: 10,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  var data = snapshot.data as QuerySnapshot;

                                  if (data.docs.isEmpty) {
                                    return const Center(
                                      child: HFParagrpah(
                                        text: 'No events.',
                                        size: 10,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      ...data.docs.map((e) {
                                        var eventData = e.data() as dynamic;
                                        var eventV2 = false;
                                        var eventClientFeedback = '';

                                        if (eventData.containsKey('v2')) {
                                          eventV2 = eventData['v2'];
                                        }

                                        if (eventData
                                            .containsKey('clientFeedback')) {
                                          eventClientFeedback =
                                              eventData['clientFeedback'];
                                        }

                                        var eventObj = Event(
                                          v2: eventV2,
                                          clientFeedback: eventClientFeedback,
                                          title: eventData['title'],
                                          id: eventData['id'],
                                          date:
                                              DateTime.parse(eventData['date']),
                                          startTime: eventData['startTime'],
                                          endTime: eventData['endTime'],
                                          client: eventData['client'],
                                          color: eventData['color'],
                                          exercises: eventData['exercises'],
                                          location: eventData['location'],
                                          notes: eventData['notes'],
                                          isDone: eventData['isDone'],
                                        );

                                        return HFEventTile(
                                          title: eventData['title'],
                                          startTime: eventData['startTime'],
                                          endTime: eventData['endTime'],
                                          color: eventData['color'],
                                          location: eventData['location'],
                                          client: eventData['client'],
                                          isDone: eventData['isDone'],
                                          useSpacerBottom: true,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              eventRoute,
                                              arguments: eventObj,
                                            );
                                          },
                                        );
                                      })
                                    ],
                                  );
                                }),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
