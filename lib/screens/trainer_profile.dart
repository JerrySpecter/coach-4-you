import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../constants/colors.dart';
import '../../widgets/hf_image.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class TrainerProfile extends StatefulWidget {
  const TrainerProfile({
    Key? key,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    required this.profileBackgroundImageUrl,
    this.locations = const [],
    this.education = '',
    this.intro = '',
    this.birthday = '',
    this.available = true,
  }) : super(key: key);

  final String name;
  final String id;
  final String imageUrl;
  final String email;
  final String profileBackgroundImageUrl;

  final String intro;
  final String education;
  final String birthday;
  final bool available;
  final List<dynamic> locations;

  @override
  State<TrainerProfile> createState() => _TrainerProfileState();
}

class _TrainerProfileState extends State<TrainerProfile> {
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool pullUpOpen = false;
  bool isLoading = false;
  double topOffset = 60;

  String initialname = '';
  String initialemail = '';
  String initialimageUrl = '';
  String initialprofileBackgroundImageUrl = '';
  List initiallocations = [];
  String initialeducation = '';
  String initialintro = '';
  String initialbirthday = '';
  bool initialavailable = false;
  int clients = 0;

  @override
  void initState() {
    initialname = widget.name;
    initialemail = widget.email;
    initialimageUrl = widget.imageUrl;
    initialprofileBackgroundImageUrl = widget.profileBackgroundImageUrl;
    initiallocations = widget.locations;
    initialeducation = widget.education;
    initialintro = widget.intro;
    initialbirthday = widget.birthday;
    initialavailable = widget.available;

    if (widget.name == '') {
      FirebaseFirestore.instance
          .collection('trainers')
          .doc(widget.id)
          .get()
          .then((trainer) {
        setState(() {
          initialname = trainer['name'];
          initialemail = trainer['email'];
          initialimageUrl = trainer['imageUrl'];
          initialprofileBackgroundImageUrl =
              trainer['profileBackgroundImageUrl'];
          initiallocations = trainer['locations'];
          initialeducation = trainer['education'];
          initialintro = trainer['intro'];
          initialbirthday = trainer['birthday'];
          initialavailable = trainer['available'];
        });
      });
    }

    FirebaseFirestore.instance
        .collection('trainers')
        .doc(widget.id)
        .collection('clients')
        .get()
        .then((value) {
      setState(() {
        clients = clients + value.docs.length;
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection('trainers')
          .doc(widget.id)
          .collection('tempClients')
          .get()
          .then((value) {
        setState(() {
          clients = clients + value.docs.length;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: ClipRRect(
                          child: HFImage(
                              imageUrl: initialprofileBackgroundImageUrl),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(0, 255, 255, 255),
                              HFColors().backgroundColor(),
                            ],
                          )),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: (MediaQuery.of(context).size.width / 2) - 75,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27.0),
                              boxShadow: [
                                BoxShadow(
                                  color: HFColors().primaryColor(opacity: 0.2),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                )
                              ],
                              border: Border.all(
                                width: 4,
                                color: HFColors().primaryColor(),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: HFImage(imageUrl: initialimageUrl),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: topOffset,
                        left: 16,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            color: HFColors().primaryColor(),
                            boxShadow: getShadow(),
                          ),
                          child: IconButton(
                            iconSize: 20,
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              CupertinoIcons.chevron_left,
                              color: HFColors().secondaryColor(),
                            ),
                          ),
                        ),
                      ),
                      if (widget.name != '' && widget.available)
                        Positioned(
                          top: topOffset,
                          right: 16,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              color: HFColors().primaryColor(),
                              boxShadow: getShadow(),
                            ),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: ((context) {
                                      return modalBottomSheetContent();
                                    }));
                              },
                              child: Row(
                                children: [
                                  HFParagrpah(
                                    text: 'Request',
                                    size: 8,
                                    fontWeight: FontWeight.bold,
                                    color: HFColors().secondaryColor(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                HFHeading(
                  text: initialname,
                  size: 8,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 4, left: 4, right: 8, bottom: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: initialavailable
                                  ? HFColors().greenColor(opacity: 0.4)
                                  : HFColors().redColor(opacity: 0.4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.circle_filled,
                                  color: initialavailable
                                      ? HFColors().greenColor()
                                      : HFColors().redColor(),
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                HFParagrpah(
                                  size: 8,
                                  color: HFColors().whiteColor(),
                                  text: initialavailable
                                      ? 'Available'
                                      : 'Currently not available',
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const HFParagrpah(
                                text: 'Clients',
                                size: 10,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              HFHeading(
                                text: '${clients}',
                                size: 10,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const HFParagrpah(
                                text: 'Requests',
                                size: 10,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('trainers')
                                    .doc(widget.id)
                                    .collection('requests')
                                    .snapshots(),
                                builder: ((context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const HFHeading(
                                      text: '0',
                                      size: 10,
                                    );
                                  }

                                  var data = snapshot.data as QuerySnapshot;

                                  return HFHeading(
                                    text: '${data.docs.length}',
                                    size: 10,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TrainerInformation(context, initialintro, initiallocations,
                    initialeducation, initialbirthday)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget modalBottomSheetContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: HFColors().secondaryLightColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HFHeading(
                text: 'Send a request to trainer.',
                size: 7,
              ),
              const SizedBox(
                height: 10,
              ),
              HFInput(
                hintText: 'Full name',
                controller: nameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const HFParagrpah(
                text: 'Enter your email address.',
                size: 7,
              ),
              HFInput(
                hintText: 'Email address',
                controller: emailAddressController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email.';
                  }

                  if (!EmailValidator.validate(value)) {
                    return 'Please enter valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const HFParagrpah(
                text: 'Compose a message for your trainer.',
                size: 7,
              ),
              const SizedBox(
                height: 6,
              ),
              TextFormField(
                toolbarOptions: const ToolbarOptions(
                  copy: true,
                  cut: true,
                  paste: true,
                  selectAll: true,
                ),
                minLines: 3,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                controller: contentController,
                style: TextStyle(color: HFColors().whiteColor()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              HFButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                text: isLoading ? 'Loading...' : 'Apply',
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    FirebaseFirestore.instance
                        .collection('trainers')
                        .doc(widget.id)
                        .get()
                        .then((trainerDocRef) {
                      trainerDocRef.reference
                          .collection('requests')
                          .doc(emailAddressController.text)
                          .set({
                        'name': nameController.text,
                        'email': emailAddressController.text,
                        'dateCreated': DateTime.now(),
                        'content': contentController.text,
                      });

                      trainerDocRef.reference
                          .collection('notifications')
                          .doc()
                          .set({
                        'date': '${DateTime.now()}',
                        'read': false,
                        'trainerImage': '',
                        'trainerName': '',
                        'type': 'new-request',
                        'token': trainerDocRef.data()!['notificationToken'],
                        'data': {
                          'name': nameController.text,
                          'email': emailAddressController.text,
                          'dateCreated': DateTime.now(),
                          'content': contentController.text,
                        }
                      });

                      trainerDocRef.reference.update({
                        'unreadNotifications':
                            trainerDocRef.data()!['unreadNotifications'] + 1
                      }).then((value) {
                        setState(() {
                          isLoading = false;
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                          text: 'Request has been sent',
                          color: HFColors().primaryColor(opacity: 1),
                        ));
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'Fill in required fields',
                      color: HFColors().redColor(opacity: 1),
                    ));
                  }
                },
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget ProfileDataListTile(context, text, value) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: HFColors().secondaryLightColor(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: HFHeading(
                          text: text,
                          size: 4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        flex: 3,
                        child: HFHeading(
                          text: value,
                          textAlign: TextAlign.right,
                          size: 4,
                          fontWeight: FontWeight.w700,
                          maxLines: 9,
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
        height: 10,
      ),
    ],
  );
}

Widget TrainerInformation(context, intro, locations, education, birthday) {
  var differenceDays = null;
  if (birthday != '') {
    final date1 = DateTime.parse(birthday);
    final date2 = DateTime.now();
    differenceDays = (date2.difference(date1).inDays / 365).floor();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intro != '')
          const HFHeading(
            text: 'Introduction:',
            size: 5,
          ),
        if (intro != '')
          const SizedBox(
            height: 10,
          ),
        if (intro != '')
          HFParagrpah(
            text: intro,
            lineHeight: 1.4,
            size: 10,
            maxLines: 30,
          ),
        if (intro != '')
          const SizedBox(
            height: 30,
          ),
        const HFHeading(
          text: 'About your trainer:',
          size: 4,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              if (differenceDays != null)
                ProfileDataListTile(context, 'Age:', '$differenceDays'),
              ProfileDataListTile(context, 'Locations:', locations.join(', ')),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        if (education != '')
          const HFHeading(
            text: 'Education:',
            size: 4,
          ),
        if (education != '')
          const SizedBox(
            height: 10,
          ),
        if (education != '')
          HFParagrpah(
            text: education,
            lineHeight: 1.4,
            size: 10,
            maxLines: 30,
          ),
        if (education != '')
          const SizedBox(
            height: 30,
          ),
      ],
    ),
  );
}
