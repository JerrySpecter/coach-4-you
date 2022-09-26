import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_image.dart';
import 'package:health_factory/widgets/home/hf_calendar_section.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';

import '../widgets/home/hf_actions_section.dart';
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
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: getShadow(),
                        border: Border.all(
                          width: 2,
                          color: HFColors().primaryColor(),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        clipBehavior: Clip.hardEdge,
                        child: HFImage(
                          imageUrl: context.watch<HFGlobalState>().userImage,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.bell,
                        color: HFColors().primaryColor(),
                      ))
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
            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}
