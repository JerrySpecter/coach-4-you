import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_dialog.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../constants/colors.dart';
import '../../constants/global_state.dart';
import 'add_exercise.dart';

class SingleExercise extends StatefulWidget {
  SingleExercise({
    Key? key,
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.video,
    required this.thumbnail,
    required this.types,
    required this.repetitionType,
    required this.isFromEvent,
    this.note = '',
  }) : super(key: key);

  final String id;
  final String name;
  final String description;
  final String author;
  final String thumbnail;
  final String video;
  final List<dynamic> types;
  final String repetitionType;
  final String note;
  final bool isFromEvent;

  @override
  State<SingleExercise> createState() => _SingleExerciseState();
}

class _SingleExerciseState extends State<SingleExercise> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isEdited = false;
  String _nameState = '';
  String _thumbnailState = '';
  String _descriptionState = '';
  String _videoState = '';
  List<dynamic> _typesState = [];
  String _repetitionTypeState = '';

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer(videoUrl) async {
    _videoPlayerController = VideoPlayerController.network(videoUrl);

    await Future.wait([_videoPlayerController.initialize()]);

    _createChewieController();
    _chewieController?.setVolume(0.0);
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      hideControlsTimer: const Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    _nameState = widget.name;
    _thumbnailState = widget.thumbnail;
    _descriptionState = widget.description;
    _videoState = widget.video;
    _typesState = widget.types;
    _repetitionTypeState = widget.repetitionType;

    getVideoById(widget.video).get().then((value) {
      initializePlayer(value['url']);
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
        actions: [
          if ((widget.author == context.read<HFGlobalState>().userDisplayName ||
                  context.read<HFGlobalState>().userIsAdmin) &&
              !widget.isFromEvent)
            IconButton(
              onPressed: () {
                // showAlertDialog(
                //   context,
                //   'Are you sure you want to delete video: $_nameState',
                //   () {
                //     FirebaseFirestore.instance
                //         .collection(COLLECTION_EXERCISES)
                //         .doc(widget.id)
                //         .delete()
                //         .then((value) {
                //       Navigator.pop(context);
                //     }).then((value) {
                //       Navigator.pop(context);
                //     });
                //   },
                //   'Yes',
                //   () {
                //     Navigator.pop(context);
                //   },
                //   'No',
                // );
              },
              icon: Icon(
                CupertinoIcons.trash,
                color: HFColors().redColor(),
              ),
            ),
          if ((widget.author == context.read<HFGlobalState>().userDisplayName ||
                  context.read<HFGlobalState>().userIsAdmin) &&
              !widget.isFromEvent)
            IconButton(
              onPressed: () {
                _navigateAndDisplayEditScreen(
                    context,
                    {
                      'name': _nameState,
                      'description': _descriptionState,
                      'video': _videoState,
                      'thumbnail': _thumbnailState,
                      'types': _typesState,
                      'repetitionType': _repetitionTypeState,
                      'id': widget.id,
                      'author': widget.author,
                    },
                    setState);
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
                text: _nameState,
                size: 7,
              ),
              const SizedBox(
                height: 10,
              ),
              HFParagrpah(
                text: widget.author,
                size: 7,
                maxLines: 999,
              ),
              const SizedBox(
                height: 20,
              ),
              if (_typesState.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    ..._typesState.map(
                      (type) => HFTag(
                        text: type,
                        size: 6,
                        color: HFColors().secondaryColor(),
                        backgroundColor: HFColors().primaryColor(),
                      ),
                    )
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
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
              if (widget.note != '')
                const SizedBox(
                  height: 30,
                ),
              if (widget.note != '')
                const HFHeading(
                  text: 'Coach notes:',
                  size: 6,
                ),
              if (widget.note != '')
                const SizedBox(
                  height: 8,
                ),
              if (widget.note != '')
                HFParagrpah(
                  text: widget.note,
                  size: 9,
                  lineHeight: 1.4,
                  maxLines: 999,
                ),
              const SizedBox(
                height: 30,
              ),
              const HFHeading(
                text: 'Exercise description:',
                size: 6,
              ),
              const SizedBox(
                height: 8,
              ),
              HFParagrpah(
                text: _descriptionState,
                size: 9,
                lineHeight: 1.4,
                maxLines: 999,
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  Future<void> _navigateAndDisplayEditScreen(
      BuildContext context, data, setState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddExercise(
                parentContext: context,
                id: data['id'],
                name: data['name'],
                description: data['description'],
                author: data['author'],
                video: data['video'],
                types: data['types'],
                repetitionType: data['repetitionType'],
                isEdit: true,
              )),
    );

    if (!mounted) return;

    setState(() {
      _nameState = result['name'];
      _descriptionState = result['description'];
      _videoState = result['video'];
      _thumbnailState = result['videoThumbnail'];
      _typesState = result['types'];
      _repetitionTypeState = result['repetitionType'];
    });

    if (widget.video != result['video']) {
      getVideoById(result['video']).get().then((value) {
        initializePlayer(value['url']);
      });
    }
  }
}
