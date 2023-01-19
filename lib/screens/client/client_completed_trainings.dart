import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../../constants/colors.dart';
import 'package:intl/intl.dart';

class ClientsCompletedTrainings extends StatelessWidget {
  const ClientsCompletedTrainings({
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
          text: 'Completed workouts',
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
                    .collection('clients')
                    .doc(id)
                    .collection('completed')
                    .limit(30)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No completed workouts.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  var data = snapshot.data as QuerySnapshot;

                  if (data.docs.isEmpty) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No completed workouts.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HFHeading(
                        text: 'Total completed: ${data.docs.length}',
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ...data.docs.map(
                        (event) {
                          var eventData = event.data() as dynamic;
                          var eventV2 = false;
                          var eventClientFeedback = '';

                          if (eventData.containsKey('v2')) {
                            eventV2 = eventData['v2'];
                          }

                          if (eventData.containsKey('clientFeedback')) {
                            eventClientFeedback = eventData['clientFeedback'];
                          }

                          return HFListViewTile(
                            showAvailable: false,
                            useImage: false,
                            name: event['title'],
                            onTap: () {
                              Navigator.pushNamed(context, completedEventRoute,
                                  arguments: {
                                    'v2': eventV2,
                                    'clientFeedback': eventClientFeedback,
                                    'title': event['title'],
                                    'id': event['id'],
                                    'date': event['date'],
                                    'startTime': event['startTime'],
                                    'endTime': event['endTime'],
                                    'client': event['client'],
                                    'exercises': event['exercises'],
                                    'location': event['location'],
                                    'notes': event['notes'],
                                    'isDone': event['isDone'],
                                    'inCompleted': true,
                                  });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                HFParagrpah(
                                  size: 6,
                                  text: DateFormat('EEE, d/M/y')
                                      .format(DateTime.parse(event['date'])),
                                ),
                              ],
                            ),
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
