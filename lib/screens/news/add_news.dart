import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/screens/root.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
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
  final _formKey = GlobalKey<FormState>();
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFInput(
                      controller: newsExcerptController,
                      keyboardType: TextInputType.multiline,
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
                        if (_formKey.currentState!.validate()) {
                          var newId = const Uuid().v4();

                          if (_imageUrl != '') {
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
                              ).then((cloudinaryResponse) {
                                HFFirebaseFunctions()
                                    .getFirebaseAuthUser(context)
                                    .collection('news')
                                    .doc(newId)
                                    .set({
                                  'title': newsTitleController.text,
                                  'excerpt': newsExcerptController.text,
                                  'author':
                                      context.read<HFGlobalState>().userName,
                                  'likes': [],
                                  'id': newId,
                                  'date': '${DateTime.now()}',
                                  'imageUrl': cloudinaryResponse.secureUrl,
                                }).then(
                                  (v) {
                                    HFFirebaseFunctions()
                                        .getFirebaseAuthUser(context)
                                        .collection('clients')
                                        .get()
                                        .then((clientRef) {
                                      var clientDocs = clientRef.docs;

                                      for (var clientDoc in clientDocs) {
                                        FirebaseFirestore.instance
                                            .collection('clients')
                                            .doc(clientDoc['id'])
                                            .get()
                                            .then((clientProfileDoc) {
                                          clientProfileDoc.reference
                                              .collection('notifications')
                                              .doc()
                                              .set({
                                            'type': 'new-news',
                                            'token': clientProfileDoc[
                                                'notificationToken'],
                                            'trainerName': context
                                                .read<HFGlobalState>()
                                                .userName,
                                            'trainerImage': context
                                                .read<HFGlobalState>()
                                                .userImage,
                                            'date': '${DateTime.now()}',
                                            'read': false,
                                            'data': {
                                              'title': newsTitleController.text,
                                              'excerpt':
                                                  newsExcerptController.text,
                                              'author': context
                                                  .read<HFGlobalState>()
                                                  .userName,
                                              'likes': [],
                                              'id': newId,
                                              'date': '${DateTime.now()}',
                                              'imageUrl':
                                                  cloudinaryResponse.secureUrl,
                                            }
                                          });

                                          clientProfileDoc.reference.update({
                                            'unreadNotifications':
                                                clientProfileDoc[
                                                        'unreadNotifications'] +
                                                    1
                                          });
                                        });
                                      }
                                    });
                                  },
                                ).then(
                                  (value) {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(getSnackBar(
                                      text: 'New post published!',
                                      color: HFColors().primaryColor(),
                                    ));
                                  },
                                ).catchError(
                                        (error) => print('Add failed: $error'));
                              });
                            } on CloudinaryException catch (e) {
                              print(e.message);
                              print(e.request);
                            }
                          } else {
                            HFFirebaseFunctions()
                                .getFirebaseAuthUser(context)
                                .collection('news')
                                .doc(newId)
                                .set({
                              'title': newsTitleController.text,
                              'excerpt': newsExcerptController.text,
                              'author': context.read<HFGlobalState>().userName,
                              'likes': [],
                              'id': newId,
                              'date': '${DateTime.now()}',
                              'imageUrl': _imageUrl,
                            }).then(
                              (value) {
                                HFFirebaseFunctions()
                                    .getFirebaseAuthUser(context)
                                    .collection('clients')
                                    .get()
                                    .then((clientRef) {
                                  var clientDocs = clientRef.docs;

                                  for (var clientDoc in clientDocs) {
                                    FirebaseFirestore.instance
                                        .collection('clients')
                                        .doc(clientDoc['id'])
                                        .get()
                                        .then((clientProfileDoc) {
                                      clientProfileDoc.reference
                                          .collection('notifications')
                                          .doc()
                                          .set({
                                        'type': 'new-news',
                                        'token': clientProfileDoc[
                                            'notificationToken'],
                                        'trainerName': context
                                            .read<HFGlobalState>()
                                            .userName,
                                        'trainerImage': context
                                            .read<HFGlobalState>()
                                            .userImage,
                                        'date': '${DateTime.now()}',
                                        'read': false,
                                        'data': {
                                          'title': newsTitleController.text,
                                          'excerpt': newsExcerptController.text,
                                          'author': context
                                              .read<HFGlobalState>()
                                              .userName,
                                          'likes': [],
                                          'id': newId,
                                          'date': '${DateTime.now()}',
                                          'imageUrl': _imageUrl,
                                        }
                                      });

                                      clientProfileDoc.reference.update({
                                        'unreadNotifications': clientProfileDoc[
                                                'unreadNotifications'] +
                                            1
                                      });
                                    });
                                  }
                                });
                              },
                            ).then((value) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(
                                text: 'New post published!',
                                color: HFColors().primaryColor(),
                              ));
                            }).catchError(
                                    (error) => print('Add failed: $error'));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
