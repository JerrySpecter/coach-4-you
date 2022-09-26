import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../../constants/colors.dart';
import '../../../widgets/hf_image.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../constants/routes.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({
    Key? key,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    required this.profileBackgroundImageUrl,
    this.height = '',
    this.weight = '',
  }) : super(key: key);

  final String name;
  final String id;
  final String imageUrl;
  final String email;
  final String profileBackgroundImageUrl;

  final String height;
  final String weight;

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool pullUpOpen = false;
  bool isLoading = false;
  double topOffset = 60;

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
                              imageUrl: widget.profileBackgroundImageUrl),
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
                              child: HFImage(imageUrl: widget.imageUrl),
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
                  text: widget.name,
                  size: 8,
                  textAlign: TextAlign.center,
                ),
                ClientInformation(context, widget),
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
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('weight')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Weight',
                        'kg',
                        clientWeightRoute),
                    SliderBox(
                        context,
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('chest')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Chest circumference',
                        'cm',
                        clientChestRoute),
                    SliderBox(
                        context,
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('shoulders')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Shoulder circ.',
                        'cm',
                        clientShouldersRoute),
                    SliderBox(
                        context,
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('arm')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Arm circumference',
                        'cm',
                        clientUpperArmRoute),
                    SliderBox(
                        context,
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('waist')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Waist circumference',
                        'cm',
                        clientWaistRoute),
                    SliderBox(
                        context,
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection('thigh')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        'Thigh circumference',
                        'cm',
                        clientMidThighRoute),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: HFHeading(
                //     text: 'Past trainings',
                //     size: 8,
                //   ),
                // ),
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

Widget ClientInformation(context, data) {
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
              ProfileDataListTile(context, 'Height:', '${data.height}cm'),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget SliderBox(BuildContext context, data, title, measure, route) {
  return StreamBuilder<Object>(
      stream: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return HFParagrpah(
            text: '',
          );
        }
        var data = snapshot.data as QuerySnapshot;

        return InkWell(
          onTap: (() {
            print('tap');
            Navigator.pushNamed(context, route, arguments: {});
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
                      return SizedBox(
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
