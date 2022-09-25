import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/utils/helpers.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';

class Exercise extends StatefulWidget {
  bool isCoach;

  Exercise({Key? key, this.isCoach = false}) : super(key: key);

  @override
  State<Exercise> createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Exercises',
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: HFColors().primaryColor(),
          borderRadius: BorderRadius.circular(24),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, adminExerciseAddRoute,
                arguments: {'isCoach': widget.isCoach});
          },
          icon: const Icon(CupertinoIcons.add),
        ),
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 0.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('exercises')
                      .where('author',
                          whereIn: getCoaches(context, widget.isCoach))
                      .orderBy("name", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No exercises.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No exercises.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...data.docs.map(
                          (exercise) {
                            return HFListViewTile(
                              name: exercise['name'],
                              showAvailable: false,
                              imageUrl: exercise['videoThumbnail'],
                              headingMargin: 0,
                              id: exercise['id'],
                              tags: exercise['types'],
                              useSpacerBottom: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HFParagrpah(
                                    text: 'Author: ${exercise['author']}',
                                    size: 7,
                                  )
                                ],
                              ),
                              onTap: () {
                                print('Open exercise');
                                Navigator.pushNamed(
                                  context,
                                  adminExerciseSingle,
                                  arguments: exerciseData(exercise),
                                );
                              },
                            );
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
