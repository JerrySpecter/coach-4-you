import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/screens/root.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/hf_upload_photo.dart';

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({
    Key? key,
  }) : super(key: key);

  @override
  AddNewsScreenState createState() => AddNewsScreenState();
}

class AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController newsTitleController = TextEditingController();
  final TextEditingController newsExcerptController = TextEditingController();
  String _imageUrl = '';
  bool _startUpload = false;
  double _uploadingPercentage = 0;
  final cloudinary =
      CloudinaryPublic('jerryspecter', 'hf_upload', cache: false);

  String eventName = '';
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: const HFHeading(
          text: 'Add news',
          size: 6,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RootPage(),
                  ),
                );
                newsTitleController.clear();
                newsExcerptController.clear();
              },
              icon: const Icon(CupertinoIcons.multiply))
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HFUploadPhoto(
                    onImageSelect: (imageUrl) {
                      setState(() {
                        _imageUrl = imageUrl;
                      });
                    },
                    startUpload: _startUpload,
                    uploadingPercentage: _uploadingPercentage,
                  ),
                  HFInput(
                    controller: newsTitleController,
                    hintText: 'News title',
                    labelText: 'News title',
                    showCursor: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFInput(
                    controller: newsExcerptController,
                    hintText: 'News content',
                    labelText: 'News content',
                    showCursor: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFButton(
                    text: _startUpload ? 'Adding...' : 'Add news',
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () async {
                      var newId = const Uuid().v4();
                      setState(() {
                        _startUpload = true;
                      });

                      try {
                        await cloudinary.uploadFile(
                          CloudinaryFile.fromFile(
                            _imageUrl,
                            resourceType: CloudinaryResourceType.Image,
                          ),
                          onProgress: (count, total) {
                            setState(() {
                              _uploadingPercentage = (count / total);
                            });
                          },
                        ).then((value) {
                          HFFirebaseFunctions()
                              .getFirebaseAuthUser(context)
                              .collection('news')
                              .doc(newId)
                              .set({
                            'title': newsTitleController.text,
                            'excerpt': newsExcerptController.text,
                            'id': newId,
                            'date': '${DateTime.now()}',
                            'imageUrl': value.secureUrl,
                          }).then(
                            (value) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(
                                text: 'New post published!',
                                color: HFColors().primaryColor(),
                              ));
                            },
                          ).catchError((error) => print('Add failed: $error'));
                        });
                      } on CloudinaryException catch (e) {
                        print(e.message);
                        print(e.request);
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
