import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../constants/routes.dart';

class ClientVisceralFat extends StatelessWidget {
  ClientVisceralFat({super.key, required this.clientId});

  String clientId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Visceral fat progress:',
          size: 5,
        ),
      ),
      floatingActionButton:
          context.watch<HFGlobalState>().userAccessLevel == accessLevels.client
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: HFColors().primaryColor(),
                  ),
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.add),
                    onPressed: () {
                      Navigator.pushNamed(context, clientAddVisceralFatRoute);
                    },
                  ),
                )
              : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('clients')
                      .doc(clientId)
                      .collection('visceral-fat')
                      .limit(30)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No measurements yet.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No measurements yet.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var dataReversed = data.docs.reversed;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dataReversed.length > 1)
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: LineChart(
                                LineChartData(
                                  lineTouchData: LineTouchData(
                                    getTouchedSpotIndicator:
                                        ((barData, spotIndexes) {
                                      return spotIndexes.map(
                                        (int index) {
                                          final line = FlLine(
                                            color: HFColors()
                                                .whiteColor(opacity: 0.2),
                                            strokeWidth: 1,
                                          );
                                          return TouchedSpotIndicatorData(
                                            line,
                                            FlDotData(show: true),
                                          );
                                        },
                                      ).toList();
                                    }),
                                    handleBuiltInTouches: true,
                                    touchTooltipData: LineTouchTooltipData(
                                      tooltipBgColor: HFColors()
                                          .secondaryColor(opacity: 0.4),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: false,
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        reservedSize: 20,
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return const HFParagrpah(
                                            text: '',
                                            color: Colors.transparent,
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        reservedSize: 35,
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          var val = value.toInt();

                                          if (val >= 0 &&
                                              val < 10 &&
                                              val < data.docs.length) {
                                            return Column(
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                HFParagrpah(
                                                  text:
                                                      DateFormat('d/M').format(
                                                    DateTime.parse(
                                                      dataReversed
                                                              .toList()
                                                              .take(10)
                                                              .toList()[val]
                                                          ['date'],
                                                    ),
                                                  ),
                                                  size: 5,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return const HFParagrpah(
                                              text: 'te',
                                              color: Colors.transparent,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  maxX: data.docs.length.toDouble(),
                                  minX: -1,
                                  lineBarsData: [
                                    LineChartBarData(
                                      isCurved: true,
                                      color: HFColors().pinkColor(),
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: HFColors().pinkColor(),
                                        gradient: LinearGradient(
                                          colors: [
                                            HFColors().pinkColor(opacity: 0.3),
                                            Colors.transparent
                                          ],
                                          transform:
                                              const GradientRotation(1.4),
                                        ),
                                      ),
                                      spots: [
                                        ...dataReversed
                                            .toList()
                                            .take(10)
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          double idx = entry.key.toDouble();
                                          String val = entry.value['value'];

                                          if (val.contains(',')) {
                                            val = val.split(',').join('.');
                                          }

                                          return FlSpot(idx, double.parse(val));
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const HFHeading(
                                text: 'What is visceral fat?',
                                size: 6,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const HFParagrpah(
                                text:
                                    'Visceral body fat, also known as "hidden" fat, is fat stored deep inside the belly, wrapped around the organs, including the liver and intestines. It makes up about one tenth of all the fat stored in the body. Most fat is stored underneath the skin and is known as subcutaneous fat.',
                                maxLines: 99,
                                size: 10,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (data.docs.isNotEmpty)
                                ClientDataListTile(context, 'Current Body fat:',
                                    '${data.docs[0]['value']}%', () {}),
                              const SizedBox(
                                height: 30,
                              ),
                              const HFHeading(text: 'Past Body fat', size: 6),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        HFColors().primaryColor(opacity: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxHeight: 400),
                                        child: ListView.builder(
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: index == 0
                                                  ? const EdgeInsets.only(
                                                      top: 8, left: 8, right: 8)
                                                  : const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: ClientDataListTile(
                                                context,
                                                DateFormat('d/M/y').format(
                                                    DateTime.parse(data.docs
                                                            .toList()[index]
                                                        ['date'])),
                                                '${data.docs.toList()[index]['value']}%',
                                                () {
                                                  showMeasurementActionSheet(
                                                      context,
                                                      '${data.docs.toList()[index]['value']}%',
                                                      data.docs
                                                          .toList()[index]
                                                          .reference);
                                                },
                                              ),
                                            );
                                          },
                                          itemCount: data.docs.length,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}

Widget ClientDataListTile(context, text, value, onTap) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
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
                          flex: 3,
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
                          flex: 1,
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
      ),
      const SizedBox(
        height: 10,
      ),
    ],
  );
}

void showMeasurementActionSheet(
    BuildContext context, title, DocumentReference<Object?> docRef) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: HFParagrpah(
        text: 'Selected:',
        size: 10,
        textAlign: TextAlign.center,
        color: HFColors().secondaryColor(),
      ),
      message: HFHeading(
        text: title,
        size: 4,
        color: HFColors().secondaryColor(),
        textAlign: TextAlign.center,
      ),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            docRef.delete().then((value) {
              Navigator.pop(context);

              ScaffoldMessenger.of(context)
                  .showSnackBar(getSnackBar(text: 'Body fat deleted'));
            });
          },
          child: HFParagrpah(
            text: 'Delete',
            size: 10,
            color: HFColors().redColor(),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        /// This parameter indicates the action would perform
        /// a destructive action such as delete or exit and turns
        /// the action's text color to red.
        onPressed: () {
          Navigator.pop(context);
        },
        child: HFParagrpah(
          text: 'Cancel',
          size: 10,
          color: HFColors().secondaryColor(),
        ),
      ),
    ),
    filter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 1.4),
  );
}
