import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_select_list_view_tile.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/hf_image.dart';
import '../../widgets/hf_paragraph.dart';

class AddExercise extends StatefulWidget {
  AddExercise({
    Key? key,
    required this.parentContext,
    this.id = '',
    this.name = '',
    this.description = '',
    this.author = '',
    this.video = '',
    this.thumbnail = '',
    this.types = const [],
    this.repetitionType = '',
    this.isEdit = false,
    this.isCoach = false,
  }) : super(key: key);

  BuildContext parentContext;
  final String id;
  final String name;
  final String description;
  final String author;
  final String video;
  final String thumbnail;
  final List<dynamic> types;
  final String repetitionType;
  bool isEdit;
  bool isCoach;

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: widget.isEdit ? 'Edit ${widget.name}' : 'Add new exercise',
        ),
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 10,
              ),
              AddExerciseForm(
                id: widget.id,
                name: widget.name,
                description: widget.description,
                author: widget.author,
                video: widget.video,
                types: widget.types,
                repetitionType: widget.repetitionType,
                parentContext: widget.parentContext,
                isEdit: widget.isEdit,
                isCoach: widget.isCoach,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddExerciseForm extends StatefulWidget {
  AddExerciseForm({
    Key? key,
    required this.parentContext,
    this.id = '',
    this.name = '',
    this.description = '',
    this.author = '',
    this.video = '',
    this.thumbnail = '',
    this.types = const [],
    this.repetitionType = '',
    this.isEdit = false,
    this.isCoach = false,
  }) : super(key: key);

  BuildContext parentContext;
  String id;
  String name;
  String description;
  String author;
  String video;
  String thumbnail;
  List<dynamic> types;
  String repetitionType;
  bool isEdit;
  bool isCoach;

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final _exerciseNameController = TextEditingController();
  final _exerciseDescriptionController = TextEditingController();
  final _exerciseUrlController = TextEditingController();
  final _exerciseThumbnailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _videoLoading = '';
  var _selectedTypes = [];
  var _selectedRepetition = [];

  String _exerciseUrl = '';
  String _initialVideoId = '';
  String _initialName = '';
  String _initialDescription = '';
  final String _initialThumbnail = '';
  String _initialRepetition = '';
  String _videoSelected = '';

  final TextEditingController _searchFieldController = TextEditingController();
  String searchText = '';
  late Stream stream;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer(videoUrl, videoId) async {
    _videoLoading = videoId;
    _videoPlayerController = VideoPlayerController.network(videoUrl);

    await Future.wait([_videoPlayerController.initialize()]).then((value) {
      setState(() {
        _videoLoading = '';
        _videoSelected = videoId;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _videoLoading = '';
        _videoSelected = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar(
          text: 'There was an error, try again',
          color: HFColors().redColor(),
        ),
      );
    }).catchError((onError) {
      setState(() {
        _videoLoading = '';
        _videoSelected = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar(
          text: 'There was an error, try again',
          color: HFColors().redColor(),
        ),
      );
    });

    _createChewieController();
    _chewieController?.setVolume(0.0);
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
      hideControlsTimer: const Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    if (widget.isEdit) {
      _exerciseNameController.text = widget.name;
      _exerciseDescriptionController.text = widget.description;
      _exerciseUrlController.text = widget.video;
      _exerciseThumbnailController.text = widget.thumbnail;
      _selectedRepetition = [widget.repetitionType];
      _selectedTypes = widget.types;

      _initialName = widget.name;
      _initialDescription = widget.description;
      _initialRepetition = widget.repetitionType;
      _videoSelected = widget.video;
      _initialVideoId = widget.video;

      getVideoById(widget.video).get().then((value) {
        _exerciseUrl = value['url'];
        initializePlayer(value['url'], value['id']);
      });
    }

    stream = getStream(widget.isCoach,
        context.read<HFGlobalState>().userDisplayName, searchText);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HFInput(
            hintText: 'Exercise name',
            controller: _exerciseNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter exercise name.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 20,
          ),
          const HFHeading(
            text: 'Select a video:',
            size: 3,
          ),
          HFInput(
            controller: _searchFieldController,
            onChanged: (value) {
              setState(() {
                searchText = value;
                stream = getStream(widget.isCoach,
                    context.read<HFGlobalState>().userDisplayName, searchText);
              });
            },
            hintText: 'filter videos',
            keyboardType: TextInputType.text,
            verticalContentPadding: 12,
          ),
          Container(
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
                  maxHeight: 350,
                  minHeight: 100,
                ),
                child: StreamBuilder(
                  stream: stream,
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
                        const SizedBox(
                          height: 8,
                        ),
                        ...data.docs.map(
                          (video) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: HFSelectListViewTile(
                                name: video['name'],
                                imageUrl: video['thumbnail'],
                                showAvailable: false,
                                isSelected: _videoSelected == video['id'],
                                isLoading: _videoLoading,
                                headingMargin: 0,
                                imageSize: 48,
                                id: video['id'],
                                useSpacerBottom: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HFParagrpah(
                                      text: 'Author: ${video['author']}',
                                      size: 5,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    HFParagrpah(
                                      text: video['description'],
                                      size: 6,
                                      maxLines: 1,
                                      color:
                                          HFColors().whiteColor(opacity: 0.7),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _exerciseNameController.text =
                                        video['name'];
                                    _exerciseUrlController.text = video['id'];
                                    _exerciseThumbnailController.text =
                                        video['thumbnail'];
                                    _exerciseUrl = video['url'];

                                    _videoLoading = video['id'];
                                    initializePlayer(video['url'], video['id']);
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
          if (_exerciseUrl.isNotEmpty)
            SizedBox(
              height: (MediaQuery.of(context).size.width - 32) / (16 / 9),
              width: MediaQuery.of(context).size.width - 32,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    _chewieController != null &&
                            _chewieController!
                                .videoPlayerController.value.isInitialized
                        ? Chewie(
                            controller: _chewieController!,
                          )
                        : const HFImage()
                  ],
                ),
              ),
            ),
          HFInput(
            isHidden: true,
            readOnly: true,
            controller: _exerciseUrlController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a video.';
              }
              return null;
            },
          ),
          HFInput(
            isHidden: true,
            readOnly: true,
            controller: _exerciseThumbnailController,
          ),
          const SizedBox(
            height: 20,
          ),
          const HFHeading(
            text: 'Select exercise type:',
            size: 3,
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('exerciseType')
                .snapshots(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: HFParagrpah(
                    text: 'No types.',
                    size: 10,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              var data = snapshot.data as QuerySnapshot;

              if (data.docs.isEmpty) {
                return const Center(
                  child: HFParagrpah(
                    text: 'No types.',
                    size: 10,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return MultiSelectChipField(
                chipColor: HFColors().primaryColor(),
                selectedChipColor: HFColors().greenColor(),
                decoration: const BoxDecoration(),
                showHeader: false,
                scroll: false,
                items: [
                  ...data.docs.map(
                    (dynamic location) {
                      return MultiSelectItem(
                          location['name'], location['name']);
                    },
                  ).toList()
                ],
                itemBuilder: (item, state) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      _selectedTypes.contains(item.label)
                          ? _selectedTypes.remove(item.label)
                          : _selectedTypes.add(item.label);

                      setState(() {
                        _selectedTypes = _selectedTypes;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedTypes.contains(item.label)
                              ? HFColors().primaryColor()
                              : HFColors().secondaryColor(),
                          border: Border.all(
                            color: HFColors().primaryColor(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HFParagrpah(
                          text: item.label,
                          size: 8,
                          color: _selectedTypes.contains(item.label)
                              ? HFColors().secondaryColor()
                              : HFColors().primaryColor(),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(
            height: 20,
          ),
          const HFHeading(
            text: 'Select repetition type:',
            size: 3,
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('repetitionTypes')
                .snapshots(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: HFParagrpah(
                    text: 'No types.',
                    size: 10,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              var data = snapshot.data as QuerySnapshot;

              if (data.docs.isEmpty) {
                return const Center(
                  child: HFParagrpah(
                    text: 'No types.',
                    size: 10,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return MultiSelectChipField(
                chipColor: HFColors().primaryColor(),
                selectedChipColor: HFColors().greenColor(),
                decoration: const BoxDecoration(),
                showHeader: false,
                scroll: false,
                items: [
                  ...data.docs.map(
                    (dynamic location) {
                      return MultiSelectItem(
                          location['name'], location['name']);
                    },
                  ).toList()
                ],
                itemBuilder: (item, state) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _selectedRepetition = [item.label];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedRepetition.contains(item.label)
                              ? HFColors().primaryColor()
                              : HFColors().secondaryColor(),
                          border: Border.all(
                            color: HFColors().primaryColor(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HFParagrpah(
                          text: item.label,
                          size: 8,
                          color: _selectedRepetition.contains(item.label)
                              ? HFColors().secondaryColor()
                              : HFColors().primaryColor(),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(
            height: 20,
          ),
          HFInput(
            hintText: 'Exercise description',
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 9,
            controller: _exerciseDescriptionController,
          ),
          const SizedBox(
            height: 40,
          ),
          HFButton(
            text: _isLoading
                ? widget.isEdit
                    ? 'Updating...'
                    : 'Adding...'
                : widget.isEdit
                    ? 'Update exercise'
                    : 'Add exercise',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                var editedData = {
                  'name': _initialName,
                  'description': _initialDescription,
                  'video': _initialVideoId,
                  'videoThumbnail': _initialThumbnail,
                  'repetitionType': _initialRepetition,
                  'types': _selectedTypes,
                };

                if (widget.isEdit) {
                  if (_initialName != _exerciseNameController.text) {
                    editedData.update(
                        'name', (value) => _exerciseNameController.text);
                  }
                  if (_initialDescription !=
                      _exerciseDescriptionController.text) {
                    editedData.update('description',
                        (value) => _exerciseDescriptionController.text);
                  }
                  if (_initialVideoId != _exerciseUrlController.text) {
                    editedData.update(
                        'video', (value) => _exerciseUrlController.text);
                    editedData.update('videoThumbnail',
                        (value) => _exerciseThumbnailController.text);
                  }
                  if (_initialRepetition != _selectedRepetition[0]) {
                    editedData.update(
                        'repetitionType', (value) => _selectedRepetition[0]);
                  }

                  await FirebaseFirestore.instance
                      .collection('exercises')
                      .doc(widget.id)
                      .update(editedData);
                } else {
                  var newId = const Uuid().v4();

                  await FirebaseFirestore.instance
                      .collection('exercises')
                      .doc(newId)
                      .set({
                    'id': newId,
                    'name': _exerciseNameController.text,
                    'description': _exerciseDescriptionController.text,
                    'video': _exerciseUrlController.text,
                    'videoThumbnail': _exerciseThumbnailController.text,
                    'author': widget.isCoach
                        ? context.read<HFGlobalState>().userDisplayName
                        : 'C4Y',
                    'repetitionType': _selectedRepetition.isNotEmpty
                        ? _selectedRepetition[0]
                        : '',
                    'types': _selectedTypes
                  });
                }

                Navigator.pop(context, editedData);

                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}

getStream(isCoach, coachName, searchText) {
  var coaches = ['C4Y'];

  if (isCoach) {
    coaches.add(coachName);
  }

  return FirebaseFirestore.instance
      .collection('videos')
      .where('author', whereIn: coaches)
      .where('name', isGreaterThanOrEqualTo: searchText)
      .where('name', isLessThan: '${searchText}z')
      .orderBy("name", descending: false)
      .snapshots();
}
