import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

import '../../constants/global_state.dart';
import '../../widgets/hf_input_number_field.dart';
import '../../widgets/hf_paragraph.dart';
import '../../widgets/hf_select_list_view_tile.dart';
import '../../widgets/hf_training_list_view_tile.dart';

class AddEventScreen extends StatefulWidget {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final Map client;
  final List exercises;
  final String note;
  final String color;
  final bool isEdit;
  final bool v2;
  final bool isDuplicate;

  const AddEventScreen({
    Key? key,
    this.id = '',
    this.title = '',
    required this.date,
    this.startTime = '',
    this.endTime = '',
    this.location = '',
    this.client = const {
      'name': '',
      'id': '',
    },
    this.exercises = const [],
    this.note = '',
    this.color = '',
    this.isEdit = false,
    this.v2 = false,
    this.isDuplicate = false,
  }) : super(key: key);

  @override
  AddEventScreenState createState() => AddEventScreenState();
}

class AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventStartController = TextEditingController();
  final TextEditingController eventEndController = TextEditingController();
  final TextEditingController eventNoteController = TextEditingController();
  final TextEditingController searchFieldController = TextEditingController();

  List exerciseTypes = [];
  String searchText = '';
  String exerciseSearchText = '';
  String searchClientsText = '';
  String selectedColor = 'primaryColor';
  late Stream stream;
  Stream exerciseStream = const Stream.empty();
  late Stream clientsStream;
  String eventName = '';
  String selectedClient = '';
  String selectedClientName = '';
  String selectedLocation = '';
  String selectedLocationName = '';
  List<dynamic> selectedExercises = [];
  List<dynamic> selectedTrainingExercises = [];
  late DateTime selectedEventDate;
  late DateTime startTimeInitialDate;
  late DateTime initialDate;
  DateTime selectedEventStartTime = DateTime.now();
  DateTime selectedEventEndTime = DateTime.now();
  String trainingSelected = '';
  String trainingNameSelected = '';
  bool pullUp = false;
  bool isLoading = false;

  int selectedSet = 0;
  List<dynamic> selectedExercisesSets = [
    {'exercises': []}
  ];

  @override
  void initState() {
    if (widget.date.day == DateTime.now().day &&
        widget.date.month == DateTime.now().month) {
      startTimeInitialDate = DateTime.now();
    } else {
      startTimeInitialDate = widget.date;
    }

    selectedEventDate = widget.date;
    eventDateController.text = DateFormat('EEE, d/M/y').format(widget.date);

    if (selectedEventDate
            .compareTo(DateTime.now().subtract(const Duration(days: 1))) <
        0) {
      selectedEventDate = DateTime.parse(
          '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 00:00:00.000Z');
      eventDateController.text =
          DateFormat('EEE, d/M/y').format(DateTime.now());
      startTimeInitialDate = DateTime.now();
    }
    stream = getTrainingsStream(searchText);
    clientsStream = getClientsStream(searchText);

    setState(() {
      eventNameController.text = widget.title;
      eventStartController.text = widget.startTime;
      eventEndController.text = widget.endTime;
      eventNoteController.text = widget.note;

      selectedClient = widget.client['id'];
      selectedClientName = widget.client['name'];

      selectedLocationName = widget.location;
      selectedExercisesSets = widget.exercises;
      selectedColor = widget.color;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: HFHeading(
          text: widget.isEdit
              ? 'Edit workout'
              : widget.isDuplicate
                  ? 'Duplicate workout'
                  : 'Add workout',
          size: 6,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height - 100),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HFInput(
                            controller: eventNameController,
                            hintText: 'Title',
                            showCursor: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const HFHeading(
                            size: 5,
                            text: 'Date and time:',
                          ),
                          HFInput(
                            controller: eventDateController,
                            showCursor: false,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                            onTap: () {
                              return showSheet(
                                context,
                                child: SizedBox(
                                  height: 180,
                                  child: CupertinoDatePicker(
                                    initialDateTime: selectedEventDate,
                                    mode: CupertinoDatePickerMode.date,
                                    use24hFormat: true,
                                    minuteInterval: 1,
                                    minimumDate: DateTime.now()
                                        .subtract(const Duration(days: 1)),
                                    //use24hFormat: true,
                                    onDateTimeChanged: (dateTime) => setState(
                                      () {
                                        if (dateTime.day ==
                                                DateTime.now().day &&
                                            dateTime.month ==
                                                DateTime.now().month) {
                                          startTimeInitialDate = DateTime.now();
                                        } else {
                                          startTimeInitialDate = dateTime;
                                        }

                                        selectedEventDate =
                                            DateTime.parse('${dateTime}Z');
                                      },
                                    ),
                                  ),
                                ),
                                onClicked: () {
                                  final value = DateFormat('EEE, d/M/y')
                                      .format(selectedEventDate);

                                  eventDateController.text = value;

                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: HFInput(
                                  controller: eventStartController,
                                  hintText: 'Start time',
                                  showCursor: false,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select start time';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    return showSheet(
                                      context,
                                      child: SizedBox(
                                        height: 180,
                                        child: CupertinoDatePicker(
                                          minimumDate: DateTime.now().subtract(
                                              const Duration(seconds: 60)),
                                          initialDateTime: startTimeInitialDate,
                                          mode: CupertinoDatePickerMode.time,
                                          use24hFormat: true,
                                          minuteInterval: 1,
                                          //use24hFormat: true,
                                          onDateTimeChanged: (dateTime) =>
                                              setState(() =>
                                                  selectedEventStartTime =
                                                      dateTime),
                                        ),
                                      ),
                                      onClicked: () {
                                        final value = DateFormat('HH:mm')
                                            .format(selectedEventStartTime);

                                        eventStartController.text = value;

                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Expanded(
                                flex: 10,
                                child: HFInput(
                                  controller: eventEndController,
                                  hintText: 'End time',
                                  showCursor: false,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select end time';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    return showSheet(
                                      context,
                                      child: SizedBox(
                                        height: 180,
                                        child: CupertinoDatePicker(
                                          initialDateTime:
                                              selectedEventStartTime,
                                          mode: CupertinoDatePickerMode.time,
                                          minuteInterval: 1,
                                          use24hFormat: true,
                                          minimumDate: selectedEventStartTime,
                                          onDateTimeChanged: (dateTime) =>
                                              setState(() =>
                                                  selectedEventEndTime =
                                                      dateTime),
                                        ),
                                      ),
                                      onClicked: () {
                                        final value = DateFormat('HH:mm')
                                            .format(selectedEventEndTime);

                                        eventEndController.text = value;

                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const HFHeading(
                            size: 5,
                            text: 'Choose a client:',
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: HFColors().primaryColor(opacity: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 2,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: HFInput(
                                    controller: searchFieldController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchClientsText = value;
                                        clientsStream =
                                            getClientsStream(searchText);
                                      });
                                    },
                                    hintText: 'Search clients',
                                    keyboardType: TextInputType.text,
                                    verticalContentPadding: 12,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 230,
                                      minHeight: 60,
                                    ),
                                    child: StreamBuilder(
                                      stream: clientsStream,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: HFParagrpah(
                                              text: 'No clients.',
                                              size: 10,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }

                                        var data =
                                            snapshot.data as QuerySnapshot;

                                        if (data.docs.isEmpty) {
                                          return const Center(
                                            child: HFParagrpah(
                                              text: 'No clients.',
                                              size: 10,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }

                                        return ListView(
                                          shrinkWrap: true,
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            ...data.docs.map(
                                              (client) {
                                                if (!client['accountReady']) {
                                                  return const SizedBox(
                                                    height: 0,
                                                  );
                                                }

                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                                  child: HFSelectListViewTile(
                                                    name: client['name'],
                                                    useImage: false,
                                                    showAvailable: false,
                                                    isSelected:
                                                        selectedClient ==
                                                            client['id'],
                                                    headingMargin: 0,
                                                    imageSize: 48,
                                                    id: client['id'],
                                                    useSpacerBottom: true,
                                                    onTap: () {
                                                      setState(() {
                                                        selectedClient =
                                                            client['id'];
                                                        selectedClientName =
                                                            client['name'];
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (selectedClientName != '')
                            HFParagrpah(
                              text: 'Selected: $selectedClientName',
                              size: 8,
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          const HFHeading(
                            text: 'Select a set:',
                            size: 5,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: HFColors().primaryColor(opacity: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 2,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: HFInput(
                                    controller: searchFieldController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchText = value;
                                        stream = getTrainingsStream(searchText);
                                      });
                                    },
                                    hintText: 'Search sets',
                                    keyboardType: TextInputType.text,
                                    verticalContentPadding: 12,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 250,
                                      minHeight: 60,
                                    ),
                                    child: StreamBuilder(
                                      stream: stream,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: HFParagrpah(
                                              text: 'No sets. no data',
                                              size: 10,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }

                                        var data =
                                            snapshot.data as QuerySnapshot;

                                        if (data.docs.isEmpty) {
                                          return const Center(
                                            child: HFParagrpah(
                                              text: 'No sets. empty',
                                              size: 10,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }

                                        return ListView(
                                          shrinkWrap: true,
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            ...data.docs.map(
                                              (training) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                                  child: HFSelectListViewTile(
                                                    name: training['name'],
                                                    useImage: false,
                                                    showAvailable: false,
                                                    icon: CupertinoIcons
                                                        .add_circled,
                                                    isSelected: false,
                                                    headingMargin: 0,
                                                    imageSize: 48,
                                                    id: training['id'],
                                                    useSpacerBottom: true,
                                                    onTap: () {
                                                      setState(() {
                                                        training['exercises']
                                                            .forEach(
                                                                (exercise) {
                                                          var exerciseObj =
                                                              exercise;

                                                          if (!exerciseObj
                                                              .containsKey(
                                                                  'v2')) {
                                                            exerciseObj = {
                                                              ...exercise,
                                                              'v2': false,
                                                              'warmups': [],
                                                              'pauseTime': {
                                                                'duration': const Duration(
                                                                        minutes:
                                                                            0,
                                                                        seconds:
                                                                            0)
                                                                    .toString(),
                                                                'durationString':
                                                                    0
                                                              }
                                                            };
                                                          }

                                                          selectedExercisesSets[
                                                                      selectedSet]
                                                                  ['exercises']
                                                              .add(exerciseObj);
                                                        });
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const HFHeading(
                            text: 'Selected exercises:',
                            size: 5,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 8, top: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: HFColors().primaryColor(opacity: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 6,
                                ),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          for (int index = 0;
                                              index <
                                                  selectedExercisesSets.length;
                                              index += 1)
                                            getExerciseTab(
                                                index + 1, selectedSet == index,
                                                () {
                                              setState(() {
                                                selectedSet = index;
                                              });
                                            }, selectedExercisesSets),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    if (selectedExercisesSets.length < 4)
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedExercisesSets
                                                .add({'exercises': []});
                                            selectedSet =
                                                selectedExercisesSets.length -
                                                    1;
                                          });
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: HFColors().primaryColor()),
                                          child: Icon(
                                            CupertinoIcons.add,
                                            color: HFColors().secondaryColor(),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Column(
                                  children: <Widget>[
                                    if (selectedExercisesSets[selectedSet]
                                            ['exercises']
                                        .isNotEmpty)
                                      for (int index = 0;
                                          index <
                                              selectedExercisesSets[selectedSet]
                                                      ['exercises']
                                                  .length;
                                          index += 1)
                                        Builder(builder: (context) {
                                          List<dynamic> set =
                                              selectedExercisesSets[selectedSet]
                                                  ['exercises'];

                                          var exerciseModel = set[index];

                                          return HFTrainingListViewTile(
                                            onDelete: () {
                                              setState(() {
                                                set.removeAt(index);
                                              });
                                            },
                                            onTap: () {
                                              showExerciseModal(
                                                  true, exerciseModel);
                                            },
                                            name: exerciseModel['name'],
                                            amount: exerciseModel[
                                                            'repetitionType'] ==
                                                        'time' &&
                                                    exerciseModel['v2']
                                                ? exerciseModel['amount']
                                                    ['durationString']
                                                : exerciseModel['amount'],
                                            repetitions:
                                                exerciseModel['repetitions'],
                                            series: exerciseModel['series'],
                                            pauseTime: exerciseModel['v2']
                                                ? exerciseModel['pauseTime']
                                                    ['durationString']
                                                : '',
                                            type:
                                                exerciseModel['repetitionType'],
                                            note: exerciseModel['note'],
                                            warmups: exerciseModel['v2']
                                                ? exerciseModel['warmups']
                                                : [],
                                            useImage: false,
                                            showDelete: true,
                                          );
                                        }),
                                    if (selectedExercisesSets[selectedSet]
                                            ['exercises']
                                        .isEmpty)
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    if (selectedExercisesSets[selectedSet]
                                            ['exercises']
                                        .isEmpty)
                                      HFParagrpah(
                                        size: 9,
                                        text: (selectedExercisesSets[
                                                    selectedSet]
                                                .isEmpty)
                                            ? 'Select a set or add a exercise'
                                            : 'No exercises added',
                                        textAlign: TextAlign.center,
                                      ),
                                    if (selectedExercisesSets[selectedSet]
                                            ['exercises']
                                        .isEmpty)
                                      const SizedBox(
                                        height: 20,
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: HFColors().redColor()),
                                        child: Icon(
                                          CupertinoIcons.trash,
                                          color: HFColors().whiteColor(),
                                          size: 20,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (selectedExercisesSets.length ==
                                              1) {
                                            selectedExercisesSets = [
                                              {'exercises': []}
                                            ];
                                          } else {
                                            selectedExercisesSets
                                                .removeAt(selectedSet);

                                            selectedSet = 0;
                                          }
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: HFButton(
                                        text: 'Add exercise to list',
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        onPressed: () {
                                          setState(() {
                                            // pullUp = true;

                                            exerciseStream = getStream(
                                                true,
                                                context
                                                    .read<HFGlobalState>()
                                                    .userDisplayName,
                                                exerciseSearchText);

                                            showExerciseModal(false);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const HFHeading(
                            size: 5,
                            text: 'Select a location:',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(COLLECTION_LOCATIONS)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: HFParagrpah(
                                    text: 'No locations.',
                                    size: 10,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              var data = snapshot.data as QuerySnapshot;

                              if (data.docs.isEmpty) {
                                return const Center(
                                  child: HFParagrpah(
                                    text: 'No locations.',
                                    size: 10,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return Wrap(
                                direction: Axis.horizontal,
                                runSpacing: 8,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  ...data.docs.map(
                                    (location) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              selectedLocation = location['id'];
                                              selectedLocationName =
                                                  location['name'];
                                            });
                                          },
                                          child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: selectedLocationName ==
                                                        location['name']
                                                    ? HFColors().primaryColor()
                                                    : HFColors()
                                                        .secondaryLightColor(),
                                              ),
                                              child: HFParagrpah(
                                                text: location['name'],
                                                size: 8,
                                                color: selectedLocationName ==
                                                        location['name']
                                                    ? HFColors()
                                                        .secondaryColor()
                                                    : HFColors().whiteColor(),
                                              )),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const HFHeading(
                            size: 5,
                            text: 'Select color:',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              colorBox(
                                HFColors().primaryColor(),
                                selectedColor == 'primaryColor',
                                () {
                                  setState(() {
                                    selectedColor = 'primaryColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().redColor(),
                                selectedColor == 'redColor',
                                () {
                                  setState(() {
                                    selectedColor = 'redColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().greenColor(),
                                selectedColor == 'greenColor',
                                () {
                                  setState(() {
                                    selectedColor = 'greenColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().yellowColor(),
                                selectedColor == 'yellowColor',
                                () {
                                  setState(() {
                                    selectedColor = 'yellowColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().whiteColor(),
                                selectedColor == 'whiteColor',
                                () {
                                  setState(() {
                                    selectedColor = 'whiteColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().purpleColor(),
                                selectedColor == 'purpleColor',
                                () {
                                  setState(() {
                                    selectedColor = 'purpleColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().pinkColor(),
                                selectedColor == 'pinkColor',
                                () {
                                  setState(() {
                                    selectedColor = 'pinkColor';
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              colorBox(
                                HFColors().blueColor(),
                                selectedColor == 'blueColor',
                                () {
                                  setState(() {
                                    selectedColor = 'blueColor';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const HFHeading(
                            text: 'Workout notes:',
                            size: 5,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          HFInput(
                            controller: eventNoteController,
                            keyboardType: TextInputType.multiline,
                            hintText: 'Workout notes',
                            maxLines: 8,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          HFButton(
                            text: isLoading
                                ? widget.isEdit
                                    ? 'Updating...'
                                    : 'Creating...'
                                : widget.isEdit
                                    ? 'Update workout'
                                    : 'Create workout',
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {
                              var newId =
                                  widget.isEdit ? widget.id : const Uuid().v4();

                              var eventData = {
                                'v2': true,
                                'id': newId,
                                'title': eventNameController.text,
                                'date': '$selectedEventDate',
                                'startTime': eventStartController.text,
                                'endTime': eventEndController.text,
                                'client': {
                                  'id': selectedClient,
                                  'name': selectedClientName,
                                },
                                'exercises': selectedExercisesSets,
                                'color': selectedColor,
                                'location': selectedLocationName,
                                'notes': eventNoteController.text,
                                'isDone': false,
                                'clientFeedback': '',
                              };

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                if (widget.isEdit) {
                                  HFFirebaseFunctions()
                                      .getFirebaseAuthUser(context)
                                      .collection(COLLECTION_DAYS)
                                      .doc('${selectedEventDate}')
                                      .collection(COLLECTION_EVENTS)
                                      .doc(newId)
                                      .update(eventData)
                                      .then((value) {
                                    var newDate = DateTime.now();
                                    HFFirebaseFunctions()
                                        .getFirebaseAuthUser(context)
                                        .update({
                                      'changed': '$newDate',
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection(COLLECTION_CLIENTS)
                                          .doc(selectedClient)
                                          .collection(COLLECTION_DAYS)
                                          .doc('${selectedEventDate}')
                                          .collection(COLLECTION_EVENTS)
                                          .doc(newId)
                                          .update(eventData)
                                          .then((value) {
                                        FirebaseFirestore.instance
                                            .collection(COLLECTION_CLIENTS)
                                            .doc(selectedClient)
                                            .update({
                                          'changed': '$newDate',
                                        });
                                      });
                                    }).then((value) {
                                      context
                                          .read<HFGlobalState>()
                                          .setCalendarLastUpdated('$newDate');

                                      Navigator.pop(context);
                                    });

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(getSnackBar(
                                      text: 'Workout updated',
                                      color:
                                          HFColors().primaryColor(opacity: 1),
                                    ));
                                  }).catchError((error) => {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(getSnackBar(
                                              text: 'There was an error',
                                              color: HFColors().redColor(),
                                            ))
                                          });
                                } else {
                                  HFFirebaseFunctions()
                                      .getFirebaseAuthUser(context)
                                      .collection(COLLECTION_DAYS)
                                      .doc('${selectedEventDate}')
                                      .collection(COLLECTION_EVENTS)
                                      .doc(newId)
                                      .set(eventData)
                                      .then((value) {
                                    initDay(selectedEventDate);

                                    var newDate = DateTime.now();
                                    HFFirebaseFunctions()
                                        .getFirebaseAuthUser(context)
                                        .update({
                                      'changed': '$newDate',
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection(COLLECTION_CLIENTS)
                                          .doc(selectedClient)
                                          .collection(COLLECTION_DAYS)
                                          .doc('${selectedEventDate}')
                                          .collection(COLLECTION_EVENTS)
                                          .doc(newId)
                                          .set(eventData)
                                          .then((value) {
                                        initClientDay(
                                            selectedEventDate, selectedClient);
                                        FirebaseFirestore.instance
                                            .collection(COLLECTION_CLIENTS)
                                            .doc(selectedClient)
                                            .update({
                                          'changed': '$newDate',
                                        });
                                      }).then((value) {
                                        FirebaseFirestore.instance
                                            .collection(COLLECTION_CLIENTS)
                                            .doc(selectedClient)
                                            .get()
                                            .then((clientRef) {
                                          clientRef.reference
                                              .collection(
                                                  COLLECTION_NOTIFICATIONS)
                                              .doc()
                                              .set({
                                            'type': 'new-workout',
                                            'token':
                                                clientRef['notificationToken'],
                                            'read': false,
                                            'trainerName': context
                                                .read<HFGlobalState>()
                                                .userName,
                                            'trainerImage': context
                                                .read<HFGlobalState>()
                                                .userImage,
                                            'date': '${DateTime.now()}',
                                            'data': {
                                              'id': newId,
                                              'title': eventNameController.text,
                                              'date': '$selectedEventDate',
                                              'startTime':
                                                  eventStartController.text,
                                              'endTime':
                                                  eventEndController.text,
                                              'client': {
                                                'id': selectedClient,
                                                'name': selectedClientName,
                                              },
                                              'exercises':
                                                  selectedExercisesSets,
                                              'color': selectedColor,
                                              'location': selectedLocationName,
                                              'notes': eventNoteController.text,
                                              'isDone': false,
                                              'clientFeedback': '',
                                            }
                                          });

                                          clientRef.reference.update({
                                            'unreadNotifications': clientRef[
                                                    'unreadNotifications'] +
                                                1
                                          });
                                        });
                                      });
                                    }).then((value) {
                                      context
                                          .read<HFGlobalState>()
                                          .setCalendarLastUpdated('$newDate');

                                      Navigator.pop(context);
                                    });

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(getSnackBar(
                                      text: 'New workout created',
                                      color:
                                          HFColors().primaryColor(opacity: 1),
                                    ));
                                  }).catchError((error) {
                                    print(error);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      getSnackBar(
                                        text: 'There was an error',
                                        color: HFColors().redColor(),
                                      ),
                                    );
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  getSnackBar(
                                    text: 'Please fill in required fields',
                                    color: HFColors().redColor(),
                                  ),
                                );
                              }

                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getTrainingsStream(searchText) {
    return HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection(COLLECTION_TRAININGS)
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }

  getClientsStream(searchText) {
    return HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection(COLLECTION_CLIENTS)
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }

  getStream(isCoach, coachName, searchText) {
    var coaches = ['C4Y'];

    if (isCoach) {
      coaches.add(coachName);
    }

    return FirebaseFirestore.instance
        .collection(COLLECTION_EXERCISES)
        .where('author', whereIn: coaches)
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }

  void showExerciseModal(isEdit, [exercise]) {
    List<String> selectedTypes = [];
    String exerciseSelected = '';
    ScrollController modalSheetScrollController = ScrollController();
    final TextEditingController exerciseSearchFieldController =
        TextEditingController();

    final TextEditingController exerciseTypeNumberController =
        TextEditingController();
    final TextEditingController editAdditionalExerciseAmountController =
        TextEditingController();

    final TextEditingController editAdditionalExerciseRepetitionsController =
        TextEditingController();
    Duration editAdditionalExerciseBreakDuration =
        const Duration(seconds: 0, minutes: 0);
    Duration editAdditionalExerciseAmountDuration =
        const Duration(seconds: 0, minutes: 0);
    Duration editAdditionalWarmupAmountDuration =
        const Duration(seconds: 0, minutes: 0);
    final TextEditingController editAdditionalExerciseBreakController =
        TextEditingController();
    final TextEditingController editAdditionalExerciseSeriesController =
        TextEditingController();
    final TextEditingController editAdditionalExerciseNoteController =
        TextEditingController();
    final TextEditingController editAdditionalExerciseWarmupAmountController =
        TextEditingController();
    final TextEditingController editAdditionalExerciseWarmupRepsController =
        TextEditingController();
    List<dynamic> editAdditionalExerciseWarmups = [];
    int editAdditionalExerciseWarmupselected = -1;

    String modalExerciseSearchText = '';
    Stream modalExerciseStream = getStream(true,
        context.read<HFGlobalState>().userDisplayName, modalExerciseSearchText);

    String exerciseDescription = '';
    String exerciseVideo = '';
    String exerciseThumbnail = '';
    String exerciseIdSelected = '';
    String exerciseRepetitionType = '';
    var defaultSet = false;

    // edit exercise modal
    showModalBottomSheet(
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          controller: modalSheetScrollController,
          child: StatefulBuilder(builder: (context, editModalSetState) {
            if (isEdit && !defaultSet) {
              editModalSetState(() {
                editAdditionalExerciseAmountController.text =
                    '${exercise['repetitionType'] == 'time' ? exercise['amount']['durationString'] : exercise['amount']}';
                if (exercise['repetitionType'] == 'time') {
                  editAdditionalExerciseAmountDuration =
                      parseTime(exercise['amount']['duration']);
                }
                editAdditionalExerciseRepetitionsController.text =
                    exercise['repetitions'];
                editAdditionalExerciseSeriesController.text =
                    exercise['series'];
                editAdditionalExerciseBreakController.text =
                    '${exercise['pauseTime']['durationString']}';
                editAdditionalExerciseBreakDuration =
                    parseTime(exercise['pauseTime']['duration']);

                editAdditionalExerciseNoteController.text = exercise['note'];
                editAdditionalExerciseWarmups = exercise['warmups'];
                exerciseSelected = exercise['name'];
                exerciseIdSelected = exercise['id'];
                exerciseRepetitionType = exercise['repetitionType'];

                defaultSet = true;
              });
            }

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
                  Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: HFHeading(
                          size: 6,
                          maxLines: 2,
                          text: isEdit
                              ? 'Edit ${exercise['name']}'
                              : 'Add exercise',
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Icon(
                            CupertinoIcons.multiply,
                            color: HFColors().primaryColor(),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  getTypeFilters(editModalSetState, selectedTypes),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HFColors().secondaryLightColor(opacity: 0.3),
                      border: Border.all(
                        width: 1,
                        color: HFColors().primaryColor(opacity: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 250,
                        minHeight: 250,
                      ),
                      child: StreamBuilder(
                        stream: modalExerciseStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: HFParagrpah(
                                text: 'No exercises. no data',
                                size: 10,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          var data = snapshot.data as QuerySnapshot;

                          if (data.docs.isEmpty) {
                            return const Center(
                              child: HFParagrpah(
                                text: 'No exercises.',
                                size: 10,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return ListView(
                            shrinkWrap: true,
                            children: [
                              ...data.docs.map((exercise) {
                                bool showTile = false;
                                List<dynamic> exerciseTypes = exercise['types'];

                                if (selectedTypes.isNotEmpty) {
                                  exerciseTypes.forEach((type) {
                                    if (selectedTypes.contains(type) &&
                                        !showTile) {
                                      showTile = true;
                                    }
                                  });

                                  if (!showTile) {
                                    return const SizedBox(
                                      height: 0,
                                    );
                                  }
                                }

                                return HFSelectListViewTile(
                                  key: Key(exercise['id']),
                                  name: exercise['name'],
                                  imageUrl: exercise['videoThumbnail'],
                                  showAvailable: false,
                                  showTags: true,
                                  tags: exercise['types'],
                                  isSelected:
                                      exerciseSelected == exercise['name'],
                                  headingMargin: 0,
                                  imageSize: 70,
                                  backgroundColor: HFColors().secondaryColor(),
                                  id: exercise['id'],
                                  useSpacerBottom: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HFParagrpah(
                                        text: 'Author: ${exercise['author']}',
                                        size: 5,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      HFParagrpah(
                                        text: exercise['description'],
                                        size: 6,
                                        maxLines: 1,
                                        color:
                                            HFColors().whiteColor(opacity: 0.7),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    editModalSetState(() {
                                      editAdditionalExerciseWarmups = [];
                                      editAdditionalExerciseAmountDuration =
                                          const Duration(
                                              minutes: 0, milliseconds: 0);
                                      editAdditionalExerciseAmountController
                                          .text = '';
                                      exerciseTypeNumberController.text = '';
                                      exerciseDescription =
                                          exercise['description'];
                                      exerciseVideo = exercise['video'];
                                      exerciseThumbnail =
                                          exercise['videoThumbnail'];
                                      exerciseSelected = exercise['name'];
                                      exerciseIdSelected = exercise['id'];
                                      exerciseRepetitionType =
                                          exercise['repetitionType'];
                                      exerciseTypes = exercise['types'];
                                    });
                                  },
                                );
                              })
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  HFInput(
                    controller: exerciseSearchFieldController,
                    onChanged: (value) {
                      editModalSetState(() {
                        modalExerciseSearchText = value;

                        modalExerciseStream = getStream(
                            true,
                            context.read<HFGlobalState>().userDisplayName,
                            value);
                      });
                    },
                    hintText: 'Search for exercise',
                    keyboardType: TextInputType.text,
                    verticalContentPadding: 12,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        flex: 1,
                        child: HFInputNumber(
                          labelText: exerciseRepetitionType == 'weight'
                              ? 'Weight (kg)'
                              : exerciseRepetitionType == 'time'
                                  ? 'Time'
                                  : '',
                          controller: editAdditionalExerciseAmountController,
                          readOnly: exerciseRepetitionType == 'time',
                          onTap: () {
                            if (exerciseRepetitionType != 'time') {
                              scrollByDistance(modalSheetScrollController, 190);

                              editAdditionalExerciseAmountController.selection =
                                  TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          editAdditionalExerciseAmountController
                                              .value.text.length);
                            }

                            if (exerciseRepetitionType == 'time') {
                              return showSheet(
                                context,
                                child: SizedBox(
                                  height: 180,
                                  child: CupertinoTimerPicker(
                                      initialTimerDuration:
                                          editAdditionalExerciseAmountDuration,
                                      secondInterval: 5,
                                      mode: CupertinoTimerPickerMode.ms,
                                      onTimerDurationChanged: (time) {
                                        editAdditionalExerciseAmountDuration =
                                            time;
                                      }),
                                ),
                                onClicked: () {
                                  final value =
                                      "${editAdditionalExerciseAmountDuration.inMinutes.remainder(60) == 0 ? '' : '${editAdditionalExerciseAmountDuration.inMinutes.remainder(60)}m'} ${editAdditionalExerciseAmountDuration.inSeconds.remainder(60) == 0 ? '' : '${editAdditionalExerciseAmountDuration.inSeconds.remainder(60)}s'}";

                                  editAdditionalExerciseAmountController.text =
                                      value;

                                  Navigator.pop(context);
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: HFInputNumber(
                          labelText: 'Series',
                          controller: editAdditionalExerciseSeriesController,
                          onTap: (() {
                            scrollByDistance(modalSheetScrollController, 190);
                            editAdditionalExerciseSeriesController.selection =
                                TextSelection(
                                    baseOffset: 0,
                                    extentOffset:
                                        editAdditionalExerciseSeriesController
                                            .value.text.length);
                          }),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (exerciseRepetitionType == 'weight')
                        Expanded(
                          flex: 1,
                          child: HFInputNumber(
                            labelText: 'Reps',
                            controller:
                                editAdditionalExerciseRepetitionsController,
                            onTap: (() {
                              scrollByDistance(modalSheetScrollController, 190);
                              editAdditionalExerciseRepetitionsController
                                      .selection =
                                  TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          editAdditionalExerciseRepetitionsController
                                              .value.text.length);
                            }),
                          ),
                        ),
                      if (exerciseRepetitionType == 'weight')
                        const SizedBox(
                          width: 10,
                        ),
                      Expanded(
                        flex: 1,
                        child: HFInputNumber(
                          labelText: 'Break',
                          controller: editAdditionalExerciseBreakController,
                          readOnly: true,
                          onTap: () {
                            showSheet(
                              context,
                              child: SizedBox(
                                height: 180,
                                child: CupertinoTimerPicker(
                                    initialTimerDuration:
                                        editAdditionalExerciseBreakDuration,
                                    secondInterval: 5,
                                    mode: CupertinoTimerPickerMode.ms,
                                    onTimerDurationChanged: (time) {
                                      editAdditionalExerciseBreakDuration =
                                          time;
                                    }),
                              ),
                              onClicked: () {
                                final value =
                                    "${editAdditionalExerciseBreakDuration.inMinutes.remainder(60) == 0 ? '' : '${editAdditionalExerciseBreakDuration.inMinutes.remainder(60)}m'} ${editAdditionalExerciseBreakDuration.inSeconds.remainder(60) == 0 ? '' : '${editAdditionalExerciseBreakDuration.inSeconds.remainder(60)}s'}";

                                editAdditionalExerciseBreakController.text =
                                    value;

                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HFHeading(
                        text: 'Warmup:',
                        size: 2,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: HFInputNumber(
                              labelText: exerciseRepetitionType == 'weight'
                                  ? 'Weight (kg)'
                                  : exerciseRepetitionType == 'time'
                                      ? 'Time'
                                      : '',
                              controller:
                                  editAdditionalExerciseWarmupAmountController,
                              readOnly: exerciseRepetitionType == 'time',
                              onTap: () {
                                if (exerciseRepetitionType == 'time') {
                                  return showSheet(
                                    context,
                                    child: SizedBox(
                                      height: 180,
                                      child: CupertinoTimerPicker(
                                          secondInterval: 5,
                                          mode: CupertinoTimerPickerMode.ms,
                                          onTimerDurationChanged: (time) {
                                            editAdditionalWarmupAmountDuration =
                                                time;
                                          }),
                                    ),
                                    onClicked: () {
                                      final value =
                                          "${editAdditionalWarmupAmountDuration.inMinutes.remainder(60) == 0 ? '' : '${editAdditionalWarmupAmountDuration.inMinutes.remainder(60)}m'} ${editAdditionalWarmupAmountDuration.inSeconds.remainder(60) == 0 ? '' : '${editAdditionalWarmupAmountDuration.inSeconds.remainder(60)}s'}";

                                      editAdditionalExerciseWarmupAmountController
                                          .text = value;

                                      Navigator.pop(context);
                                    },
                                  );
                                }

                                scrollByDistance(
                                    modalSheetScrollController, 315);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: HFInputNumber(
                              labelText: 'Reps',
                              controller:
                                  editAdditionalExerciseWarmupRepsController,
                              onTap: () {
                                scrollByDistance(
                                    modalSheetScrollController, 315);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              const SizedBox(
                                height: 13,
                              ),
                              InkWell(
                                onTap: () {
                                  editModalSetState(
                                    () {
                                      if (editAdditionalExerciseWarmupselected ==
                                          -1) {
                                        editAdditionalExerciseWarmups.add({
                                          'repetitionType':
                                              exerciseRepetitionType,
                                          'amount': exerciseRepetitionType ==
                                                  'time'
                                              ? {
                                                  'duration':
                                                      editAdditionalWarmupAmountDuration
                                                          .toString(),
                                                  'durationString':
                                                      editAdditionalExerciseWarmupAmountController
                                                                  .text ==
                                                              ''
                                                          ? '0s'
                                                          : editAdditionalExerciseWarmupAmountController
                                                              .text
                                                }
                                              : editAdditionalExerciseWarmupAmountController
                                                  .text,
                                          'reps': editAdditionalExerciseWarmupRepsController
                                                      .text ==
                                                  ''
                                              ? '0'
                                              : editAdditionalExerciseWarmupRepsController
                                                  .text
                                        });
                                      } else {
                                        editAdditionalExerciseWarmups[
                                            editAdditionalExerciseWarmupselected] = {
                                          'repetitionType':
                                              exerciseRepetitionType,
                                          'amount': exerciseRepetitionType ==
                                                  'time'
                                              ? {
                                                  'duration':
                                                      editAdditionalWarmupAmountDuration
                                                          .toString(),
                                                  'durationString':
                                                      editAdditionalExerciseWarmupAmountController
                                                                  .text ==
                                                              ''
                                                          ? '0s'
                                                          : editAdditionalExerciseWarmupAmountController
                                                              .text
                                                }
                                              : editAdditionalExerciseWarmupAmountController
                                                  .text,
                                          'reps': editAdditionalExerciseWarmupRepsController
                                                      .text ==
                                                  ''
                                              ? '0'
                                              : editAdditionalExerciseWarmupRepsController
                                                  .text
                                        };
                                      }

                                      editAdditionalWarmupAmountDuration =
                                          const Duration(
                                              seconds: 0, minutes: 0);
                                      editAdditionalExerciseWarmupAmountController
                                          .text = '';
                                      editAdditionalExerciseWarmupRepsController
                                          .text = '';
                                      editAdditionalExerciseWarmupselected = -1;
                                    },
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: HFColors().primaryColor(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.add,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      for (var warmupIndex = 0;
                          warmupIndex < editAdditionalExerciseWarmups.length;
                          warmupIndex += 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Center(
                                  child: HFHeading(
                                    text: '${warmupIndex + 1}.',
                                    size: 2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: HFColors().whiteColor(opacity: 0.1),
                                    borderRadius: BorderRadius.circular(12),
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
                                              textAlign: TextAlign.center,
                                              text: exerciseRepetitionType ==
                                                      'time'
                                                  ? 'Time'
                                                  : 'Weight (kg)',
                                            ),
                                            HFHeading(
                                              text: exerciseRepetitionType ==
                                                      'time'
                                                  ? editAdditionalExerciseWarmups[
                                                          warmupIndex]['amount']
                                                      ['durationString']
                                                  : editAdditionalExerciseWarmups[
                                                      warmupIndex]['amount'],
                                              textAlign: TextAlign.center,
                                              size: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 16,
                                        color:
                                            HFColors().whiteColor(opacity: 0.4),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const HFParagrpah(
                                              textAlign: TextAlign.center,
                                              text: 'Reps.',
                                            ),
                                            HFHeading(
                                              text:
                                                  editAdditionalExerciseWarmups[
                                                      warmupIndex]['reps'],
                                              textAlign: TextAlign.center,
                                              size: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                onTap: () {
                                  editModalSetState(() {
                                    editAdditionalExerciseWarmupselected =
                                        warmupIndex;

                                    if (exerciseRepetitionType == 'time') {
                                      editAdditionalWarmupAmountDuration =
                                          parseTime(
                                              editAdditionalExerciseWarmups[
                                                      warmupIndex]['amount']
                                                  ['duration']);
                                    }
                                    editAdditionalExerciseWarmupAmountController
                                            .text =
                                        exerciseRepetitionType == 'time'
                                            ? editAdditionalExerciseWarmups[
                                                    warmupIndex]['amount']
                                                ['durationString']
                                            : editAdditionalExerciseWarmups[
                                                warmupIndex]['amount'];
                                    editAdditionalExerciseWarmupRepsController
                                            .text =
                                        editAdditionalExerciseWarmups[
                                            warmupIndex]['reps'];
                                  });
                                },
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                      color: HFColors().primaryColor(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.pen,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                onTap: () {
                                  editModalSetState(
                                    () {
                                      editAdditionalExerciseWarmups
                                          .removeAt(warmupIndex);
                                    },
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                      color: HFColors().redColor(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.trash,
                                      size: 18,
                                      color: HFColors().whiteColor(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                  HFInput(
                    controller: editAdditionalExerciseNoteController,
                    keyboardType: TextInputType.multiline,
                    labelText: 'Note',
                    hintText: 'Exercise notes',
                    minLines: 3,
                    maxLines: 3,
                    onTap: () {
                      scrollByDistance(modalSheetScrollController, 600);
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  HFButton(
                    onPressed: () {
                      setState(() {
                        if (isEdit) {
                          exercise['name'] = exerciseSelected;
                          exercise['exerciseId'] = exerciseIdSelected;
                          exercise['amount'] = exerciseRepetitionType == 'time'
                              ? {
                                  'duration':
                                      editAdditionalExerciseAmountDuration
                                          .toString(),
                                  'durationString':
                                      editAdditionalExerciseAmountController
                                          .text,
                                }
                              : editAdditionalExerciseAmountController.text ==
                                      ''
                                  ? '0'
                                  : editAdditionalExerciseAmountController.text;
                          exercise['repetitions'] =
                              editAdditionalExerciseRepetitionsController
                                          .text ==
                                      ''
                                  ? '0'
                                  : editAdditionalExerciseRepetitionsController
                                      .text;
                          exercise['series'] =
                              editAdditionalExerciseSeriesController.text == ''
                                  ? '0'
                                  : editAdditionalExerciseSeriesController.text;
                          exercise['pauseTime'] = {
                            'duration':
                                editAdditionalExerciseBreakDuration.toString(),
                            'durationString':
                                editAdditionalExerciseBreakController.text == ''
                                    ? '0'
                                    : editAdditionalExerciseBreakController.text
                          };

                          exercise['note'] =
                              editAdditionalExerciseNoteController.text;
                          exercise['warmups'] = editAdditionalExerciseWarmups;
                          exercise['repetitionType'] = exerciseRepetitionType;
                          exercise['types'] = exerciseTypes;
                          exercise['description'] = exerciseDescription;
                          exercise['video'] = exerciseVideo;
                          exercise['videoThumbnail'] = exerciseThumbnail;
                        } else {
                          var newId = const Uuid().v4();
                          selectedExercisesSets[selectedSet]['exercises'].add({
                            'v2': true,
                            'id': newId,
                            'name': exerciseSelected,
                            'exerciseId': exerciseIdSelected,
                            'amount': exerciseRepetitionType == 'time'
                                ? {
                                    'duration':
                                        editAdditionalExerciseAmountDuration
                                            .toString(),
                                    'durationString':
                                        editAdditionalExerciseAmountController
                                            .text,
                                  }
                                : editAdditionalExerciseAmountController.text ==
                                        ''
                                    ? '0'
                                    : editAdditionalExerciseAmountController
                                        .text,
                            'repetitions':
                                editAdditionalExerciseRepetitionsController
                                            .text ==
                                        ''
                                    ? '0'
                                    : editAdditionalExerciseRepetitionsController
                                        .text,
                            'series': editAdditionalExerciseSeriesController
                                        .text ==
                                    ''
                                ? '0'
                                : editAdditionalExerciseSeriesController.text,
                            'pauseTime': {
                              'duration': editAdditionalExerciseBreakDuration
                                  .toString(),
                              'durationString':
                                  editAdditionalExerciseBreakController.text ==
                                          ''
                                      ? '0'
                                      : editAdditionalExerciseBreakController
                                          .text
                            },
                            'warmups': editAdditionalExerciseWarmups,
                            'repetitionType': exerciseRepetitionType,
                            'note': editAdditionalExerciseNoteController.text,
                            'types': exerciseTypes,
                            'description': exerciseDescription,
                            'video': exerciseVideo,
                            'videoThumbnail': exerciseThumbnail,
                            'clientFeedback': ''
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                              getSnackBar(text: 'Exercise added'));
                        }
                      });

                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.all(16),
                    text:
                        isEdit ? 'Update ${exercise['name']}' : 'Add exercise',
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom < 40
                        ? 40
                        : MediaQuery.of(context).viewInsets.bottom,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget getTypeFilters(editModalSetState, selectedTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HFParagrpah(
          text: 'Filter by exercise type:',
          size: 7,
        ),
        const SizedBox(
          height: 6,
        ),
        SizedBox(
          height: 40,
          child: StreamBuilder<Object>(
            stream: FirebaseFirestore.instance
                .collection(COLLECTION_EXERCISETYPE)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: HFParagrpah(
                  text: '',
                ));
              }

              var data = snapshot.data as QuerySnapshot;

              if (data.docs.isEmpty) {
                return const Center(
                  child: HFParagrpah(
                    text: '',
                    size: 10,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...data.docs.map(
                      (type) {
                        return Row(
                          children: [
                            Center(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (() {
                                  editModalSetState(() {
                                    if (selectedTypes.contains(type['name'])) {
                                      selectedTypes.remove(type['name']);
                                    } else {
                                      selectedTypes.add(type['name']);
                                    }
                                  });
                                }),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.only(
                                      right: 10, bottom: 10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedTypes
                                              .contains(type['name'])
                                          ? HFColors().primaryColor()
                                          : HFColors().secondaryLightColor(),
                                      border: Border.all(
                                        color: HFColors().primaryColor(),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: HFParagrpah(
                                      text: type['name'],
                                      size: 8,
                                      color:
                                          selectedTypes.contains(type['name'])
                                              ? HFColors().secondaryLightColor()
                                              : HFColors().primaryColor(),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      width: 16,
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget getWarmupExerciseTile(amount, reps, type, index, onDelete) {
  return Column(
    children: [
      Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: HFHeading(
              text: '${index + 1}.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HFColors().whiteColor(opacity: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HFParagrpah(
                          textAlign: TextAlign.center,
                          text: type == 'time' ? 'Time' : 'Weight (kg)',
                        ),
                        HFHeading(
                          text: amount,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HFParagrpah(
                          textAlign: TextAlign.center,
                          text: 'Reps.',
                        ),
                        HFHeading(
                          text: reps,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: onDelete,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: HFColors().redColor(),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: HFColors().whiteColor(),
                ),
              ),
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      )
    ],
  );
}

void showSheet(
  BuildContext context, {
  required Widget child,
  required VoidCallback onClicked,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        child,
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: onClicked,
        child: Text(
          'Done',
          style: GoogleFonts.getFont(
            'Manrope',
            textStyle: TextStyle(
              color: HFColors().secondaryColor(),
            ),
          ),
        ),
      ),
    ),
  );
}

void initDay(date) {
  HFFirebaseFunctions()
      .getTrainersUser()
      .collection(COLLECTION_DAYS)
      .doc('$date')
      .set({'exists': true}).catchError((error) => print(error));
}

void initClientDay(date, id) {
  HFFirebaseFunctions()
      .getClientsUser(id)
      .collection(COLLECTION_DAYS)
      .doc('$date')
      .set({'exists': true}).catchError((error) => print(error));
}

List getExerciseMap(List exercises) {
  return exercises.map((set) {
    return {'exercises': set};
  }).toList();
}

Widget colorBox(color, isActive, onTap) {
  return Expanded(
    flex: 1,
    child: InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(
                width: 2,
                color:
                    isActive ? HFColors().primaryColor() : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getExerciseTab(int number, isActive, onTap, List sets) {
  return Expanded(
    child: Material(
      color: Colors.transparent,
      elevation: 12,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: isActive
                  ? HFColors().primaryColor(opacity: 0.3)
                  : HFColors().secondaryLightColor(),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(number > 1 ? 0 : 12),
                bottomLeft: Radius.circular(number > 1 ? 0 : 12),
                topRight: Radius.circular(number < sets.length ? 0 : 12),
                bottomRight: Radius.circular(number < sets.length ? 0 : 12),
              )),
          height: 40,
          child: Center(
            child: HFHeading(
              text: 'Set $number',
              color: HFColors().primaryColor(),
            ),
          ),
        ),
      ),
    ),
  );
}

scrollByDistance(ScrollController controller, double distance) {
  controller.animateTo(
    distance,
    curve: Curves.easeInOut,
    duration: const Duration(milliseconds: 200),
  );
}
