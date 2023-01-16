import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';

class Faqs extends StatefulWidget {
  bool isAdmin;

  Faqs({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<Faqs> createState() => _FaqsState();
}

class _FaqsState extends State<Faqs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      floatingActionButton: widget.isAdmin
          ? Container(
              decoration: BoxDecoration(
                color: HFColors().primaryColor(),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, adminFaqsAddRoute,
                      arguments: {'isAdmin': widget.isAdmin});
                },
                icon: const Icon(CupertinoIcons.add),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const HFHeading(
                size: 10,
                text: 'Frequently asked questions',
              ),
              const SizedBox(
                height: 10,
              ),
              const HFParagrpah(
                text: 'Have questions? We\'re here to help.',
                size: 9,
              ),
              const SizedBox(
                height: 40,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('faqSections')
                    .orderBy("order", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No sections.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  var data = snapshot.data as QuerySnapshot;

                  if (data.docs.isEmpty) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No sections.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...data.docs.map(
                        (section) {
                          return ExpansionTile(
                            childrenPadding: EdgeInsets.all(0),
                            tilePadding: EdgeInsets.all(0),
                            iconColor: HFColors().primaryColor(),
                            collapsedIconColor: HFColors().primaryColor(),
                            title: HFHeading(
                              text: section['name'],
                              size: 7,
                            ),
                            backgroundColor: Colors.transparent,
                            children: [
                              HFParagrpah(
                                size: 8,
                                text: section['description'],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              StreamBuilder(
                                stream:
                                    context.read<HFGlobalState>().userIsAdmin
                                        ? FirebaseFirestore.instance
                                            .collection('faqSections')
                                            .doc(section.id)
                                            .collection('questions')
                                            .snapshots()
                                        : FirebaseFirestore.instance
                                            .collection('faqSections')
                                            .doc(section.id)
                                            .collection('questions')
                                            .where('isDraft', isEqualTo: false)
                                            .snapshots(),
                                builder: ((context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: HFParagrpah(
                                        text: 'No questions.',
                                        size: 10,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  var data = snapshot.data as QuerySnapshot;

                                  if (data.docs.isEmpty) {
                                    return const Center(
                                      child: HFParagrpah(
                                        text: 'No questions.',
                                        size: 10,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      ...data.docs.map(
                                        (question) {
                                          return HFListViewTile(
                                            name: question['isDraft']
                                                ? '(Draft) ${question['name']}'
                                                : question['name'],
                                            simpleImage: true,
                                            useImage: false,
                                            showAvailable: false,
                                            headingMargin: 0,
                                            useSpacerBottom: true,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                adminFaqsSingle,
                                                arguments: {
                                                  'name': question['name'],
                                                  'id': question['id'],
                                                  'videoUrl':
                                                      question['videoUrl'],
                                                  'videoThumbnailUrl': question[
                                                      'videoThumbnailUrl'],
                                                  'sectionId': section.id,
                                                  'description':
                                                      question['description'],
                                                  'isDraft':
                                                      question['isDraft'],
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  );
                                }),
                              )
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
