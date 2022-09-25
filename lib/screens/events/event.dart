import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../widgets/hf_training_list_view_tile.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({
    Key? key,
    required this.title,
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.client,
    required this.exercises,
    required this.location,
    required this.notes,
  }) : super(key: key);

  final String title;
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final Map<String, dynamic> client;
  final List<dynamic> exercises;
  final String location;
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              HFFirebaseFunctions()
                  .getFirebaseAuthUser(context)
                  .collection('days')
                  .doc('$date')
                  .collection('events')
                  .doc(id)
                  .delete()
                  .then((value) {
                HFFirebaseFunctions().updateUserChangedDate(context);

                ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                  text: 'Training removed!',
                  color: HFColors().primaryColor(opacity: 1),
                ));

                Navigator.pop(context);
              });
            },
            icon: Icon(
              CupertinoIcons.trash,
              color: HFColors().redColor(),
            ),
          ),
          IconButton(
            onPressed: () {
              print('duplicate');
              // Navigator.pushNamed(
              //   context,
              //   editTrainingRoute,
              //   arguments: {
              //     'parentContext': context,
              //     'id': widget.id,
              //     'name': _nameState,
              //     'note': _noteState,
              //     'exercises': _exercisesState,
              //     'isEdit': false,
              //     'isDuplicate': true
              //   },
              // );
            },
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
          ),
          IconButton(
            onPressed: () {
              print('edit');
              // Navigator.pushNamed(
              //   context,
              //   editTrainingRoute,
              //   arguments: {
              //     'parentContext': context,
              //     'id': widget.id,
              //     'name': _nameState,
              //     'note': _noteState,
              //     'exercises': _exercisesState,
              //     'isEdit': true,
              //     'isDuplicate': false
              //   },
              // );
            },
            icon: const Icon(CupertinoIcons.pen),
          )
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              HFHeading(
                text: title,
                size: 7,
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HFColors().primaryColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.calendar,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HFHeading(
                            text: DateFormat('EEE, d/M/y').format(date),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HFParagrpah(
                            size: 8,
                            text: '$startTime - $endTime',
                            color: HFColors().whiteColor(opacity: 0.8),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HFColors().primaryColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HFHeading(
                            text: 'Location:',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HFParagrpah(
                            size: 8,
                            text: location,
                            color: HFColors().whiteColor(opacity: 0.8),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HFColors().primaryColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.person,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HFHeading(
                            text: 'Client:',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HFParagrpah(
                            size: 8,
                            text: client['name'],
                            color: HFColors().whiteColor(opacity: 0.8),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              HFHeading(
                size: 5,
                text: 'Exercises:',
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: HFColors().primaryColor(opacity: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...exercises.map((exercise) {
                      return HFTrainingListViewTile(
                        showDelete: false,
                        name: exercise['name'],
                        note: exercise['note'],
                        type: exercise['type'],
                        amount: double.parse(exercise['amount']),
                        repetitions: double.parse(exercise['repetitions']),
                        series: double.parse(exercise['series']),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const HFHeading(
                text: 'Note:',
                size: 6,
                lineHeight: 2,
              ),
              HFParagrpah(
                text: notes,
                size: 8,
                lineHeight: 1.4,
                maxLines: 999,
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
