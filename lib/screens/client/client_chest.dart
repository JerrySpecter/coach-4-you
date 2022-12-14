import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../constants/global_state.dart';
import '../../constants/routes.dart';
import 'client_weight.dart';

class ClientChest extends StatelessWidget {
  ClientChest({super.key, required this.clientId});

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
          text: 'Chest size progress:',
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
                      Navigator.pushNamed(context, clientAddChestRoute);
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
                      .collection('chest')
                      .limit(30)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No measurements.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No measurements.',
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
                              if (data.docs.isNotEmpty)
                                ClientDataListTile(
                                    context,
                                    'Current chest circumference:',
                                    '${data.docs[0]['value']}cm',
                                    () {}),
                              const SizedBox(
                                height: 30,
                              ),
                              const HFHeading(
                                  text: 'Past measurements', size: 6),
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
                                                  '${data.docs.toList()[index]['value']}cm',
                                                  () {
                                                showMeasurementActionSheet(
                                                    context,
                                                    '${data.docs.toList()[index]['value']}cm',
                                                    data.docs
                                                        .toList()[index]
                                                        .reference);
                                              }),
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
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
