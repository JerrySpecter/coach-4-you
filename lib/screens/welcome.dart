import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:health_factory/widgets/hf_text_button.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../constants/firebase_functions.dart';
import '../widgets/hf_input_field.dart';
import '../widgets/hf_upload_photo.dart';
import 'events/add_event.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _imageUrl = '';
  bool _startUpload = false;
  double _uploadingPercentage = 0;
  String _imageUrlBackground = '';
  bool _startUploadBackground = false;
  double _uploadingPercentageBackground = 0;
  final cloudinary =
      CloudinaryPublic('jerryspecter', 'hf_upload', cache: false);

  final _trainerBirthdayController = TextEditingController();
  final _trainerFirstNameController = TextEditingController();
  final _trainerLastNameController = TextEditingController();
  final _trainerHeightController = TextEditingController();
  final _trainerWeightController = TextEditingController();
  final _trainerIntroController = TextEditingController();
  final _trainerEducationController = TextEditingController();
  DateTime dateTime = DateTime.now();
  var _selectedLocations = [];

  @override
  Widget build(BuildContext context) {
    _trainerFirstNameController.text =
        context.watch<HFGlobalState>().userFirstName;
    _trainerLastNameController.text =
        context.watch<HFGlobalState>().userLastName;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: HFColors().backgroundColor(),
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HFHeading(
                text: 'Welcome ${context.read<HFGlobalState>().userFirstName}',
                size: 9,
              ),
              const SizedBox(
                height: 10,
              ),
              const HFParagrpah(
                text:
                    'Below you can enter some more information about yourself',
                size: 8,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  HFUploadPhoto(
                    onImageSelect: ((imageUrl) {
                      setState(() {
                        _imageUrl = imageUrl;
                      });
                    }),
                    tooltipText: 'Add a profile picture',
                    startUpload: _startUpload,
                    uploadingPercentage: _uploadingPercentage,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFUploadPhoto(
                    onImageSelect: ((imageUrl) {
                      setState(() {
                        _imageUrlBackground = imageUrl;
                      });
                    }),
                    tooltipText: 'Add a profile background',
                    startUpload: _startUploadBackground,
                    uploadingPercentage: _uploadingPercentageBackground,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFInput(
                    controller: _trainerFirstNameController,
                    labelText: 'First name',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFInput(
                    controller: _trainerLastNameController,
                    labelText: 'Last name',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFInput(
                    controller: _trainerBirthdayController,
                    labelText: 'Birthday',
                    hintText: '01 01 1900',
                    showCursor: false,
                    readOnly: true,
                    onTap: () {
                      return showSheet(
                        context,
                        child: SizedBox(
                          height: 180,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (dateTime) =>
                                setState(() => this.dateTime = dateTime),
                          ),
                        ),
                        onClicked: () {
                          final value =
                              DateFormat('dd. MM. yyyy.').format(dateTime);

                          _trainerBirthdayController.text = value;

                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: HFInput(
                          controller: _trainerHeightController,
                          labelText: 'Height (cm)',
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: HFInput(
                          controller: _trainerWeightController,
                          labelText: 'Weight (kg)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFHeading(
                    text: 'Select your locations:',
                    size: 3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('locations')
                        .snapshots(),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: HFParagrpah(
                            text: 'No locations.',
                            size: 10,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      var data = snapshot.data as QuerySnapshot;

                      if (data.docs.isEmpty) {
                        return const Center(
                          child: HFParagrpah(
                            text: 'No locations.',
                            size: 10,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return MultiSelectChipField(
                        chipColor: HFColors().primaryColor(),
                        selectedChipColor: HFColors().greenColor(),
                        decoration: BoxDecoration(),
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
                          // return your custom widget here

                          return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              _selectedLocations.contains(item.label)
                                  ? _selectedLocations.remove(item.label)
                                  : _selectedLocations.add(item.label);

                              setState(() {
                                _selectedLocations = _selectedLocations;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 10, bottom: 10),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedLocations.contains(item.label)
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
                                  color: _selectedLocations.contains(item.label)
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
                  HFHeading(
                    text: 'Write about yourself:',
                    size: 3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HFInput(
                    maxLines: 7,
                    keyboardType: TextInputType.multiline,
                    controller: _trainerIntroController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  HFHeading(
                    text: 'Write about your education:',
                    size: 3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HFInput(
                    maxLines: 7,
                    keyboardType: TextInputType.multiline,
                    controller: _trainerEducationController,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  HFButton(
                    text: _startUpload ? 'Updating...' : 'Update profile',
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () async {
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
                          ).then((value) {
                            HFFirebaseFunctions()
                                .getFirebaseAuthUser(context)
                                .update({
                              'imageUrl': value.secureUrl,
                            }).then((res) {
                              context
                                  .read<HFGlobalState>()
                                  .setUserImage(value.secureUrl);
                            }).catchError(
                                    (error) => print('Add failed: $error'));
                          });
                        } on CloudinaryException catch (e) {
                          _startUpload = false;
                          print(e.message);
                          print(e.request);
                        }
                      }

                      if (_imageUrlBackground != '') {
                        setState(() {
                          _startUploadBackground = true;
                        });

                        try {
                          await cloudinary.uploadFile(
                            CloudinaryFile.fromFile(
                              _imageUrlBackground,
                              resourceType: CloudinaryResourceType.Image,
                            ),
                            onProgress: (count, total) {
                              setState(() {
                                _uploadingPercentageBackground =
                                    (count / total);
                              });
                            },
                          ).then((value) {
                            HFFirebaseFunctions()
                                .getFirebaseAuthUser(context)
                                .update({
                              'profileBackgroundImageUrl': value.secureUrl,
                            }).then((res) {
                              context
                                  .read<HFGlobalState>()
                                  .setUserBackgroundImage(value.secureUrl);
                            }).catchError(
                                    (error) => print('Add failed: $error'));
                          });
                        } on CloudinaryException catch (e) {
                          _startUploadBackground = false;
                          print(e.message);
                          print(e.request);
                        }
                      }

                      HFFirebaseFunctions()
                          .getFirebaseAuthUser(context)
                          .update({
                        'birthday': '$dateTime',
                        'firstName': _trainerFirstNameController.text,
                        'lastName': _trainerLastNameController.text,
                        'height': _trainerHeightController.text,
                        'weight': _trainerWeightController.text,
                        'intro': _trainerIntroController.text,
                        'education': _trainerEducationController.text,
                        'locations': _selectedLocations,
                      }).then((res) {
                        context
                            .read<HFGlobalState>()
                            .setUserBirthday('$dateTime');
                        context
                            .read<HFGlobalState>()
                            .setUserName(_trainerFirstNameController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserLastName(_trainerLastNameController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserHeight(_trainerHeightController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserWeight(_trainerWeightController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserIntro(_trainerIntroController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserEducation(_trainerEducationController.text);
                        context
                            .read<HFGlobalState>()
                            .setUserLocations(_selectedLocations);
                      }).then((value) {
                        closeWelcomeScreen(context);
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                          text: 'Trainer information updated',
                          color: HFColors().primaryColor(opacity: 1),
                        ));
                      }).catchError((error) => print('Add failed: $error'));
                    },
                  ),
                  HFTextButton(
                    text: 'Update later',
                    onPressed: () {
                      closeWelcomeScreen(context);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

closeWelcomeScreen(BuildContext context) {
  HFFirebaseFunctions().getFirebaseAuthUser(context).update({
    'newAccount': false,
  }).then(
    (value) {
      context.read<HFGlobalState>().setUserNewAccount(false);
      context.read<HFGlobalState>().setRootScreenState(RootScreens.home);
    },
  ).catchError((error) => print('Add failed: $error'));
}
