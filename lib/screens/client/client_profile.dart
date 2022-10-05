import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../widgets/hf_image.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../constants/routes.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/home/hf_archive_tile.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({
    Key? key,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    this.profileBackgroundImageUrl = '',
    this.height = '',
    this.weight = '',
    this.asTrainer = false,
  }) : super(key: key);

  final String name;
  final String id;
  final String imageUrl;
  final String email;
  final String profileBackgroundImageUrl;

  final bool asTrainer;
  final String height;
  final String weight;

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  double topOffset = 60;
  String initialName = '';
  String initialId = '';
  String initialImageUrl = '';
  String initialEmail = '';
  String initialProfileBackgroundImageUrl = '';
  String initialHeight = '';

  @override
  void initState() {
    initialName = widget.name;
    initialId = widget.id;
    initialImageUrl = widget.imageUrl;
    initialEmail = widget.email;
    initialProfileBackgroundImageUrl = widget.profileBackgroundImageUrl;
    initialHeight = widget.height;

    if (widget.asTrainer) {
      FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.id)
          .get()
          .then((value) {
        var data = value.data();

        if (data != null) {
          setState(() {
            initialHeight = data['height'];
            initialImageUrl = data['imageUrl'];
            initialProfileBackgroundImageUrl =
                data['profileBackgroundImageUrl'];
          });
        }
      });
    }

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
                              imageUrl: initialProfileBackgroundImageUrl),
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
                      if (widget.asTrainer)
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
                                showAlertDialog(
                                  context,
                                  'Are you sure you want to delete client: $initialName',
                                  () {
                                    HFFirebaseFunctions()
                                        .getFirebaseAuthUser(context)
                                        .collection('clients')
                                        .doc(widget.email)
                                        .delete()
                                        .then((value) {
                                      Navigator.pop(context);
                                    }).then((value) {
                                      Navigator.pop(context);
                                    });
                                  },
                                  'Yes',
                                  () {
                                    Navigator.pop(context);
                                  },
                                  'No',
                                );
                              },
                              child: Icon(
                                CupertinoIcons.trash,
                                color: HFColors().secondaryColor(),
                              ),
                            ),
                          ),
                        ),
                      if (widget.asTrainer)
                        Positioned(
                          top: topOffset + 50,
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
                                Navigator.pushNamed(
                                  context,
                                  addEventRoute,
                                  arguments: {
                                    'id': '',
                                    'date': DateTime.parse(
                                        '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 00:00:00.000Z'),
                                    'title': '',
                                    'startTime': '',
                                    'endTime': '',
                                    'location': '',
                                    'client': {
                                      'name': widget.name,
                                      'id': widget.id,
                                    },
                                    'exercises': [],
                                    'note': '',
                                    'color': '',
                                    'isEdit': false,
                                    'isDuplicate': false,
                                  },
                                );
                              },
                              child: Icon(
                                CupertinoIcons.calendar_badge_plus,
                                color: HFColors().secondaryColor(),
                              ),
                            ),
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
                              child: initialImageUrl == ''
                                  ? const HFImage(imageUrl: '')
                                  : Image.network(
                                      initialImageUrl,
                                      fit: BoxFit.cover,
                                    ),
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                HFHeading(
                  text: initialName,
                  size: 8,
                  textAlign: TextAlign.center,
                ),
                ClientInformation(context, initialHeight),
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.7,
                    disableCenter: true,
                  ),
                  items: [
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('weight')
                          .snapshots(),
                      'Weight',
                      'kg',
                      clientWeightRoute,
                      widget.asTrainer,
                    ),
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('chest')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      'Chest circumference',
                      'cm',
                      clientChestRoute,
                      widget.asTrainer,
                    ),
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('shoulders')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      'Shoulder circ.',
                      'cm',
                      clientShouldersRoute,
                      widget.asTrainer,
                    ),
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('arm')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      'Arm circumference',
                      'cm',
                      clientUpperArmRoute,
                      widget.asTrainer,
                    ),
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('waist')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      'Waist circumference',
                      'cm',
                      clientWaistRoute,
                      widget.asTrainer,
                    ),
                    SliderBox(
                      context,
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.id)
                          .collection('thigh')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      'Thigh circumference',
                      'cm',
                      clientMidThighRoute,
                      widget.asTrainer,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HFArchiveTile(
                    image: 'assets/exercises.svg',
                    hideTitle: true,
                    useChildren: true,
                    primaryColor: HFColors().purpleColor(opacity: 0.1),
                    secondaryColor: HFColors().purpleColor(opacity: 0.6),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        clientCompletedTrainingsRoute,
                        arguments: {
                          'id': widget.id,
                        },
                      );
                    },
                    children: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        HFHeading(
                          text: 'Completed',
                          size: 8,
                          color: HFColors().whiteColor(opacity: 1),
                        ),
                        HFHeading(
                          text: 'workouts',
                          size: 8,
                          color: HFColors().whiteColor(opacity: 1),
                        ),
                      ],
                    ),
                  ),
                ),
                if (context.read<HFGlobalState>().userAccessLevel ==
                    accessLevels.client)
                  const SizedBox(
                    height: 20,
                  ),
                if (context.read<HFGlobalState>().userAccessLevel ==
                    accessLevels.client)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HFArchiveTile(
                      image: 'assets/clients.svg',
                      hideTitle: true,
                      useChildren: true,
                      children: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          HFHeading(
                            text: 'Trainer',
                            size: 8,
                            color: HFColors().whiteColor(opacity: 1),
                          ),
                          HFHeading(
                            text: 'profile',
                            size: 8,
                            color: HFColors().whiteColor(opacity: 1),
                          ),
                        ],
                      ),
                      primaryColor: HFColors().yellowColor(opacity: 0.1),
                      secondaryColor: HFColors().yellowColor(opacity: 0.6),
                      onTap: () {
                        Navigator.pushNamed(context, trainerProfileRoute,
                            arguments: {
                              'id': context.read<HFGlobalState>().userTrainerId,
                              'name': '',
                              'imageUrl': '',
                              'email': '',
                              'locations': [],
                              'birthday': '',
                              'intro': '',
                              'available': false,
                              'education': '',
                              'profileBackgroundImageUrl': '',
                            });
                      },
                    ),
                  ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ],
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

