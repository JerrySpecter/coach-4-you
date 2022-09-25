import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/home/hf_actions_section.dart';
import 'package:health_factory/widgets/home/hf_archive_tile.dart';
import 'package:health_factory/widgets/home/hf_archive_tile_small.dart';
import 'package:provider/provider.dart';

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HFHeading(
                          text: context.watch<HFGlobalState>().userDisplayName,
                          size: 10,
                          color: HFColors().whiteColor(opacity: 1),
                        ),
                      ],
                    ),
                    HFParagrpah(
                      text: 'Welcome to your administration',
                      size: 8,
                      color: HFColors().whiteColor(opacity: 1),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    HFArchiveTileSmall(
                      icon: CupertinoIcons.person_3_fill,
                      title: 'Trainers',
                      primaryColor: HFColors().primaryColor(opacity: 0.1),
                      secondaryColor: HFColors().primaryColor(opacity: 0.6),
                      onTap: () {
                        Navigator.pushNamed(context, adminTrainersRoute);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFArchiveTileSmall(
                      icon: CupertinoIcons.location,
                      title: 'Gym locations',
                      primaryColor: HFColors().primaryColor(opacity: 0.1),
                      secondaryColor: HFColors().primaryColor(opacity: 0.6),
                      onTap: () {
                        Navigator.pushNamed(context, adminLocationsRoute);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFArchiveTileSmall(
                      icon: CupertinoIcons.video_camera,
                      title: 'Videos',
                      primaryColor: HFColors().primaryColor(opacity: 0.1),
                      secondaryColor: HFColors().primaryColor(opacity: 0.6),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          adminVideosRoute,
                          arguments: {
                            'isCoach': false,
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFArchiveTileSmall(
                      icon: CupertinoIcons.circle_grid_hex_fill,
                      title: 'Excercises',
                      primaryColor: HFColors().primaryColor(opacity: 0.1),
                      secondaryColor: HFColors().primaryColor(opacity: 0.6),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          adminExerciseRoute,
                          arguments: {
                            'isCoach': false,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
