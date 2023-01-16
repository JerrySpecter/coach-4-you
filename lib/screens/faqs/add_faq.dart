import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/cupertino.dart';
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

import '../../widgets/hf_paragraph.dart';

class AddFaq extends StatefulWidget {
  AddFaq({
    Key? key,
    required this.parentContext,
    this.name = '',
    this.description = '',
    this.id = '',
    this.videoUrl = '',
    this.videoThumbnailUrl = '',
    this.isEdit = false,
    this.isAdmin = false,
    this.isDraft = true,
    this.sectionId = '',
  }) : super(key: key);

  BuildContext parentContext;
  String name;
  String description;
  String id;
  String videoUrl;
  String videoThumbnailUrl;
  String sectionId;
  bool isEdit;
  bool isAdmin;
  bool isDraft;

  @override
  State<AddFaq> createState() => _AddFaqState();
}

class _AddFaqState extends State<AddFaq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: widget.isEdit ? 'Edit ${widget.name}' : 'Add new question',
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
              AddFaqForm(
                name: widget.name,
                description: widget.description,
                id: widget.id,
                videoUrl: widget.videoUrl,
                videoThumbnailUrl: widget.videoThumbnailUrl,
                parentContext: widget.parentContext,
                isEdit: widget.isEdit,
                isAdmin: widget.isAdmin,
                sectionId: widget.sectionId,
                isDraft: widget.isDraft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddFaqForm extends StatefulWidget {
  AddFaqForm({
    Key? key,
    required this.parentContext,
    this.name = '',
    this.description = '',
    this.id = '',
    this.videoUrl = '',
    this.sectionId = '',
    this.videoThumbnailUrl = '',
    this.isEdit = false,
    this.isAdmin = false,
    this.isDraft = false,
  }) : super(key: key);

  BuildContext parentContext;
  String name;
  String description;
  String id;
  String videoUrl;
  String videoThumbnailUrl;
  String sectionId;
  bool isEdit;
  bool isAdmin;
  bool isDraft;

  @override
  State<AddFaqForm> createState() => _AddFaqFormState();
}

class _AddFaqFormState extends State<AddFaqForm> {
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
  bool _initialIsDraft = false;
  double _uploadingPercentage = 0;
  String _initialVideoUrl = '';
  String _initialName = '';
  String _initialDescription = '';
  String _initialThumbnail = '';
  String _selectedSection = '';

  @override
  void initState() {
    _videoNameController.text = widget.name;
    _videoDescriptionController.text = widget.description;
    _videoUrlController.text = widget.videoUrl;
    _initialVideoUrl = widget.videoUrl;
    _initialName = widget.name;
    _initialDescription = widget.description;
    _initialThumbnail = widget.videoThumbnailUrl;
    _selectedSection = widget.sectionId;
    _initialIsDraft = widget.isDraft;

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
            hintText: 'Question title',
            controller: _videoNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter question title.';
              }
              return null;
            },
          ),
          if (!widget.isEdit)
            const SizedBox(
              height: 20,
            ),
          if (!widget.isEdit)
            const HFHeading(
              size: 5,
              text: 'Select a faq section:',
            ),
          if (!widget.isEdit)
            const SizedBox(
              height: 10,
            ),
          if (!widget.isEdit)
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('faqSections')
                  .orderBy('order', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: HFParagrpah(
                      text: 'No sections.',
                      size: 10,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                var data = snapshot.data as QuerySnapshot;

                if (data.docs.isEmpty) {
                  return const Center(
                    child: HFParagrpah(
                      text: 'No sections.',
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
                      (section) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                _selectedSection = section.id;
                              });
                            },
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: _selectedSection == section.id
                                      ? HFColors().primaryColor()
                                      : HFColors().secondaryLightColor(),
                                ),
                                child: HFParagrpah(
                                  text: section['name'],
                                  size: 8,
                                  color: _selectedSection == section.id
                                      ? HFColors().secondaryColor()
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
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: HFColors().secondaryLightColor(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            flex: 3,
                            child: HFHeading(
                              text: 'Draft?',
                              size: 4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            flex: 1,
                            child: CupertinoSwitch(
                              value: _initialIsDraft,
                              onChanged: ((value) {
                                setState(() {
                                  _initialIsDraft = value;
                                });
                              }),
                              thumbColor: HFColors().primaryColor(),
                              trackColor: HFColors().redColor(opacity: 0.4),
                              activeColor: HFColors().greenColor(opacity: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          HFUploadVideo(
            thumbnail: widget.videoThumbnailUrl,
            defaultVideo: _initialVideoUrl,
            onVideoSelect: ((video) {
              setState(() {
                _video = video;
                _videoUrlController.text = _video.path;
              });
            }),
            startUpload: _startUpload,
            uploadingPercentage: _uploadingPercentage,
          ),
          const SizedBox(
            height: 30,
          ),
          const HFHeading(
            size: 5,
            text: 'Question description:',
          ),
          const SizedBox(
            height: 10,
          ),
          HFInput(
            hintText: 'Question description',
            controller: _videoDescriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: 99,
            minLines: 10,
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
                    ? 'Update question'
                    : 'Add question',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var newId = const Uuid().v4();
                var videoId = widget.isEdit ? widget.id : newId;

                setState(() {
                  _isLoading = true;
                });

                var editedData = {
                  'name': _videoNameController.text,
                  'description': _videoDescriptionController.text,
                  'videoUrl': _initialVideoUrl,
                  'videoThumbnailUrl': _initialThumbnail,
                  'isDraft': _initialIsDraft,
                  'sectionId': _selectedSection,
                };

                print(editedData);

                var imageUrl = '';
                var imageThumbnailUrl = '';

                if (_videoUrlController.text != widget.videoUrl) {
                  if (_videoUrlController.text == '') {
                    imageUrl = '';
                    imageThumbnailUrl = '';
                  } else {
                    setState(() {
                      _startUpload = true;
                    });

                    var uploadValue = await cloudinarySdk.uploadResource(
                      CloudinaryUploadResource(
                        filePath: _videoUrlController.text,
                        resourceType: CloudinaryResourceType.video,
                        folder: 'videos/faqs/$videoId',
                        fileName: '${videoId}_video',
                        progressCallback: (count, total) {
                          setState(() {
                            _uploadingPercentage = (count / total);
                          });
                        },
                      ),
                    );
                    imageUrl = uploadValue.secureUrl as String;
                    var imageFormat = uploadValue.format;
                    imageThumbnailUrl =
                        '${imageUrl.split('.$imageFormat')[0]}.jpg';
                  }
                } else {
                  imageUrl = widget.videoUrl;
                  imageThumbnailUrl = widget.videoThumbnailUrl;
                }

                if (widget.isEdit) {
                  editedData.update('videoUrl', (v) => imageUrl);
                  editedData.update(
                      'videoThumbnailUrl', (v) => imageThumbnailUrl);

                  if (_initialName != _videoNameController.text) {
                    editedData.update(
                        'name', (value) => _videoNameController.text);
                  }

                  if (_initialIsDraft != widget.isDraft) {
                    editedData.update('isDraft', (value) => _initialIsDraft);
                  }

                  if (_initialDescription != _videoDescriptionController.text) {
                    editedData.update('description',
                        (value) => _videoDescriptionController.text);
                  }

                  await FirebaseFirestore.instance
                      .collection('faqSections')
                      .doc(widget.sectionId)
                      .collection('questions')
                      .doc(widget.id)
                      .update(editedData);
                } else {
                  FirebaseFirestore.instance
                      .collection('faqSections')
                      .doc(_selectedSection)
                      .collection('questions')
                      .doc(videoId)
                      .set({
                    'name': _videoNameController.text,
                    'description': _videoDescriptionController.text,
                    'id': videoId,
                    'videoUrl': imageUrl,
                    'videoThumbnailUrl': imageThumbnailUrl,
                    'sectionId': _selectedSection,
                    'isDraft': _initialIsDraft,
                  }).then((value) {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                }

                ScaffoldMessenger.of(widget.parentContext)
                    .showSnackBar(getSnackBar(
                  text: 'Question added',
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
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