Widget ClientInformation(context, height) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HFHeading(
          text: 'Measurements:',
          size: 6,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              ProfileDataListTile(context, 'Height:', '${height}cm'),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget SliderBox(BuildContext context, data, title, measure, route, isTrainer) {
  return StreamBuilder<Object>(
      stream: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const HFParagrpah(
            text: '',
          );
        }

        var data = snapshot.data as QuerySnapshot;

        return InkWell(
          onTap: (() {
            if (!isTrainer) {
              Navigator.pushNamed(context, route, arguments: {});
            }
          }),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 48, left: 16, right: 16, bottom: 64),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: HFColors().secondaryLightColor(),
                    boxShadow: getShadow()),
                child: SizedBox(
                  height: 150,
                  width: 250,
                  child: Builder(builder: (context) {
                    if (!snapshot.hasData || snapshot.hasError) {
                      return const SizedBox(
                        height: 0,
                      );
                    }

                    var dotData = snapshot.data as QuerySnapshot;

                    return LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: false,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor:
                                HFColors().secondaryColor(opacity: 0.4),
                          ),
                        ),
                        gridData: FlGridData(
                          show: false,
                        ),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          bottomTitles: AxisTitles(),
                          leftTitles: AxisTitles(),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: HFColors().pinkColor(),
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            spots: [
                              ...dotData.docs.reversed
                                  .toList()
                                  .take(10)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                double idx = entry.key.toDouble();
                                var val = entry.value;

                                return FlSpot(idx, double.parse(val['value']));
                              }),
                            ],
                          )
                        ],
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 250),
                    );
                  }),
                ),
              ),
              Positioned(
                top: 10,
                left: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    HFHeading(
                      text: data.docs.isNotEmpty ? data.docs[0]['value'] : '- ',
                      size: 10,
                      lineHeight: 1,
                    ),
                    HFParagrpah(
                      text: measure,
                      size: 10,
                      lineHeight: 3,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 15,
                left: 16,
                child: Row(
                  children: [
                    HFHeading(
                      text: title,
                      size: 6,
                      lineHeight: 1,
                      color: HFColors().whiteColor(opacity: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
