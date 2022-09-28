import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../constants/global_state.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_training_list_view_tile.dart';

class EventScreen extends StatefulWidget {
  EventScreen({
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
    required this.isDone,
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
  final bool isDone;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        actions: [
          if (context.read<HFGlobalState>().userAccessLevel ==
              accessLevels.trainer)
            IconButton(
              onPressed: () {
                HFFirebaseFunctions()
                    .getFirebaseAuthUser(context)
                    .collection('days')
                    .doc('${widget.date}')
                    .collection('events')
                    .doc(widget.id)
                    .delete()
                    .then((value) {
                  HFFirebaseFunctions().updateUserChangedDate(context);

                  FirebaseFirestore.instance
                      .collection('clients')
                      .doc(widget.client['id'])
                      .collection('days')
                      .doc('${widget.date}')
                      .collection('events')
                      .doc(widget.id)
                      .delete()
                      .then((value) {
                    FirebaseFirestore.instance
                        .collection('clients')
                        .doc(widget.client['id'])
                        .update({
                      'changed': '${DateTime.now()}',
                    });
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'Training removed!',
                      color: HFColors().primaryColor(opacity: 1),
                    ));

                    Navigator.pop(context);
                  });
                });
              },
              icon: Icon(
                CupertinoIcons.trash,
                color: HFColors().redColor(),
              ),
            ),
          // if (context.read<HFGlobalState>().userAccessLevel ==
          //     accessLevels.trainer)
          //   IconButton(
          //     onPressed: () {
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
          // },
          //   icon: const Icon(CupertinoIcons.doc_on_clipboard),
          // ),
          // if (context.read<HFGlobalState>().userAccessLevel ==
          //     accessLevels.trainer)
          // IconButton(
          //   onPressed: () {
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
          //   },
          //   icon: const Icon(CupertinoIcons.pen),
          // )
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
                text: widget.title,
                size: 7,
              ),
              SizedBox(
                height: 5,
              ),
              if (widget.isDone)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark_circled,
                      color: HFColors().greenColor(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    HFParagrpah(
                      text: 'Event completed',
                      size: 6,
                    )
                  ],
                ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            text: DateFormat('EEE, d/M/y').format(widget.date),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HFParagrpah(
                            size: 8,
                            text: '${widget.startTime} - ${widget.endTime}',
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
                            text: widget.location,
                            color: HFColors().whiteColor(opacity: 0.8),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (context.read<HFGlobalState>().userAccessLevel ==
                      accessLevels.trainer)
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
                              text: widget.client['name'],
                              color: HFColors().whiteColor(opacity: 0.8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        ...widget.exercises.map((exercise) {
                          return HFTrainingListViewTile(
                            showDelete: false,
                            name: exercise['name'],
                            note: exercise['note'],
                            type: exercise['repetitionType'],
                            amount: double.parse(exercise['amount']),
                            repetitions: double.parse(exercise['repetitions']),
                            series: double.parse(exercise['series']),
                            onTap: () {
                              if (widget.isDone) {
                                return;
                              }

                              Navigator.pushNamed(context, adminExerciseSingle,
                                  arguments: {
                                    ...exerciseData(exercise),
                                    'note': exercise['note'],
                                    'author': ''
                                  });
                            },
                          );
                        })
                      ],
                    ),
                  ),
                  if (!widget.isDone)
                    const SizedBox(
                      height: 20,
                    ),
                  if (!widget.isDone)
                    const HFHeading(
                      text: 'Note:',
                      size: 6,
                      lineHeight: 2,
                    ),
                  if (!widget.isDone)
                    HFParagrpah(
                      text: widget.notes,
                      size: 8,
                      lineHeight: 1.4,
                      maxLines: 999,
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (!widget.isDone &&
                      context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.client)
                    HFButton(
                      text: isLoading ? 'Processing...' : 'Mark as done',
                      padding: EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        showAlertDialog(
                          context,
                          'Are you sure you want to mark this event as done?',
                          () {
                            Navigator.pop(context);
                            completeTraining(context);

                            setState(() {
                              isLoading = true;
                            });
                          },
                          'Yes',
                          () {
                            Navigator.pop(context);
                          },
                          'No',
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  completeTraining(BuildContext context) {
    HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection('days')
        .doc('${widget.date}')
        .collection('events')
        .doc(widget.id)
        .update({'isDone': true}).then((value) {
      print('updated is done');
      HFFirebaseFunctions().getFirebaseAuthUser(context).update({
        'changed': '${DateTime.now()}',
      }).then((value) {
        print('updated is client changed');
        FirebaseFirestore.instance
            .collection('trainers')
            .doc(context.read<HFGlobalState>().userTrainerId)
            .collection('days')
            .doc('${widget.date}')
            .collection('events')
            .doc(widget.id)
            .update({'isDone': true}).then((value) {
          print('updated trainer is done');
          FirebaseFirestore.instance
              .collection('trainers')
              .doc(context.read<HFGlobalState>().userTrainerId)
              .update({
            'changed': '${DateTime.now()}',
          }).then((value) {
            print('updated trainer changed');
            HFFirebaseFunctions()
                .getFirebaseAuthUser(context)
                .collection('completed')
                .doc(widget.id)
                .set({
              'title': widget.title,
              'id': widget.id,
              'date': '${widget.date}',
              'startTime': widget.startTime,
              'endTime': widget.endTime,
              'client': widget.client,
              'exercises': widget.exercises,
              'location': widget.location,
              'notes': widget.notes,
              'isDone': widget.isDone,
            }).then((value) {
              print('added completed item');

              ScaffoldMessenger.of(context)
                  .showSnackBar(getSnackBar(text: 'Event marked as completed'));

              Navigator.pop(context);
            });
          });
        });
      });
    });
  }
}
