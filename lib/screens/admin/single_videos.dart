import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/screens/admin/add_videos.dart';
import 'package:health_factory/widgets/hf_dialog.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../constants/colors.dart';

class SingleVideos extends StatefulWidget {
  const SingleVideos({
    Key? key,
    required this.name,
    required this.id,
    required this.url,
    required this.thumbnail,
    required this.description,
    required this.author,
  }) : super(key: key);

  final String name;
  final String id;
  final String url;
  final String thumbnail;
  final String description;
  final String author;

  @override
  State<SingleVideos> createState() => _SingleVideosState();
}

class _SingleVideosState extends State<SingleVideos> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  String _nameState = '';
  String _descriptionState = '';
  String _videoState = '';
  String _thumbnailState = '';

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer(url) async {
    _videoPlayerController = VideoPlayerController.network(url);

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
    _descriptionState = widget.description;
    _videoState = widget.url;
    _thumbnailState = widget.thumbnail;

    initializePlayer(widget.url);

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
          if (widget.author == context.read<HFGlobalState>().userDisplayName ||
              context.read<HFGlobalState>().userIsAdmin)
            IconButton(
              onPressed: () {
                showAlertDialog(
                  context,
                  'Are you sure you want to delete video: ${_nameState}',
                  () {
                    FirebaseFirestore.instance
                        .collection('videos')
                        .doc(widget.id)
                        .delete()
                        .then((value) {
                      Navigator.pop(context);
                    }).then((value) {
                      Navigator.pop(context);
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
          if (widget.author == context.read<HFGlobalState>().userDisplayName ||
              context.read<HFGlobalState>().userIsAdmin)
            IconButton(
              onPressed: () {
                _navigateAndDisplayEditScreen(
                  context,
                  {
                    'parentContext': context,
                    'name': _nameState,
                    'thumbnail': _thumbnailState,
                    'url': _videoState,
                    'description': _descriptionState,
                    'id': widget.id,
                    'isEdit': true
                  },
                  setState,
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
                          : HFImage(
                              imageUrl: _thumbnailState,
                            )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              HFParagrpah(
                text: _descriptionState,
                size: 9,
                lineHeight: 1.4,
                maxLines: 999,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateAndDisplayEditScreen(
      BuildContext context, data, setState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVideos(
          parentContext: context,
          id: data['id'],
          name: data['name'],
          description: data['description'],
          thumbnail: data['thumbnail'],
          url: data['url'],
          isEdit: true,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _nameState = result['name'];
      _descriptionState = result['description'];
      _videoState = result['video'];
      _thumbnailState = result['thumbnail'];
    });

    if (widget.url != result['video']) {
      initializePlayer(result['video']);
    }
  }
}
