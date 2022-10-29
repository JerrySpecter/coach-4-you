import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:health_factory/widgets/hf_upload_video.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddVideos extends StatefulWidget {
  AddVideos({
    Key? key,
    required this.parentContext,
    this.name = '',
    this.description = '',
    this.id = '',
    this.url = '',
    this.thumbnail = '',
    this.isEdit = false,
    this.isCoach = false,
  }) : super(key: key);

  BuildContext parentContext;
  String name;
  String description;
  String id;
  String url;
  String thumbnail;
  bool isEdit;
  bool isCoach;

  @override
  State<AddVideos> createState() => _AddVideosState();
}

class _AddVideosState extends State<AddVideos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: widget.isEdit ? 'Edit ${widget.name}' : 'Add new video',
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
              AddVideosForm(
                name: widget.name,
                description: widget.description,
                id: widget.id,
                url: widget.url,
                thumbnail: widget.thumbnail,
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

class AddVideosForm extends StatefulWidget {
  AddVideosForm({
    Key? key,
    required this.parentContext,
    this.name = '',
    this.description = '',
    this.id = '',
    this.url = '',
    this.thumbnail = '',
    this.isEdit = false,
    this.isCoach = false,
  }) : super(key: key);

  BuildContext parentContext;
  String name;
  String description;
  String id;
  String url;
  String thumbnail;
  bool isEdit;
  bool isCoach;

  @override
  State<AddVideosForm> createState() => _AddVideosFormState();
}

class _AddVideosFormState extends State<AddVideosForm> {
  final _videoNameController = TextEditingController();
  final _videoDescriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final cloudinarySdk = Cloudinary.full(
    apiKey: '735651249342712',
    apiSecret: '-bHnS3Hz7ValwMez15sJRBMH2po',
    cloudName: 'jerryspecter',
  );

  File _video = File('');
  String _videoUrl = '';
  bool _startUpload = false;
  double _uploadingPercentage = 0;
  String _initialVideoUrl = '';
  String _initialName = '';
  String _initialDescription = '';
  String _initialThumbnail = '';

  @override
  void initState() {
    _videoNameController.text = widget.name;
    _videoDescriptionController.text = widget.description;
    _videoUrlController.text = widget.url;
    _initialVideoUrl = widget.url;
    _initialName = widget.name;
    _initialDescription = widget.description;
    _initialThumbnail = widget.thumbnail;
    _videoUrl = widget.url;

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
            hintText: 'Video name',
            controller: _videoNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter video name.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          HFUploadVideo(
            thumbnail: widget.thumbnail,
            defaultVideo: _videoUrl,
            onVideoSelect: ((video) {
              setState(() {
                _video = video;
                _videoUrlController.text = _video.path;
              });
            }),
            startUpload: _startUpload,
            uploadingPercentage: _uploadingPercentage,
          ),
          HFInput(
            isHidden: true,
            hintText: 'Video url',
            controller: _videoUrlController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a video.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          HFInput(
            hintText: 'Video description',
            controller: _videoDescriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: 9,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter trainers name.';
              }
              return null;
            },
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
                    ? 'Update video'
                    : 'Add video',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var newId = const Uuid().v4();
                var videoId = widget.isEdit ? widget.id : newId;

                setState(() {
                  _isLoading = true;
                });

                var editedData = {
                  'name': _initialName,
                  'description': _initialDescription,
                  'video': _initialVideoUrl,
                  'thumbnail': _initialThumbnail
                };

                if (_initialVideoUrl != _videoUrlController.text) {
                  setState(() {
                    _startUpload = true;
                  });

                  await cloudinarySdk
                      .uploadResource(
                    CloudinaryUploadResource(
                      filePath: _videoUrlController.text,
                      resourceType: CloudinaryResourceType.video,
                      folder: 'videos/$videoId',
                      optParams: {
                        'transformation': 'c_scale,w_1200',
                      },
                      fileName: '${videoId}_video',
                      progressCallback: (count, total) {
                        setState(() {
                          _uploadingPercentage = (count / total);
                        });
                      },
                    ),
                  )
                      .then((value) {
                    var imageUrl = value.secureUrl as String;
                    var imageFormat = value.format;
                    var imageThumbnailUrl =
                        '${imageUrl.split('.$imageFormat')[0]}.jpg';

                    if (widget.isEdit) {
                      editedData.update('video', (v) => imageUrl);
                      editedData.update('thumbnail', (v) => imageThumbnailUrl);
                    } else {
                      FirebaseFirestore.instance
                          .collection('videos')
                          .doc(newId)
                          .set({
                        'name': _videoNameController.text,
                        'description': _videoDescriptionController.text,
                        'id': newId,
                        'url': imageUrl,
                        'thumbnail': imageThumbnailUrl,
                        'author': widget.isCoach
                            ? context.read<HFGlobalState>().userDisplayName
                            : 'C4Y',
                      }).then((value) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    }
                  });
                }

                if (widget.isEdit) {
                  if (_initialName != _videoNameController.text) {
                    editedData.update(
                        'name', (value) => _videoNameController.text);
                  }
                  if (_initialDescription != _videoDescriptionController.text) {
                    editedData.update('description',
                        (value) => _videoDescriptionController.text);
                  }

                  await FirebaseFirestore.instance
                      .collection('videos')
                      .doc(widget.id)
                      .update(editedData);
                }

                ScaffoldMessenger.of(widget.parentContext)
                    .showSnackBar(getSnackBar(
                  text: 'Video added',
                  color: HFColors().primaryColor(opacity: 1),
                ));

                Navigator.pop(context, editedData);

                setState(() {
                  _startUpload = false;
                  _isLoading = false;
                });
              }
            },
          ),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
