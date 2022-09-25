import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';
import 'package:chewie/chewie.dart';

class HFUploadVideo extends StatefulWidget {
  Function(File video)? onVideoSelect;
  bool startUpload;
  bool showControls;
  double uploadingPercentage;
  String tooltipText;
  String thumbnail;
  String defaultVideo;

  HFUploadVideo({
    Key? key,
    this.thumbnail = '',
    this.defaultVideo = '',
    this.onVideoSelect,
    this.startUpload = false,
    this.showControls = true,
    this.uploadingPercentage = 0,
    this.tooltipText = 'Add a video',
  }) : super(key: key);

  @override
  State<HFUploadVideo> createState() => _HFUploadVideoState();
}

class _HFUploadVideoState extends State<HFUploadVideo> {
  late File _videoUrl;
  String thumbnail = '';
  double videoHeight = 240;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(_videoUrl);

    await Future.wait([_videoPlayerController.initialize()]);

    _createChewieController();
    _chewieController?.setVolume(0.0);
    setState(() {});
  }

  Future<void> initializeDefaultPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.defaultVideo);

    await Future.wait([_videoPlayerController.initialize()]);

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
    initializeDefaultPlayer();
    thumbnail = widget.thumbnail;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: videoHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : HFImage(
                    imageUrl: thumbnail,
                  ),
            if (widget.showControls)
              AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                bottom: 10,
                right: 10,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: _chewieController == null ? 0 : 1,
                  child: InkWell(
                    onTap: () => setState(() {
                      _videoUrl = File('');
                      _chewieController = null;
                      thumbnail = '';

                      widget.onVideoSelect!(File(''));
                    }),
                    child: IgnorePointer(
                      ignoring: _chewieController == null,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          color: HFColors().redColor(),
                        ),
                        child: Icon(
                          CupertinoIcons.trash,
                          color: HFColors().whiteColor(),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.showControls)
              AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                bottom: _chewieController == null ? 10 : 50,
                right: 10,
                child: InkWell(
                  onTap: () {
                    ImagePicker().pickVideo(source: ImageSource.gallery).then(
                      (value) {
                        if (value == null) {
                          return;
                        }

                        var _videoFile = File(value.path);

                        setState(
                          () {
                            _videoUrl = _videoFile;

                            widget.onVideoSelect!(_videoFile);

                            initializePlayer();
                          },
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      AnimatedOpacity(
                        opacity: _chewieController == null ? 1 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Transform.translate(
                              offset: Offset(-18, 0),
                              child: Transform.rotate(
                                angle: 0.8,
                                alignment: Alignment.center,
                                child: Container(
                                  width: 24,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                    color: HFColors().primaryColor(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                                color: HFColors().primaryColor(),
                              ),
                              child: HFParagrpah(
                                  text: widget.tooltipText,
                                  size: 7,
                                  color: HFColors().secondaryColor()),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: HFColors().primaryColor(),
                        ),
                        child: Icon(
                          _chewieController == null
                              ? CupertinoIcons.add
                              : CupertinoIcons.pencil,
                          color: HFColors().secondaryColor(),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.showControls)
              AnimatedPositioned(
                bottom: widget.startUpload ? 10 : -30,
                left: 10,
                duration: const Duration(milliseconds: 200),
                width: MediaQuery.of(context).size.width - 32 - 62,
                child: AnimatedOpacity(
                  opacity: widget.startUpload ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: HFColors().secondaryColor(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HFHeading(
                          text: widget.uploadingPercentage == 1.0
                              ? 'Completed!'
                              : 'Uploading...',
                          color: HFColors().whiteColor(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        LinearProgressIndicator(
                          backgroundColor:
                              HFColors().primaryColor(opacity: 0.3),
                          color: HFColors().primaryColor(opacity: 1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              HFColors().primaryColor()),
                          value: widget.uploadingPercentage,
                          minHeight: 3,
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
