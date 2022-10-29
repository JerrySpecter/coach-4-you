import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/screens/trainer_profile.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../widgets/hf_image.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../utils/tiers_map.dart';

class TrainerProfileLoggedIn extends StatefulWidget {
  const TrainerProfileLoggedIn({
    Key? key,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    required this.profileBackgroundImageUrl,
    this.locations = const [],
    this.height = '',
    this.education = '',
    this.weight = '',
    this.intro = '',
    this.birthday = '',
    this.available = true,
  }) : super(key: key);

  final String name;
  final String id;
  final String imageUrl;
  final String email;
  final String profileBackgroundImageUrl;
  final String height;
  final String weight;
  final String intro;
  final String education;
  final String birthday;
  final bool available;
  final List<dynamic> locations;

  @override
  State<TrainerProfileLoggedIn> createState() => _TrainerProfileLoggedInState();
}

class _TrainerProfileLoggedInState extends State<TrainerProfileLoggedIn> {
  final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool pullUpOpen = false;

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
                            imageUrl: widget.profileBackgroundImageUrl,
                          ),
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
                                  color: HFColors().pinkColor(opacity: 0.2),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                )
                              ],
                              border: Border.all(
                                width: 4,
                                color:
                                    context.watch<HFGlobalState>().userAvailable
                                        ? HFColors().greenColor(opacity: 0.7)
                                        : HFColors().redColor(opacity: 0.7),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: HFImage(imageUrl: widget.imageUrl),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70,
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
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                HFHeading(
                  text: widget.name,
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
                      HFParagrpah(
                        text: 'Show if you are accepting new clients',
                        size: 8,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: HFColors().secondaryLightColor(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: HFHeading(
                                          text: 'Available',
                                          size: 4,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Flexible(
                                        flex: 3,
                                        child: CupertinoSwitch(
                                          value: context
                                              .watch<HFGlobalState>()
                                              .userAvailable,
                                          onChanged: (value) {
                                            context
                                                .read<HFGlobalState>()
                                                .setUserAvailable(value);

                                            HFFirebaseFunctions()
                                                .getFirebaseAuthUser(context)
                                                .update({'available': value});
                                          },
                                          thumbColor: HFColors().primaryColor(),
                                          trackColor:
                                              HFColors().redColor(opacity: 0.4),
                                          activeColor: HFColors()
                                              .greenColor(opacity: 0.4),
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
                      SizedBox(
                        height: 30,
                      ),
                      HFHeading(
                        text: 'Clients overview:',
                        size: 5,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, clientsRoute);
                            },
                            child: Container(
                              height: 120,
                              clipBehavior: Clip.hardEdge,
                              width: MediaQuery.of(context).size.width / 2 - 24,
                              decoration: BoxDecoration(
                                color: HFColors().purpleColor(opacity: 0.1),
                                boxShadow: getShadow(),
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(16)),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned(
                                    top: -20,
                                    left: 60,
                                    child: Transform(
                                      transform: Matrix4.rotationZ(1.2),
                                      child: Container(
                                        color: HFColors()
                                            .purpleColor(opacity: 0.5),
                                        height: 300,
                                        width: ((MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                16) +
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        HFHeading(
                                          text: 'Clients',
                                          color: HFColors().whiteColor(),
                                          size: 4,
                                        ),
                                        StreamBuilder(
                                          stream: HFFirebaseFunctions()
                                              .getFirebaseAuthUser(context)
                                              .collection('clients')
                                              .snapshots(),
                                          builder: ((context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return HFHeading(
                                                color: HFColors().whiteColor(),
                                                text: 'Loading...',
                                                size: 2,
                                              );
                                            }

                                            var data =
                                                snapshot.data as QuerySnapshot;

                                            double size = 75;

                                            return HFHeading(
                                              color: HFColors().whiteColor(),
                                              text: '${data.docs.length}',
                                              size: 8,
                                              lineHeight: 1,
                                              textAlign: TextAlign.center,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, requestsRoute);
                            },
                            child: Container(
                              height: 120,
                              clipBehavior: Clip.hardEdge,
                              width: MediaQuery.of(context).size.width / 2 - 24,
                              decoration: BoxDecoration(
                                color: HFColors().pinkColor(opacity: 0.1),
                                boxShadow: getShadow(),
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(16)),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned(
                                    top: -20,
                                    left: 60,
                                    child: Transform(
                                      transform: Matrix4.rotationZ(1.2),
                                      child: Container(
                                        color:
                                            HFColors().pinkColor(opacity: 0.5),
                                        height: 300,
                                        width: ((MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                16) +
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        HFHeading(
                                          text: 'Requests',
                                          color: HFColors().whiteColor(),
                                          size: 4,
                                        ),
                                        StreamBuilder(
                                          stream: HFFirebaseFunctions()
                                              .getFirebaseAuthUser(context)
                                              .collection('requests')
                                              .snapshots(),
                                          builder: ((context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return HFHeading(
                                                color: HFColors().whiteColor(),
                                                text: 'Loading...',
                                                size: 2,
                                              );
                                            }

                                            var data =
                                                snapshot.data as QuerySnapshot;

                                            double size = 75;

                                            return HFHeading(
                                              color: HFColors().whiteColor(),
                                              text: '${data.docs.length}',
                                              size: 8,
                                              lineHeight: 1,
                                              textAlign: TextAlign.center,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TrainerInformation(context, widget.intro, widget.locations,
                    widget.education, widget.birthday)
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: pullUpOpen ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !pullUpOpen,
                child: InkWell(
                  onTap: () {
                    snappingSheetController.snapToPosition(
                      const SnappingPosition.factor(positionFactor: 0),
                    );

                    setState(() {
                      pullUpOpen = false;
                    });
                  },
                  child: Container(
                    color: HFColors().primaryColor(opacity: 0.6),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SnappingSheet(
                onSnapCompleted: (positionData, snappingPosition) {
                  if (positionData.relativeToSnappingPositions == 0.0) {
                    setState(() {
                      pullUpOpen = false;
                    });
                  }
                },
                lockOverflowDrag: true,
                controller: snappingSheetController,
                snappingPositions: const [
                  SnappingPosition.factor(
                    positionFactor: 0.0,
                    snappingCurve: Curves.easeOutExpo,
                    snappingDuration: Duration(milliseconds: 100),
                    grabbingContentOffset: GrabbingContentOffset.top,
                  ),
                  SnappingPosition.factor(
                    grabbingContentOffset: GrabbingContentOffset.bottom,
                    snappingCurve: Curves.easeInOut,
                    snappingDuration: Duration(milliseconds: 200),
                    positionFactor: 1,
                  ),
                ],
                grabbingHeight: 0,
                sheetAbove: null,
                sheetBelow: SnappingSheetContent(
                  draggable: true,
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: 24, left: 32, right: 32),
                    decoration: BoxDecoration(
                      color: HFColors().whiteColor(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
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
                            hintText: 'Name',
                            controller: nameController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const HFParagrpah(
                            text: 'Enter your email address.',
                            size: 7,
                          ),
                          HFInput(
                            hintText: 'email',
                            controller: emailAddressController,
                            keyboardType: TextInputType.emailAddress,
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
                            minLines: 1,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            controller: contentController,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          HFButton(
                            onPressed: () {
                              HFFirebaseFunctions()
                                  .getFirebaseAuthUser(context)
                                  .collection('requests')
                                  .doc(emailAddressController.text)
                                  .set({
                                'name': nameController.text,
                                'email': emailAddressController.text,
                                'content': contentController.text,
                              }).then((value) {
                                snappingSheetController.snapToPosition(
                                  const SnappingPosition.factor(
                                      positionFactor: 0),
                                );

                                setState(() {
                                  pullUpOpen = false;
                                });
                              });
                            },
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            text: 'Apply',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget clientsBox(BuildContext context, data, loading) {
  return SizedBox(
    width: MediaQuery.of(context).size.width / 2 - 60,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loading)
          HFHeading(
            color: HFColors().whiteColor(),
            text: 'Loading...',
            size: 2,
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HFHeading(
                color: HFColors().whiteColor(),
                text: data == null ? 'No data.' : '${data.docs.length}',
                size: 8,
                lineHeight: 1,
                textAlign: TextAlign.center,
              ),
              if (data != null)
                HFHeading(
                  color: HFColors().whiteColor(opacity: 0.7),
                  text:
                      ' / ${getTier(context.watch<HFGlobalState>().userSubscriptionTier)}',
                  size: 4,
                  lineHeight: 1,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.normal,
                ),
            ],
          ),
        if (data != null)
          LinearProgressIndicator(
            value: data.docs.length /
                getTier(context.watch<HFGlobalState>().userSubscriptionTier),
            minHeight: 5,
            backgroundColor: HFColors().secondaryColor(opacity: 0.3),
            valueColor:
                AlwaysStoppedAnimation<Color>(HFColors().secondaryColor()),
          ),
        const SizedBox(
          height: 5,
        ),
      ],
    ),
  );
}
