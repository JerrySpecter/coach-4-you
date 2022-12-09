import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_tag.dart';
import 'package:provider/provider.dart';

import '../../constants/firebase_functions.dart';
import '../../constants/global_state.dart';
import '../../constants/routes.dart';
import '../../utils/helpers.dart';
import '../hf_client_tile.dart';
import '../hf_input_field.dart';
import '../hf_list_view_tile.dart';
import '../hf_paragraph.dart';

class FindTrainerSection extends StatefulWidget {
  const FindTrainerSection({Key? key}) : super(key: key);

  @override
  State<FindTrainerSection> createState() => _FindTrainerSectionState();
}

class _FindTrainerSectionState extends State<FindTrainerSection> {
  final TextEditingController _searchFieldController = TextEditingController();
  String searchText = '';
  String selectedLocations = '';
  bool showLocationsFilter = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          context
              .read<HFGlobalState>()
              .setSplashScreenState(SplashScreens.splash);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HFHeading(
                  text: 'Find a coach',
                  size: 8,
                ),
                IconButton(
                  onPressed: () {
                    context
                        .read<HFGlobalState>()
                        .setSplashScreenState(SplashScreens.splash);

                    setState(() {
                      searchText = '';
                    });

                    _searchFieldController.clear();
                  },
                  icon: Icon(
                    CupertinoIcons.clear,
                    color: HFColors().primaryColor(),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 6,
                  child: HFInput(
                    controller: _searchFieldController,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    hintText: 'Type in coach\'s name',
                    keyboardType: TextInputType.text,
                    verticalContentPadding: 12,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: HFColors().primaryColor(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: (() {
                        setState(() {
                          showLocationsFilter = !showLocationsFilter;
                          selectedLocations = '';
                        });
                      }),
                      icon: Icon(showLocationsFilter
                          ? CupertinoIcons.multiply
                          : CupertinoIcons.map_pin_ellipse),
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: showLocationsFilter ? 1 : 0,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(),
              curve: Curves.easeInOut,
              height: showLocationsFilter ? 50 : 0,
              child: StreamBuilder<Object>(
                stream: FirebaseFirestore.instance
                    .collection('locations')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: HFParagrpah(
                      text: 'No locations',
                    ));
                  }

                  var data = snapshot.data as QuerySnapshot;

                  if (data.docs.isEmpty) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No Locations.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return OverflowBox(
                    minWidth: MediaQuery.of(context).size.width,
                    maxWidth: MediaQuery.of(context).size.width,
                    minHeight: 40,
                    maxHeight: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        ...data.docs.map(
                          (location) {
                            return Row(
                              children: [
                                Center(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        if (selectedLocations ==
                                            location['name']) {
                                          selectedLocations = '';
                                        } else {
                                          selectedLocations = location['name'];
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: EdgeInsets.only(
                                          right: 10, bottom: 10),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.easeInOut,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedLocations ==
                                                  location['name']
                                              ? HFColors().primaryColor()
                                              : HFColors()
                                                  .secondaryLightColor(),
                                          border: Border.all(
                                            color: HFColors().primaryColor(),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: HFParagrpah(
                                          text: location['name'],
                                          size: 8,
                                          color: selectedLocations ==
                                                  location['name']
                                              ? HFColors().secondaryLightColor()
                                              : HFColors().primaryColor(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          width: 16,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: HFColors().primaryColor(opacity: 0.2),
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 400,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('trainers')
                        .where('firstName', isGreaterThanOrEqualTo: searchText)
                        .where('firstName', isLessThan: '${searchText}z')
                        .orderBy("firstName", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: HFParagrpah(
                            text: 'No trainers. no data',
                            size: 10,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      var data = snapshot.data as QuerySnapshot;

                      if (data.docs.isEmpty) {
                        return const Center(
                          child: HFParagrpah(
                            text: 'No trainers. empty',
                            size: 10,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        children: [
                          ...data.docs.map(
                            (trainer) {
                              List<dynamic> locations = trainer['locations'];

                              if (trainer['newAccount'] ||
                                  trainer['isTestAccount']) {
                                return SizedBox(height: 0);
                              }

                              if (selectedLocations != '' &&
                                  !locations.contains(selectedLocations)) {
                                return SizedBox(height: 0);
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: HFListViewTile(
                                  key: Key(trainer['id']),
                                  name:
                                      "${trainer['firstName']} ${trainer['lastName']}",
                                  email: trainer['email'],
                                  imageUrl: trainer['imageUrl'],
                                  available: trainer['available'],
                                  backgroundColor: HFColors().secondaryColor(),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      trainerProfileRoute,
                                      arguments: trainerProfileData(trainer),
                                    );
                                  },
                                  useSpacerBottom: true,
                                  child: !locations.isEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            HFParagrpah(
                                              text: 'Locations:',
                                              size: 7,
                                              color: HFColors().whiteColor(),
                                              fontWeight: FontWeight.w700,
                                            ),
                                            HFParagrpah(
                                              text: locations.join(', '),
                                              size: 7,
                                              color: HFColors().whiteColor(),
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          width: 0,
                                        ),
                                ),
                              );
                            },
                          )
                        ],
                      );
                    },
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
