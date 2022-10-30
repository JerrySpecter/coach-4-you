import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
    this.isDuplicate = false,
  }) : super(key: key);

  @override
  AddEventScreenState createState() => AddEventScreenState();
}

class AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController editexerciseamountcontroller =
      TextEditingController();
  final TextEditingController editexerciserepetitionscontroller =
      TextEditingController();
  final TextEditingController editexerciseseriescontroller =
      TextEditingController();
  final TextEditingController editexercisenotecontroller =
      TextEditingController();
  final TextEditingController editadditionalexerciseamountcontroller =
      TextEditingController();
  final TextEditingController editadditionalexerciserepetitionscontroller =
      TextEditingController();
  final TextEditingController editadditionalexerciseseriescontroller =
      TextEditingController();
  final TextEditingController editadditionalexercisenotecontroller =
      TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventStartController = TextEditingController();
  final TextEditingController eventEndController = TextEditingController();
  final TextEditingController eventNoteController = TextEditingController();
  final TextEditingController searchFieldController = TextEditingController();
  final TextEditingController exerciseTypeNumberController =
      TextEditingController();
  final TextEditingController exerciseRepsNumberController =
      TextEditingController();
  final TextEditingController exerciseSeriesNumberController =
      TextEditingController();
  final TextEditingController exerciseNoteController = TextEditingController();
  final TextEditingController exerciseSearchFieldController =
      TextEditingController();
  String exerciseSelected = '';
  String exerciseDescription = '';
  String exerciseVideo = '';
  String exerciseThumbnail = '';
  String exerciseIdSelected = '';
  String exerciseRepetitionType = '';
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

  @override
  void initState() {
    if (widget.date.day == DateTime.now().day &&
        widget.date.month == DateTime.now().month) {
      startTimeInitialDate = DateTime.now();
    } else {
      startTimeInitialDate = widget.date;
    }

    // exerciseTypeNumberController.text = '0';
    // exerciseRepsNumberController.text = '0';
    // exerciseSeriesNumberController.text = '0';
    selectedEventDate = widget.date;
    eventDateController.text = DateFormat('EEE, d/M/y').format(widget.date);
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
      selectedExercises = widget.exercises;
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
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const RootPage(),
        //           ),
        //         );
        //         eventNameController.clear();
        //         eventStartController.clear();
        //         eventEndController.clear();
        //       },
        //       icon: const Icon(CupertinoIcons.multiply))
        // ],
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
                                          minimumDate: DateTime.now()
                                              .subtract(Duration(seconds: 60)),
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
                          HFInput(
                            controller: searchFieldController,
                            onChanged: (value) {
                              setState(() {
                                searchClientsText = value;
                                clientsStream = getClientsStream(searchText);
                              });
                            },
                            hintText: 'Filter clients',
                            keyboardType: TextInputType.text,
                            verticalContentPadding: 12,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 250,
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

                                    var data = snapshot.data as QuerySnapshot;

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
                                              return SizedBox(
                                                height: 0,
                                              );
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                              ),
                                              child: HFSelectListViewTile(
                                                name: client['name'],
                                                useImage: false,
                                                showAvailable: false,
                                                isSelected: selectedClient ==
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
                          HFInput(
                            controller: searchFieldController,
                            onChanged: (value) {
                              setState(() {
                                searchText = value;
                                stream = getTrainingsStream(searchText);
                              });
                            },
                            hintText: 'Filter sets',
                            keyboardType: TextInputType.text,
                            verticalContentPadding: 12,
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
                            child: ClipRRect(
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

                                    var data = snapshot.data as QuerySnapshot;

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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                              ),
                                              child: HFSelectListViewTile(
                                                name: training['name'],
                                                useImage: false,
                                                showAvailable: false,
                                                isSelected: trainingSelected ==
                                                    training['id'],
                                                headingMargin: 0,
                                                imageSize: 48,
                                                id: training['id'],
                                                useSpacerBottom: true,
                                                onTap: () {
                                                  setState(() {
                                                    trainingSelected =
                                                        training['id'];
                                                    trainingNameSelected =
                                                        training['name'];

                                                    selectedTrainingExercises =
                                                        training['exercises'];
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
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const HFHeading(
                            text: 'Selected exercises:',
                            size: 5,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
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
                                if (selectedTrainingExercises.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          HFColors().whiteColor(opacity: 0.05),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        if (selectedTrainingExercises
                                            .isNotEmpty)
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        if (selectedTrainingExercises
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                HFHeading(
                                                  text:
                                                      '$trainingNameSelected exercises:',
                                                  size: 4,
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedTrainingExercises =
                                                          [];
                                                      trainingSelected = '';
                                                      trainingNameSelected = '';
                                                    });
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.trash,
                                                    color:
                                                        HFColors().redColor(),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        if (selectedTrainingExercises
                                            .isNotEmpty)
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        for (int index = 0;
                                            index <
                                                selectedTrainingExercises
                                                    .length;
                                            index += 1)
                                          HFTrainingListViewTile(
                                            key: Key('$index'),
                                            onDelete: () {
                                              setState(() {
                                                selectedTrainingExercises
                                                    .removeAt(index);
                                              });
                                            },
                                            onTap: () {
                                              editexerciseamountcontroller
                                                      .text =
                                                  '${double.parse(selectedTrainingExercises[index]['amount'])}';
                                              editexerciserepetitionscontroller
                                                      .text =
                                                  '${double.parse(selectedTrainingExercises[index]['repetitions'])}';
                                              editexerciseseriescontroller
                                                      .text =
                                                  '${double.parse(selectedTrainingExercises[index]['series'])}';

                                              editexercisenotecontroller.text =
                                                  selectedTrainingExercises[
                                                      index]['note'];
                                              showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 32,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: HFColors()
                                                          .secondaryColor(),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(16),
                                                        topRight:
                                                            Radius.circular(16),
                                                      ),
                                                    ),
                                                    child: SizedBox(
                                                      height: 400,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          HFHeading(
                                                            size: 6,
                                                            text:
                                                                'Edit ${selectedTrainingExercises[index]['name']}',
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Flex(
                                                            direction:
                                                                Axis.horizontal,
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    HFInputNumber(
                                                                  labelText: selectedTrainingExercises[index]
                                                                              [
                                                                              'repetitionType'] ==
                                                                          'weight'
                                                                      ? 'kg'
                                                                      : selectedTrainingExercises[index]['repetitionType'] ==
                                                                              'time'
                                                                          ? 'Minutes'
                                                                          : '',
                                                                  controller:
                                                                      editexerciseamountcontroller,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    HFInputNumber(
                                                                  labelText:
                                                                      'Reps',
                                                                  controller:
                                                                      editexerciserepetitionscontroller,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    HFInputNumber(
                                                                  labelText:
                                                                      'Series',
                                                                  controller:
                                                                      editexerciseseriescontroller,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          HFInput(
                                                            controller:
                                                                editexercisenotecontroller,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            labelText: 'Note',
                                                            hintText:
                                                                'Exercise notes',
                                                            minLines: 3,
                                                            maxLines: 3,
                                                          ),
                                                          const SizedBox(
                                                            height: 40,
                                                          ),
                                                          HFButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                selectedTrainingExercises[
                                                                        index][
                                                                    'amount'] = editexerciseamountcontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editexerciseamountcontroller
                                                                        .text;
                                                                selectedTrainingExercises[
                                                                        index][
                                                                    'repetitions'] = editexerciserepetitionscontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editexerciserepetitionscontroller
                                                                        .text;
                                                                selectedTrainingExercises[
                                                                        index][
                                                                    'series'] = editexerciseseriescontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editexerciseseriescontroller
                                                                        .text;
                                                                selectedTrainingExercises[
                                                                            index]
                                                                        [
                                                                        'note'] =
                                                                    editexercisenotecontroller
                                                                        .text;
                                                              });

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                            text:
                                                                'Update ${selectedTrainingExercises[index]['name']}',
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            name:
                                                '${selectedTrainingExercises[index]['name']}',
                                            amount: double.parse(
                                                selectedTrainingExercises[index]
                                                    ['amount']),
                                            repetitions: double.parse(
                                                selectedTrainingExercises[index]
                                                    ['repetitions']),
                                            series: double.parse(
                                                selectedTrainingExercises[index]
                                                    ['series']),
                                            type:
                                                selectedTrainingExercises[index]
                                                    ['repetitionType'],
                                            note:
                                                selectedTrainingExercises[index]
                                                    ['note'],
                                            useImage: false,
                                            showDelete: false,
                                          ),
                                        if (selectedTrainingExercises.isEmpty)
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        if (selectedTrainingExercises.isEmpty)
                                          const HFParagrpah(
                                            size: 9,
                                            text: 'No sets selected',
                                            textAlign: TextAlign.center,
                                          ),
                                        if (selectedTrainingExercises.isEmpty)
                                          const SizedBox(
                                            height: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Column(
                                  children: <Widget>[
                                    for (int index = 0;
                                        index < selectedExercises.length;
                                        index += 1)
                                      HFTrainingListViewTile(
                                        key: Key('$index'),
                                        onDelete: () {
                                          setState(() {
                                            selectedExercises.removeAt(index);
                                          });
                                        },
                                        onTap: () {
                                          editadditionalexerciseamountcontroller
                                                  .text =
                                              '${double.parse(selectedExercises[index]['amount'])}';
                                          editadditionalexerciserepetitionscontroller
                                                  .text =
                                              '${double.parse(selectedExercises[index]['repetitions'])}';
                                          editadditionalexerciseseriescontroller
                                                  .text =
                                              '${double.parse(selectedExercises[index]['series'])}';

                                          editadditionalexercisenotecontroller
                                                  .text =
                                              selectedExercises[index]['note'];
                                          showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 32,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: HFColors()
                                                      .secondaryColor(),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(16),
                                                    topRight:
                                                        Radius.circular(16),
                                                  ),
                                                ),
                                                child: SizedBox(
                                                  height: 400,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      HFHeading(
                                                        size: 6,
                                                        text:
                                                            'Edit ${selectedExercises[index]['name']}',
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Flex(
                                                        direction:
                                                            Axis.horizontal,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                HFInputNumber(
                                                              labelText: selectedExercises[
                                                                              index]
                                                                          [
                                                                          'repetitionType'] ==
                                                                      'weight'
                                                                  ? 'kg'
                                                                  : selectedExercises[index]
                                                                              [
                                                                              'repetitionType'] ==
                                                                          'time'
                                                                      ? 'Minutes'
                                                                      : '',
                                                              controller:
                                                                  editadditionalexerciseamountcontroller,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                HFInputNumber(
                                                              labelText: 'Reps',
                                                              controller:
                                                                  editadditionalexerciserepetitionscontroller,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                HFInputNumber(
                                                              labelText:
                                                                  'Series',
                                                              controller:
                                                                  editadditionalexerciseseriescontroller,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      HFInput(
                                                        controller:
                                                            editadditionalexercisenotecontroller,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        labelText: 'Note',
                                                        hintText:
                                                            'Exercise notes',
                                                        minLines: 3,
                                                        maxLines: 3,
                                                      ),
                                                      const SizedBox(
                                                        height: 40,
                                                      ),
                                                      HFButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedExercises[
                                                                        index]
                                                                    ['amount'] =
                                                                editadditionalexerciseamountcontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editadditionalexerciseamountcontroller
                                                                        .text;
                                                            selectedExercises[
                                                                        index][
                                                                    'repetitions'] =
                                                                editadditionalexerciserepetitionscontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editadditionalexerciserepetitionscontroller
                                                                        .text;
                                                            selectedExercises[
                                                                        index]
                                                                    ['series'] =
                                                                editadditionalexerciseseriescontroller
                                                                            .text ==
                                                                        ''
                                                                    ? '0'
                                                                    : editadditionalexerciseseriescontroller
                                                                        .text;
                                                            selectedExercises[
                                                                        index]
                                                                    ['note'] =
                                                                editadditionalexercisenotecontroller
                                                                    .text;
                                                          });

                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        text:
                                                            'Update ${selectedExercises[index]['name']}',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        name:
                                            '${selectedExercises[index]['name']}',
                                        amount: double.parse(
                                            selectedExercises[index]['amount']),
                                        repetitions: double.parse(
                                            selectedExercises[index]
                                                ['repetitions']),
                                        series: double.parse(
                                            selectedExercises[index]['series']),
                                        type: selectedExercises[index]
                                            ['repetitionType'],
                                        note: selectedExercises[index]['note'],
                                        useImage: false,
                                        showDelete: true,
                                      ),
                                    if (selectedExercises.isEmpty)
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    if (selectedExercises.isEmpty)
                                      HFParagrpah(
                                        size: 9,
                                        text: (selectedTrainingExercises
                                                    .isEmpty &&
                                                selectedExercises.isEmpty)
                                            ? 'Select a set or add a exercise'
                                            : 'No additional exercises added',
                                        textAlign: TextAlign.center,
                                      ),
                                    if (selectedExercises.isEmpty)
                                      const SizedBox(
                                        height: 20,
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                HFButton(
                                  text: 'Add exercise to list',
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  onPressed: () {
                                    setState(() {
                                      // pullUp = true;

                                      exerciseStream = getStream(
                                          true,
                                          context
                                              .read<HFGlobalState>()
                                              .userDisplayName,
                                          exerciseSearchText);

                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        isScrollControlled: true,
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          minHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                        ),
                                        builder: (context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setModalState) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                                color: HFColors()
                                                    .secondaryLightColor(),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const HFHeading(
                                                            text:
                                                                'Add exercise',
                                                            size: 7,
                                                          ),
                                                          IconButton(
                                                            onPressed: (() {
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                            icon: Icon(
                                                              CupertinoIcons
                                                                  .multiply,
                                                              color: HFColors()
                                                                  .primaryColor(),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            width: 1,
                                                            color: HFColors()
                                                                .primaryColor(
                                                                    opacity:
                                                                        0.2),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                            maxHeight: 350,
                                                            minHeight: 100,
                                                          ),
                                                          child: StreamBuilder(
                                                            stream:
                                                                exerciseStream,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return const Center(
                                                                  child:
                                                                      HFParagrpah(
                                                                    text:
                                                                        'No exercises. no data',
                                                                    size: 10,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                );
                                                              }

                                                              var data = snapshot
                                                                      .data
                                                                  as QuerySnapshot;

                                                              if (data.docs
                                                                  .isEmpty) {
                                                                return const Center(
                                                                  child:
                                                                      HFParagrpah(
                                                                    text:
                                                                        'No exercises.',
                                                                    size: 10,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                );
                                                              }

                                                              return ListView(
                                                                shrinkWrap:
                                                                    true,
                                                                children: [
                                                                  ...data.docs
                                                                      .map(
                                                                    (exercise) {
                                                                      return HFSelectListViewTile(
                                                                        name: exercise[
                                                                            'name'],
                                                                        imageUrl:
                                                                            exercise['videoThumbnail'],
                                                                        showAvailable:
                                                                            false,
                                                                        isSelected:
                                                                            exerciseSelected ==
                                                                                exercise['name'],
                                                                        headingMargin:
                                                                            0,
                                                                        imageSize:
                                                                            48,
                                                                        backgroundColor:
                                                                            HFColors().secondaryColor(),
                                                                        id: exercise[
                                                                            'id'],
                                                                        useSpacerBottom:
                                                                            true,
                                                                        child:
                                                                            Column(
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
                                                                              color: HFColors().whiteColor(opacity: 0.7),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          setModalState(
                                                                              () {
                                                                            exerciseDescription =
                                                                                exercise['description'];
                                                                            exerciseVideo =
                                                                                exercise['video'];
                                                                            exerciseThumbnail =
                                                                                exercise['videoThumbnail'];
                                                                            exerciseSelected =
                                                                                exercise['name'];
                                                                            exerciseIdSelected =
                                                                                exercise['id'];
                                                                            exerciseRepetitionType =
                                                                                exercise['repetitionType'];
                                                                            exerciseTypes =
                                                                                exercise['types'];
                                                                          });
                                                                        },
                                                                      );
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      HFInput(
                                                        controller:
                                                            exerciseSearchFieldController,
                                                        onChanged: (value) {
                                                          setModalState(() {
                                                            exerciseSearchText =
                                                                value;

                                                            exerciseStream = getStream(
                                                                true,
                                                                context
                                                                    .read<
                                                                        HFGlobalState>()
                                                                    .userDisplayName,
                                                                exerciseSearchText);
                                                          });
                                                        },
                                                        hintText:
                                                            'Filter exercises',
                                                        keyboardType:
                                                            TextInputType.text,
                                                        verticalContentPadding:
                                                            12,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      if (exerciseSelected
                                                          .isNotEmpty)
                                                        Flex(
                                                          direction:
                                                              Axis.horizontal,
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: HFInput(
                                                                keyboardType:
                                                                    const TextInputType
                                                                            .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                labelText: exerciseRepetitionType ==
                                                                        'weight'
                                                                    ? 'kg'
                                                                    : exerciseRepetitionType ==
                                                                            'time'
                                                                        ? 'Minutes'
                                                                        : '',
                                                                controller:
                                                                    exerciseTypeNumberController,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: HFInput(
                                                                keyboardType:
                                                                    const TextInputType
                                                                            .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                labelText:
                                                                    'Reps',
                                                                controller:
                                                                    exerciseRepsNumberController,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: HFInput(
                                                                keyboardType:
                                                                    const TextInputType
                                                                            .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                labelText:
                                                                    'Series',
                                                                controller:
                                                                    exerciseSeriesNumberController,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (exerciseSelected
                                                          .isNotEmpty)
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                      HFInput(
                                                        controller:
                                                            exerciseNoteController,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        hintText:
                                                            'Exercise notes',
                                                        maxLines: 8,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      HFButton(
                                                        text: 'Add exercise',
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 16),
                                                        onPressed: () {
                                                          setState(() {
                                                            var newId =
                                                                const Uuid()
                                                                    .v4();
                                                            selectedExercises
                                                                .add({
                                                              'id': newId,
                                                              'name':
                                                                  exerciseSelected,
                                                              'exerciseId':
                                                                  exerciseIdSelected,
                                                              'amount': exerciseTypeNumberController
                                                                          .text ==
                                                                      ''
                                                                  ? '0'
                                                                  : exerciseTypeNumberController
                                                                      .text,
                                                              'repetitions':
                                                                  exerciseRepsNumberController
                                                                              .text ==
                                                                          ''
                                                                      ? '0'
                                                                      : exerciseRepsNumberController
                                                                          .text,
                                                              'series': exerciseSeriesNumberController
                                                                          .text ==
                                                                      ''
                                                                  ? '0'
                                                                  : exerciseSeriesNumberController
                                                                      .text,
                                                              'repetitionType':
                                                                  exerciseRepetitionType,
                                                              'types':
                                                                  exerciseTypes,
                                                              'note':
                                                                  exerciseNoteController
                                                                      .text,
                                                              'description':
                                                                  exerciseDescription,
                                                              'video':
                                                                  exerciseVideo,
                                                              'videoThumbnail':
                                                                  exerciseThumbnail
                                                            });

                                                            exerciseTypeNumberController
                                                                .text = '';
                                                            exerciseTypeNumberController
                                                                .text = '';
                                                            exerciseRepsNumberController
                                                                .text = '';
                                                            exerciseSeriesNumberController
                                                                .text = '';
                                                            exerciseSelected =
                                                                '';
                                                            exerciseIdSelected =
                                                                '';
                                                            exerciseNoteController
                                                                .text = '';
                                                          });

                                                          Navigator.pop(
                                                              context);

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  getSnackBar(
                                                                      text:
                                                                          'Exercise added'));
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom <
                                                                40
                                                            ? 40
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom +
                                                                20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    });
                                  },
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
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: HFColors().primaryColor(opacity: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 180,
                                  minHeight: 60,
                                ),
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('locations')
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

                                    return ListView(
                                      shrinkWrap: true,
                                      children: [
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        ...data.docs.map(
                                          (location) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                              ),
                                              child: HFSelectListViewTile(
                                                name: location['name'],
                                                useImage: false,
                                                showAvailable: false,
                                                isSelected:
                                                    selectedLocationName ==
                                                        location['name'],
                                                headingMargin: 0,
                                                imageSize: 48,
                                                id: location['id'],
                                                useSpacerBottom: true,
                                                onTap: () {
                                                  setState(() {
                                                    selectedLocation =
                                                        location['id'];
                                                    selectedLocationName =
                                                        location['name'];
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
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (selectedLocationName != '')
                            HFParagrpah(
                              text: 'Selected: $selectedLocationName',
                              size: 8,
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

                              var exerciseList = [];

                              exerciseList.addAll(selectedTrainingExercises);
                              exerciseList.addAll(selectedExercises);

                              var eventData = {
                                'id': newId,
                                'title': eventNameController.text,
                                'date': '$selectedEventDate',
                                'startTime': eventStartController.text,
                                'endTime': eventEndController.text,
                                'client': {
                                  'id': selectedClient,
                                  'name': selectedClientName,
                                },
                                'exercises': exerciseList,
                                'color': selectedColor,
                                'location': selectedLocationName,
                                'notes': eventNoteController.text,
                                'isDone': false
                              };

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                if (widget.isEdit) {
                                  HFFirebaseFunctions()
                                      .getFirebaseAuthUser(context)
                                      .collection('days')
                                      .doc('${selectedEventDate}')
                                      .collection('events')
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
                                          .collection('clients')
                                          .doc(selectedClient)
                                          .collection('days')
                                          .doc('${selectedEventDate}')
                                          .collection('events')
                                          .doc(newId)
                                          .update(eventData)
                                          .then((value) {
                                        FirebaseFirestore.instance
                                            .collection('clients')
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
                                  }).catchError((error) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            getSnackBar(
                                              text: 'There was an error',
                                              color: HFColors().redColor(),
                                            ),
                                          ));
                                } else {
                                  HFFirebaseFunctions()
                                      .getFirebaseAuthUser(context)
                                      .collection('days')
                                      .doc('${selectedEventDate}')
                                      .collection('events')
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
                                          .collection('clients')
                                          .doc(selectedClient)
                                          .collection('days')
                                          .doc('${selectedEventDate}')
                                          .collection('events')
                                          .doc(newId)
                                          .set(eventData)
                                          .then((value) {
                                        initClientDay(
                                            selectedEventDate, selectedClient);
                                        FirebaseFirestore.instance
                                            .collection('clients')
                                            .doc(selectedClient)
                                            .update({
                                          'changed': '$newDate',
                                        });
                                      }).then((value) {
                                        FirebaseFirestore.instance
                                            .collection('clients')
                                            .doc(selectedClient)
                                            .get()
                                            .then((clientRef) {
                                          clientRef.reference
                                              .collection('notifications')
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
                                              'exercises': exerciseList,
                                              'color': selectedColor,
                                              'location': selectedLocationName,
                                              'notes': eventNoteController.text,
                                              'isDone': false,
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
                                  }).catchError((error) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            getSnackBar(
                                              text: 'There was an error',
                                              color: HFColors().redColor(),
                                            ),
                                          ));
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
            // AnimatedPositioned(
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.easeInOut,
            //   bottom: pullUp ? 0 : -MediaQuery.of(context).size.height * 0.8,
            //   left: 0,
            //   right: 0,
            //   child: SizedBox(
            //     height: MediaQuery.of(context).size.height - 100,
            //     child: IgnorePointer(
            //       ignoring: !pullUp,
            //       child: GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             pullUp = false;
            //           });
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            // AnimatedPositioned(
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.easeInOut,
            //   bottom: pullUp ? 0 : -MediaQuery.of(context).size.height * 0.8,
            //   left: 0,
            //   right: 0,
            //   child: IgnorePointer(
            //     ignoring: !pullUp,
            //     child:
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  getTrainingsStream(searchText) {
    return HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection('trainings')
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }

  getClientsStream(searchText) {
    return HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection('clients')
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
        .collection('exercises')
        .where('author', whereIn: coaches)
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }

  closePullUp() {
    exerciseDescription = '';
    exerciseVideo = '';
    exerciseThumbnail = '';
    exerciseSelected = '';
    exerciseIdSelected = '';
    // exerciseTypeNumberController.text = '0';
    // exerciseRepsNumberController.text = '0';
    // exerciseSeriesNumberController.text = '0';
    exerciseRepetitionType = '';
    exerciseTypes = [];
    exerciseNoteController.text = '';
    pullUp = false;
  }
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
      .collection('days')
      .doc('$date')
      .set({'exists': true}).catchError((error) => print(error));
}

void initClientDay(date, id) {
  HFFirebaseFunctions()
      .getClientsUser(id)
      .collection('days')
      .doc('$date')
      .set({'exists': true}).catchError((error) => print(error));
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
            borderRadius: BorderRadius.circular(12),
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
