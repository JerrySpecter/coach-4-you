// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../constants/global_state.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_training_list_view_tile.dart';
import 'add_event.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({
    Key? key,
    this.v2 = false,
    this.clientFeedback = '',
    required this.title,
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.client,
    required this.exercises,
    required this.location,
    required this.notes,
    required this.color,
    required this.isDone,
    required this.completedEventRoute,
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
  final String color;
  final String clientFeedback;
  final bool v2;
  final bool isDone;
  final bool completedEventRoute;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool isLoading = false;
  int selectedSet = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        actions: [
          if (context.read<HFGlobalState>().userAccessLevel ==
                  accessLevels.trainer &&
              !widget.completedEventRoute)
            IconButton(
              onPressed: () {
                showAlertDialog(
                  context,
                  'Are you sure you want to delete workout: ${widget.title}',
                  () {
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
                          text: 'Workout removed!',
                          color: HFColors().primaryColor(opacity: 1),
                        ));

                        Navigator.pop(context);
                      });
                    });
                  },
                  'Yes',
                  () {
                    Navigator.pop(context);
                  },
                  'No',
                );
              },
              icon: Icon(
                CupertinoIcons.trash,
                color: HFColors().redColor(),
              ),
            ),
          if (context.read<HFGlobalState>().userAccessLevel ==
                  accessLevels.trainer &&
              !widget.completedEventRoute)
            IconButton(
              onPressed: () {
                var exercises = widget.exercises;

                if (!widget.v2) {
                  exercises = [
                    {'exercises': []}
                  ];
                }

                Navigator.pushNamed(
                  context,
                  addEventRoute,
                  arguments: {
                    'v2': widget.v2,
                    'id': widget.id,
                    'date': widget.date,
                    'title': widget.title,
                    'startTime': widget.startTime,
                    'endTime': widget.endTime,
                    'location': widget.location,
                    'client': widget.client,
                    'exercises': exercises,
                    'note': widget.notes,
                    'color': widget.color,
                    'isEdit': false,
                    'isDuplicate': true,
                  },
                );
              },
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
          if (context.read<HFGlobalState>().userAccessLevel ==
                  accessLevels.trainer &&
              !widget.isDone)
            IconButton(
              onPressed: () {
                var exercises = widget.exercises;

                if (!widget.v2) {
                  exercises = [
                    {'exercises': exercises}
                  ];
                }

                Navigator.pushNamed(
                  context,
                  addEventRoute,
                  arguments: {
                    'v2': widget.v2,
                    'id': widget.id,
                    'date': widget.date,
                    'title': widget.title,
                    'startTime': widget.startTime,
                    'endTime': widget.endTime,
                    'location': widget.location,
                    'client': widget.client,
                    'exercises': exercises,
                    'note': widget.notes,
                    'color': widget.color,
                    'isEdit': true,
                    'isDuplicate': false,
                  },
                );
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
                text: widget.title,
                size: 7,
              ),
              const SizedBox(
                height: 5,
              ),
              if (widget.isDone)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark_circled,
                      color: HFColors().greenColor(),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const HFParagrpah(
                      text: 'Workout completed',
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HFColors().primaryColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.calendar,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HFHeading(
                            text: DateFormat('EEE, d/M/y').format(widget.date),
                          ),
                          const SizedBox(
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
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HFColors().primaryColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HFHeading(
                            text: 'Location:',
                          ),
                          const SizedBox(
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
                  const SizedBox(
                    height: 15,
                  ),
                  if (context.read<HFGlobalState>().userAccessLevel ==
                      accessLevels.trainer)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: HFColors().primaryColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            CupertinoIcons.person,
                            color: HFColors().secondaryColor(),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HFHeading(
                              text: 'Client:',
                            ),
                            const SizedBox(
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
                  const HFHeading(
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
                        if (widget.v2 && widget.exercises.length > 1)
                          const SizedBox(
                            height: 6,
                          ),
                        if (widget.v2 && widget.exercises.length > 1)
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              for (int index = 0;
                                  index < widget.exercises.length;
                                  index += 1)
                                getExerciseTab(index + 1, selectedSet == index,
                                    () {
                                  setState(() {
                                    selectedSet = index;
                                  });
                                }, widget.exercises),
                            ],
                          ),
                        if (widget.v2 && widget.exercises.length > 1)
                          const SizedBox(
                            height: 6,
                          ),
                        if (widget.v2)
                          for (int index = 0;
                              index < widget.exercises[selectedSet].length;
                              index += 1)
                            Builder(builder: (context) {
                              List<dynamic> set =
                                  widget.exercises[selectedSet]['exercises'];

                              if (set.isNotEmpty) {
                                return Column(
                                  children: [
                                    for (int exerciseIndex = 0;
                                        exerciseIndex < set.length;
                                        exerciseIndex += 1)
                                      Builder(builder: (context) {
                                        var eventV2 = false;

                                        if (set[exerciseIndex]
                                            .containsKey('v2')) {
                                          eventV2 = true;
                                        }

                                        return HFTrainingListViewTile(
                                          showDelete: false,
                                          name: set[exerciseIndex]['name'],
                                          note: set[exerciseIndex]['note'],
                                          type: set[exerciseIndex]
                                              ['repetitionType'],
                                          amount: set[exerciseIndex]
                                                      ['repetitionType'] ==
                                                  'time'
                                              ? eventV2
                                                  ? set[exerciseIndex]['amount']
                                                      ['durationString']
                                                  : set[exerciseIndex]['amount']
                                              : set[exerciseIndex]['amount'],
                                          repetitions: set[exerciseIndex]
                                              ['repetitions'],
                                          pauseTime: eventV2
                                              ? set[exerciseIndex]['pauseTime']
                                                  ['durationString']
                                              : '',
                                          series: set[exerciseIndex]['series'],
                                          warmups: eventV2
                                              ? set[exerciseIndex]['warmups']
                                              : [],
                                          onTap: () {
                                            if (widget.isDone) {
                                              return;
                                            }

                                            Navigator.pushNamed(
                                                context, adminExerciseSingle,
                                                arguments: {
                                                  ...exerciseData(
                                                      set[exerciseIndex]),
                                                  'note': set[exerciseIndex]
                                                      ['note'],
                                                  'author': '',
                                                  'isFromEvent': true,
                                                });
                                          },
                                        );
                                      })
                                  ],
                                );
                              } else {
                                return const HFHeading(
                                  text: '',
                                );
                              }
                            }),
                        if (!widget.v2)
                          ...widget.exercises.map(
                            (exercise) {
                              return HFTrainingListViewTile(
                                showDelete: false,
                                name: exercise['name'],
                                note: exercise['note'],
                                type: exercise['repetitionType'],
                                amount: exercise['amount'],
                                repetitions: exercise['repetitions'],
                                series: exercise['series'],
                                onTap: () {
                                  if (widget.isDone) {
                                    return;
                                  }

                                  Navigator.pushNamed(
                                      context, adminExerciseSingle,
                                      arguments: {
                                        ...exerciseData(exercise),
                                        'note': exercise['note'],
                                        'author': '',
                                        'isFromEvent': true,
                                      });
                                },
                              );
                            },
                          )
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
                  if (context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.trainer &&
                      widget.clientFeedback != '')
                    const HFHeading(
                      text: 'Client feedback:',
                      size: 6,
                      lineHeight: 2,
                    ),
                  if (context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.trainer &&
                      widget.clientFeedback != '')
                    HFParagrpah(
                      text: widget.clientFeedback,
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
                      text: 'Complete workout',
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        showExerciseModal();
                      },
                    ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showExerciseModal() {
    final TextEditingController clientFeedbackController =
        TextEditingController();
    // edit exercise modal
    showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              color: HFColors().secondaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HFHeading(
                  size: 6,
                  text: 'Leave feedback about your workout',
                ),
                const SizedBox(
                  height: 30,
                ),
                HFInput(
                  controller: clientFeedbackController,
                  hintText: 'Type your feedback message here',
                  minLines: 6,
                  maxLines: 10,
                ),
                const SizedBox(
                  height: 30,
                ),
                HFButton(
                  text: isLoading ? 'Processing...' : 'Complete',
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () {
                    showAlertDialog(
                      context,
                      'Are you sure you want to mark this event as done?',
                      () {
                        Navigator.pop(context);
                        completeTraining(
                            context, clientFeedbackController.text);

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
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom < 40
                      ? 40
                      : MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          );
        });
  }

  completeTraining(BuildContext context, clientFeedback) {
    HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection('days')
        .doc('${widget.date}')
        .collection('events')
        .doc(widget.id)
        .update({'isDone': true, 'clientFeedback': clientFeedback}).then(
            (value) {
      HFFirebaseFunctions().getFirebaseAuthUser(context).update({
        'changed': '${DateTime.now()}',
      }).then((value) {
        FirebaseFirestore.instance
            .collection('trainers')
            .doc(context.read<HFGlobalState>().userTrainerId)
            .collection('days')
            .doc('${widget.date}')
            .collection('events')
            .doc(widget.id)
            .update({'isDone': true, 'clientFeedback': clientFeedback}).then(
                (value) {
          FirebaseFirestore.instance
              .collection('trainers')
              .doc(context.read<HFGlobalState>().userTrainerId)
              .update({
            'changed': '${DateTime.now()}',
          }).then((value) {
            HFFirebaseFunctions()
                .getFirebaseAuthUser(context)
                .collection('completed')
                .doc(widget.id)
                .set({
              'v2': widget.v2,
              'clientFeedback': clientFeedback,
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
              FirebaseFirestore.instance
                  .collection('trainers')
                  .doc(context.read<HFGlobalState>().userTrainerId)
                  .get()
                  .then((trainerRef) {
                trainerRef.reference.collection('notifications').doc().set({
                  'token': trainerRef['notificationToken'],
                  'data': {
                    'v2': widget.v2,
                    'clientFeedback': clientFeedback,
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
                  },
                  'type': 'completed-workout',
                  'read': false,
                  'trainerImage': context.read<HFGlobalState>().userImage,
                  'trainerName': context.read<HFGlobalState>().userName,
                  'date': '${DateTime.now()}'
                }).then((val) {
                  trainerRef.reference.update({
                    'unreadNotifications': trainerRef['unreadNotifications'] + 1
                  });
                });
              });
            }).then((value) {
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
