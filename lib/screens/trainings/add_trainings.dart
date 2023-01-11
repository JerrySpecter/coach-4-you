import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:health_factory/widgets/hf_training_list_view_tile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants/collections.dart';
import '../../constants/global_state.dart';
import '../../widgets/hf_input_number_field.dart';
import '../../widgets/hf_select_list_view_tile.dart';
import '../events/add_event.dart';

class AddTraining extends StatefulWidget {
  AddTraining({
    Key? key,
    required this.parentContext,
    this.name = '',
    this.description = '',
    this.id = '',
    this.note = '',
    this.exercises = const [],
    this.isEdit = false,
    this.isDuplicate = false,
    this.isCoach = true,
  }) : super(key: key);

  BuildContext parentContext;
  String name;
  String description;
  String id;
  String note;
  List<dynamic> exercises;
  bool isEdit;
  bool isDuplicate;
  bool isCoach;

  @override
  State<AddTraining> createState() => _AddTrainingState();
}

class _AddTrainingState extends State<AddTraining> {
  bool _isLoading = false;
  List exerciseTypes = [];
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _selectedExercises = [];
  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _trainingNoteController = TextEditingController();

  // Pull up state fields
  final TextEditingController _exerciseNoteController = TextEditingController();
  final TextEditingController _exerciseTypeNumberController =
      TextEditingController();
  final TextEditingController _exerciseRepsNumberController =
      TextEditingController();
  final TextEditingController _exerciseSeriesNumberController =
      TextEditingController();

  // Initial state
  String _initialName = '';
  String _initialNote = '';

  @override
  void initState() {
    _trainingNameController.text = widget.name;
    _trainingNoteController.text = widget.note;

    _initialName = widget.name;
    _initialNote = widget.note;

    if (widget.isEdit || widget.isDuplicate) {
      _selectedExercises = widget.exercises;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: widget.isEdit ? 'Edit ${_initialName}' : 'Add new training',
        ),
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height - 100),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HFInput(
                                hintText: 'Training name',
                                controller: _trainingNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter set name.';
                                  }
                                  return null;
                                },
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
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        HFColors().primaryColor(opacity: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Column(
                                        children: <Widget>[
                                          const SizedBox(
                                            key: Key('list-top-margin'),
                                            height: 4,
                                          ),
                                          if (_selectedExercises.isNotEmpty)
                                            for (int index = 0;
                                                index <
                                                    _selectedExercises.length;
                                                index += 1)
                                              Builder(builder: (context) {
                                                return Padding(
                                                  key: Key('$index'),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: HFTrainingListViewTile(
                                                    onDelete: () {
                                                      setState(() {
                                                        _selectedExercises
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    onTap: () {
                                                      showExerciseModal(
                                                          true,
                                                          _selectedExercises[
                                                              index]);
                                                    },
                                                    name: _selectedExercises[
                                                        index]['name'],
                                                    amount: _selectedExercises[
                                                                        index][
                                                                    'repetitionType'] ==
                                                                'time' &&
                                                            _selectedExercises[
                                                                index]['v2']
                                                        ? _selectedExercises[
                                                                index]['amount']
                                                            ['durationString']
                                                        : _selectedExercises[
                                                            index]['amount'],
                                                    repetitions:
                                                        _selectedExercises[
                                                                index]
                                                            ['repetitions'],
                                                    series: _selectedExercises[
                                                        index]['series'],
                                                    pauseTime: _selectedExercises[
                                                            index]['v2']
                                                        ? _selectedExercises[
                                                                    index]
                                                                ['pauseTime']
                                                            ['durationString']
                                                        : '',
                                                    type: _selectedExercises[
                                                            index]
                                                        ['repetitionType'],
                                                    note: _selectedExercises[
                                                        index]['note'],
                                                    warmups: _selectedExercises[
                                                            index]['v2']
                                                        ? _selectedExercises[
                                                            index]['warmups']
                                                        : [],
                                                    useImage: false,
                                                    showDelete: true,
                                                  ),
                                                );
                                              }),
                                          if (_selectedExercises.isEmpty)
                                            const SizedBox(
                                              key: Key('empty-margin'),
                                              height: 10,
                                            ),
                                          if (_selectedExercises.isEmpty)
                                            const HFParagrpah(
                                              size: 9,
                                              key: Key('empty-list'),
                                              text: 'No exercises selected',
                                              textAlign: TextAlign.center,
                                            )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    HFButton(
                                      text: 'Add exercise',
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      onPressed: () {
                                        showExerciseModal(false);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(
                              //   height: 30,
                              // ),
                              // const HFHeading(
                              //   text: 'Training notes:',
                              //   size: 5,
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // HFInput(
                              //   controller: _trainingNoteController,
                              //   keyboardType: TextInputType.multiline,
                              //   hintText: 'Training notes',
                              //   minLines: 3,
                              //   maxLines: 9,
                              // ),
                              const SizedBox(
                                height: 40,
                              ),
                              HFButton(
                                text: _isLoading
                                    ? widget.isEdit && !widget.isDuplicate
                                        ? 'Updating...'
                                        : 'Creating...'
                                    : widget.isEdit && !widget.isDuplicate
                                        ? 'Update training'
                                        : 'Create training',
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    var editedData = {
                                      'name': _initialName,
                                      'exercises': _selectedExercises,
                                      'note': _initialNote,
                                    };

                                    if (widget.isEdit) {
                                      if (_initialName !=
                                          _trainingNameController.text) {
                                        editedData.update(
                                            'name',
                                            (value) =>
                                                _trainingNameController.text);
                                      }
                                      if (_initialNote !=
                                          _trainingNoteController.text) {
                                        editedData.update(
                                            'note',
                                            (value) =>
                                                _trainingNoteController.text);
                                      }

                                      editedData.update('exercises',
                                          (value) => _selectedExercises);
                                      HFFirebaseFunctions()
                                          .getFirebaseAuthUser(context)
                                          .collection('trainings')
                                          .doc(widget.id)
                                          .update(editedData)
                                          .then(
                                        (value) {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            getSnackBar(
                                              text: 'Training updated',
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      var newId = const Uuid().v4();

                                      HFFirebaseFunctions()
                                          .getFirebaseAuthUser(context)
                                          .collection('trainings')
                                          .doc(newId)
                                          .set({
                                        'id': newId,
                                        'name': _trainingNameController.text,
                                        'exercises': _selectedExercises,
                                        'note': _trainingNoteController.text
                                      }).then((value) {
                                        setState(() {
                                          _isLoading = false;
                                        });

                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(getSnackBar(
                                                text: 'Training created'));
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        getSnackBar(
                                            text:
                                                'Please fill in required fields',
                                            color: HFColors().redColor()));
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                      SizedBox(
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
                          _selectedExercises.add({
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
