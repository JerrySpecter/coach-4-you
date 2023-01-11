import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/home/hf_calendar_section.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';

import '../widgets/home/hf_actions_section.dart';
import '../widgets/home/hf_archive_tile.dart';
import '../widgets/home/hf_news_section.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 45.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.client) {
                        Navigator
                            .pushNamed(context, clientProfileRoute, arguments: {
                          'email': context.read<HFGlobalState>().userEmail,
                          'imageUrl': context.read<HFGlobalState>().userImage,
                          'name': context.read<HFGlobalState>().userName,
                          'id': context.read<HFGlobalState>().userId,
                          'height': context.read<HFGlobalState>().userHeight,
                          'weight': context.read<HFGlobalState>().userWeight,
                          'profileBackgroundImageUrl':
                              context.read<HFGlobalState>().userBackgroundImage,
                          'asTrainer': false,
                        });
                      } else {
                        Navigator.pushNamed(
                            context, trainerProfileLoggedInRoute,
                            arguments: {
                              'email': context.read<HFGlobalState>().userEmail,
                              'imageUrl':
                                  context.read<HFGlobalState>().userImage,
                              'name': context.read<HFGlobalState>().userName,
                              'id': context.read<HFGlobalState>().userId,
                              'locations':
                                  context.read<HFGlobalState>().userLocations,
                              'birthday':
                                  context.read<HFGlobalState>().userBirthday,
                              'intro': context.read<HFGlobalState>().userIntro,
                              'available':
                                  context.read<HFGlobalState>().userAvailable,
                              'education':
                                  context.read<HFGlobalState>().userEducation,
                              'profileBackgroundImageUrl': context
                                  .read<HFGlobalState>()
                                  .userBackgroundImage,
                            });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        boxShadow: getShadow(),
                        border: Border.all(
                          width: 2,
                          color: HFColors().primaryColor(),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        clipBehavior: Clip.hardEdge,
                        child: context.watch<HFGlobalState>().userImage != ''
                            ? Image.network(
                                context.watch<HFGlobalState>().userImage,
                                fit: BoxFit.cover,
                              )
                            : const HFImage(
                                imageUrl: '',
                                network: false,
                              ),
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: HFFirebaseFunctions()
                        .getFirebaseAuthUser(context)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return NotificationBell(context);
                      }

                      var data = snapshot.data as DocumentSnapshot;

                      if (!data.exists) {
                        return NotificationBell(context);
                      }

                      var unreadNotifications = data.get('unreadNotifications');

                      return Stack(
                        children: [
                          NotificationBell(context),
                          AnimatedPositioned(
                            top: unreadNotifications > 0 ? 0 : 5,
                            right: 0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedOpacity(
                              opacity: unreadNotifications > 0 ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HFColors().redColor()),
                                child: Center(
                                  child: HFParagrpah(
                                    text: '$unreadNotifications',
                                    size: 6,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HFHeading(
                        text: 'Hello, ',
                        size: 10,
                        color: HFColors().whiteColor(opacity: 0.7),
                      ),
                      HFHeading(
                        text:
                            context.watch<HFGlobalState>().userFirstName + '!',
                        size: 10,
                        color: HFColors().whiteColor(opacity: 1),
                      ),
                    ],
                  ),
                  HFParagrpah(
                    text: 'How are you doing today?',
                    size: 8,
                    color: HFColors().whiteColor(opacity: 1),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: HFCalendarSection(),
            ),
            const HFNewsSection(),
            if (context.watch<HFGlobalState>().userAccessLevel ==
                accessLevels.trainer)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ActionsSection(),
              ),
            if (context.read<HFGlobalState>().userAccessLevel ==
                accessLevels.client)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HFArchiveTile(
                  image: 'assets/trainings.svg',
                  hideTitle: true,
                  useChildren: true,
                  primaryColor: HFColors().pinkColor(opacity: 0.1),
                  secondaryColor: HFColors().pinkColor(opacity: 0.6),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      clientUpcomingTrainingsRoute,
                      arguments: {
                        'id': context.read<HFGlobalState>().userId,
                      },
                    );
                  },
                  children: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HFHeading(
                        text: 'Upcoming',
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
            const SizedBox(
              height: 20,
            ),
            if (context.read<HFGlobalState>().userAccessLevel ==
                accessLevels.client)
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
                        'id': context.read<HFGlobalState>().userId,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HFArchiveTile(
                image: 'assets/meal-plan.png',
                isSvg: false,
                hideTitle: true,
                useChildren: true,
                primaryColor: HFColors().yellowColor(opacity: 0.1),
                secondaryColor: HFColors().yellowColor(opacity: 0.6),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    clientMealPlan,
                    arguments: {
                      'id': context.read<HFGlobalState>().userId,
                    },
                  );
                },
                children: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    HFHeading(
                      text: 'Meal plan',
                      size: 8,
                      color: HFColors().whiteColor(opacity: 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}

Widget NotificationBell(context) {
  return IconButton(
    onPressed: () {
      Navigator.pushNamed(context, notifications);
    },
    icon: Icon(
      CupertinoIcons.bell,
      color: HFColors().primaryColor(),
    ),
  );
}
