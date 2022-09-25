import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import '../../constants/global_state.dart';
import '../../widgets/hf_select_list_view_tile.dart';

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
  bool _pullUp = false;
  int _selectedReorderItem = -1;
  bool _exerciseReorderStarted = false;
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _selectedExercises = [];
  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _trainingNoteController = TextEditingController();

  // Pull up state fields
  final TextEditingController _searchFieldController = TextEditingController();
  final TextEditingController _exerciseNoteController = TextEditingController();
  final TextEditingController _exerciseTypeNumberController =
      TextEditingController();
  final TextEditingController _exerciseRepsNumberController =
      TextEditingController();
  final TextEditingController _exerciseSeriesNumberController =
      TextEditingController();
  String _exerciseSearchText = '';
  String _exerciseDescription = '';
  String _exerciseVideo = '';
  String _exerciseThumbnail = '';
  String _exerciseSelected = '';
  String _exerciseIdSelected = '';
  String _exerciseRepetitionType = '';
  List _exerciseTypes = [];
  late Stream _exerciseStream;

  // Initial state
  String _initialName = '';
  String _initialNote = '';
  List<dynamic> _initlExercises = [];

  @override
  void initState() {
    _trainingNameController.text = widget.name;
    _trainingNoteController.text = widget.note;

    _initialName = widget.name;
    _initialNote = widget.note;

    if (widget.isEdit || widget.isDuplicate) {
      _initlExercises = widget.exercises;
      _selectedExercises = widget.exercises;
    }

    _exerciseStream = getStream(true,
        context.read<HFGlobalState>().userDisplayName, _exerciseSearchText);

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
                                    return 'Please enter training name.';
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
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 350,
                                          minHeight: 100,
                                        ),
                                        child: Theme(
                                          data: ThemeData(
                                              canvasColor: Colors.transparent),
                                          child: ListView(
                                            padding: const EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            children: <Widget>[
                                              SizedBox(
                                                key: Key('list-top-margin'),
                                                height: 4,
                                              ),
                                              if (_selectedExercises.isNotEmpty)
                                                for (int index = 0;
                                                    index <
                                                        _selectedExercises
                                                            .length;
                                                    index += 1)
                                                  Padding(
                                                    key: Key('$index'),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child:
                                                        HFTrainingListViewTile(
                                                      onDelete: () {
                                                        setState(() {
                                                          _selectedExercises
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      backgroundColor:
                                                          (_selectedReorderItem !=
                                                                      index &&
                                                                  _exerciseReorderStarted)
                                                              ? HFColors()
                                                                  .whiteColor(
                                                                      opacity:
                                                                          0.3)
                                                              : HFColors()
                                                                  .secondaryLightColor(),
                                                      name:
                                                          '${_selectedExercises[index]['name']}',
                                                      amount: double.parse(
                                                          _selectedExercises[
                                                              index]['amount']),
                                                      repetitions: double.parse(
                                                          _selectedExercises[
                                                                  index]
                                                              ['repetitions']),
                                                      series: double.parse(
                                                          _selectedExercises[
                                                              index]['series']),
                                                      type: _selectedExercises[
                                                              index]
                                                          ['repetitionType'],
                                                      note: _selectedExercises[
                                                          index]['note'],
                                                      useImage: false,
                                                    ),
                                                  ),
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
                                        setState(() {
                                          _pullUp = true;
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
                                text: 'Training notes:',
                                size: 5,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              HFInput(
                                controller: _trainingNoteController,
                                hintText: 'Training notes',
                                maxLines: 8,
                              ),
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
                                                text: 'Training added'));
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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _pullUp ? 0 : -MediaQuery.of(context).size.height * 0.8,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _pullUp = false;
                    });
                  },
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _pullUp ? 0 : -MediaQuery.of(context).size.height * 0.8,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: HFColors().secondaryLightColor(),
                ),
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const HFHeading(
                              text: 'Add exercise',
                              size: 7,
                            ),
                            IconButton(
                              onPressed: (() {
                                setState(() {
                                  closePullUp();
                                });
                              }),
                              icon: Icon(
                                CupertinoIcons.multiply,
                                color: HFColors().primaryColor(),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
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
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 350,
                              minHeight: 100,
                            ),
                            child: StreamBuilder(
                              stream: _exerciseStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: HFParagrpah(
                                      text: 'No videos. no data',
                                      size: 10,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                var data = snapshot.data as QuerySnapshot;

                                if (data.docs.isEmpty) {
                                  return const Center(
                                    child: HFParagrpah(
                                      text: 'No videos. empty',
                                      size: 10,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                return ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ...data.docs.map(
                                      (exercise) {
                                        print(exercise.toString());

                                        return HFSelectListViewTile(
                                          name: exercise['name'],
                                          imageUrl: exercise['videoThumbnail'],
                                          showAvailable: false,
                                          isSelected: _exerciseSelected ==
                                              exercise['name'],
                                          headingMargin: 0,
                                          imageSize: 48,
                                          backgroundColor:
                                              HFColors().secondaryColor(),
                                          id: exercise['id'],
                                          useSpacerBottom: true,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              HFParagrpah(
                                                text:
                                                    'Author: ${exercise['author']}',
                                                size: 5,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              HFParagrpah(
                                                text: exercise['description'],
                                                size: 6,
                                                maxLines: 1,
                                                color: HFColors()
                                                    .whiteColor(opacity: 0.7),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            print(exercise);
                                            setState(() {
                                              _exerciseTypes =
                                                  exercise['types'];
                                              _exerciseDescription =
                                                  exercise['description'];
                                              _exerciseVideo =
                                                  exercise['video'];
                                              _exerciseThumbnail =
                                                  exercise['videoThumbnail'];
                                              _exerciseSelected =
                                                  exercise['name'];
                                              _exerciseIdSelected =
                                                  exercise['id'];
                                              _exerciseRepetitionType =
                                                  exercise['repetitionType'];
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
                          controller: _searchFieldController,
                          onChanged: (value) {
                            setState(() {
                              _exerciseSearchText = value;

                              _exerciseStream = getStream(
                                  widget.isCoach,
                                  context.read<HFGlobalState>().userDisplayName,
                                  _exerciseSearchText);
                              ;
                            });
                          },
                          hintText: 'Filter exercises',
                          keyboardType: TextInputType.text,
                          verticalContentPadding: 12,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (_exerciseSelected.isNotEmpty)
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: HFInput(
                                  keyboardType: TextInputType.number,
                                  labelText: _exerciseRepetitionType == 'weight'
                                      ? 'kg'
                                      : _exerciseRepetitionType == 'time'
                                          ? 'Minutes'
                                          : '',
                                  controller: _exerciseTypeNumberController,
                                ),
                                flex: 1,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: HFInput(
                                  keyboardType: TextInputType.number,
                                  labelText: 'Reps',
                                  controller: _exerciseRepsNumberController,
                                ),
                                flex: 1,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: HFInput(
                                  keyboardType: TextInputType.number,
                                  labelText: 'Series',
                                  controller: _exerciseSeriesNumberController,
                                ),
                                flex: 1,
                              ),
                            ],
                          ),
                        if (_exerciseSelected.isNotEmpty)
                          const SizedBox(
                            height: 20,
                          ),
                        HFInput(
                          controller: _exerciseNoteController,
                          hintText: 'Exercise notes',
                          maxLines: 8,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        HFButton(
                          text: 'Add exercise',
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: () {
                            setState(() {
                              print(_selectedExercises);
                              FocusScope.of(context).requestFocus(FocusNode());

                              var newId = const Uuid().v4();
                              _selectedExercises.add({
                                'id': newId,
                                'name': _exerciseSelected,
                                'exerciseId': _exerciseIdSelected,
                                'description': _exerciseDescription,
                                'video': _exerciseVideo,
                                'videoThumbnail': _exerciseThumbnail,
                                'amount': _exerciseTypeNumberController.text,
                                'repetitions':
                                    _exerciseRepsNumberController.text,
                                'series': _exerciseRepsNumberController.text,
                                'repetitionType': _exerciseRepetitionType,
                                'types': _exerciseTypes,
                                'note': _exerciseNoteController.text
                              });

                              closePullUp();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(text: 'Exercise added'));
                          },
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  closePullUp() {
    _exerciseDescription = '';
    _exerciseVideo = '';
    _exerciseThumbnail = '';
    _exerciseSelected = '';
    _exerciseIdSelected = '';
    _exerciseTypeNumberController.text = '';
    _exerciseRepsNumberController.text = '';
    _exerciseSeriesNumberController.text = '';
    _exerciseRepetitionType = '';
    _exerciseTypes = [];
    _exerciseNoteController.text = '';
    _pullUp = false;
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
