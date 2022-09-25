import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import 'hf_heading.dart';

class HFUploadPhoto extends StatefulWidget {
  Function(String imageUrl)? onImageSelect;
  bool startUpload;
  double uploadingPercentage;
  String tooltipText;

  HFUploadPhoto({
    Key? key,
    this.onImageSelect,
    this.startUpload = false,
    this.uploadingPercentage = 0,
    this.tooltipText = 'Add a photo',
  }) : super(key: key);

  @override
  State<HFUploadPhoto> createState() => _HFUploadPhotoState();
}

class _HFUploadPhotoState extends State<HFUploadPhoto> {
  String _imageUrl = '';
  double imageHeight = 240;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            HFImage(
              imageUrl: _imageUrl,
              network: false,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: 10,
              right: 10,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _imageUrl == '' ? 0 : 1,
                child: InkWell(
                  onTap: () => setState(() {
                    _imageUrl = '';

                    widget.onImageSelect!('');
                  }),
                  child: IgnorePointer(
                    ignoring: _imageUrl == '',
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: _imageUrl == '' ? 10 : 50,
              right: 10,
              child: InkWell(
                onTap: () {
                  ImagePicker().pickImage(source: ImageSource.gallery).then(
                    (value) {
                      if (value == null) {
                        return;
                      }
                      setState(
                        () {
                          _imageUrl = value!.path;

                          widget.onImageSelect!(value.path);
                        },
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    AnimatedOpacity(
                      opacity: _imageUrl == '' ? 1 : 0,
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
                        _imageUrl == ''
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
                        backgroundColor: HFColors().primaryColor(opacity: 0.3),
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
