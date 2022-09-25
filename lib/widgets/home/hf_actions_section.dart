import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/home/hf_archive_tile.dart';

class ActionsSection extends StatelessWidget {
  const ActionsSection({Key? key}) : super(key: key);

  final double dateOffset = 60;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 30,
        ),
        HFArchiveTile(
          image: 'assets/trainings.svg',
          title: 'Trainings',
          primaryColor: HFColors().blueColor(opacity: 0.1),
          secondaryColor: HFColors().blueColor(opacity: 0.6),
          onTap: () {
            print('tap trainings');
            Navigator.pushNamed(context, trainingsRoute);
          },
        ),
        const SizedBox(
          height: 20,
        ),
        HFArchiveTile(
          image: 'assets/clients.svg',
          title: 'Clients',
          primaryColor: HFColors().pinkColor(opacity: 0.1),
          secondaryColor: HFColors().pinkColor(opacity: 0.6),
          onTap: () {
            Navigator.pushNamed(context, clientsRoute);
          },
        ),
        const SizedBox(
          height: 20,
        ),
        HFArchiveTile(
          image: 'assets/exercises.svg',
          title: 'Exercises',
          primaryColor: HFColors().yellowColor(opacity: 0.1),
          secondaryColor: HFColors().yellowColor(opacity: 0.6),
          onTap: () {
            print('tap exercise');
            Navigator.pushNamed(context, adminExerciseRoute,
                arguments: {'isCoach': true});
          },
        ),
        const SizedBox(
          height: 20,
        ),
        HFArchiveTile(
          image: 'assets/videos.svg',
          title: 'Videos',
          primaryColor: HFColors().purpleColor(opacity: 0.1),
          secondaryColor: HFColors().purpleColor(opacity: 0.6),
          onTap: () {
            print('tap exercise');
            Navigator.pushNamed(context, adminVideosRoute,
                arguments: {'isCoach': true});
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
