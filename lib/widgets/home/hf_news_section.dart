import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/home/hf_news_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import '../../constants/firebase_functions.dart';
import '../../constants/routes.dart';
import '../hf_button.dart';
import '../hf_heading.dart';

class HFNewsSection extends StatelessWidget {
  const HFNewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isClient =
        context.read<HFGlobalState>().userAccessLevel == accessLevels.client;

    print(isClient);

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const HFHeading(
                text: 'News',
                size: 8,
              ),
            ],
          ),
        ),
        Column(
          children: [
            StreamBuilder(
              stream: HFFirebaseFunctions()
                  .getTrainersUser(
                    isClient
                        ? context.read<HFGlobalState>().userTrainerId
                        : context.read<HFGlobalState>().userId,
                  )
                  .collection("news")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: HFParagrpah(
                      text: 'No news.',
                      size: 10,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                var data = snapshot.data as QuerySnapshot;
                if (data.docs.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: HFParagrpah(
                        text: 'There is no news.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 350,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          ...data.docs.map((news) {
                            return HFNewsTile(
                              title: news['title'],
                              excerpt: news['excerpt'],
                              date: news['date'],
                              imageUrl: news['imageUrl'],
                              id: news['id'],
                              useSpacerBottom: true,
                              onTap: () {
                                Navigator.pushNamed(context, singleNewsRoute,
                                    arguments: {
                                      'title': news['title'],
                                      'excerpt': news['excerpt'],
                                      'date': news['date'],
                                      'imageUrl': news['imageUrl'],
                                      'id': news['id'],
                                    });
                              },
                            );
                          })
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                );
              },
            ),
          ],
        )
      ],
    );
  }
}
