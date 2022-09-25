import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/firebase_functions.dart';
import '../../widgets/home/hf_news_tile.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: const HFHeading(
          text: 'News',
          size: 6,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: StreamBuilder(
          stream: HFFirebaseFunctions()
              .getFirebaseAuthUser(context)
              .collection('news')
              .orderBy("date", descending: true)
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
              return const Center(
                child: HFParagrpah(
                  text: 'There is no news.',
                  size: 10,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(children: [
              ...data.docs.map((news) {
                return HFNewsTile(
                  title: news['title'],
                  excerpt: news['excerpt'],
                  date: news['date'],
                  imageUrl: news['imageUrl'],
                  id: news['id'],
                  useSpacerBottom: true,
                  onTap: () {
                    Navigator.pushNamed(context, singleNewsRoute, arguments: {
                      'title': news['title'],
                      'excerpt': news['excerpt'],
                      'date': news['date'],
                      'imageUrl': news['imageUrl'],
                      'id': news['id'],
                    });
                  },
                );
              })
            ]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, addNewsRoute);
        },
        backgroundColor: HFColors().primaryColor(),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}
