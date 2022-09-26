import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 80,
              ),
              const HFHeading(
                text: 'Settings',
                size: 10,
              ),
              const SizedBox(
                height: 40,
              ),
              if (context.watch<HFGlobalState>().userIsAdmin)
                SettingsListTile(
                    context, CupertinoIcons.person_2_square_stack, 'Admin', () {
                  Navigator.pushNamed(context, adminRoute);
                }),
              SettingsListTile(context, CupertinoIcons.person, 'Profile', () {
                if (context.read<HFGlobalState>().userAccessLevel ==
                    accessLevels.client) {
                  Navigator.pushNamed(context, clientProfileRoute, arguments: {
                    'email': context.read<HFGlobalState>().userEmail,
                    'imageUrl': context.read<HFGlobalState>().userImage,
                    'name': context.read<HFGlobalState>().userName,
                    'id': context.read<HFGlobalState>().userId,
                    'height': context.read<HFGlobalState>().userHeight,
                    'weight': context.read<HFGlobalState>().userWeight,
                    'profileBackgroundImageUrl':
                        context.read<HFGlobalState>().userBackgroundImage,
                    'asTrainer': false
                  });
                } else {
                  Navigator.pushNamed(context, trainerProfileLoggedInRoute,
                      arguments: {
                        'email': context.read<HFGlobalState>().userEmail,
                        'imageUrl': context.read<HFGlobalState>().userImage,
                        'name': context.read<HFGlobalState>().userName,
                        'id': context.read<HFGlobalState>().userId,
                        'locations':
                            context.read<HFGlobalState>().userLocations,
                        'birthday': context.read<HFGlobalState>().userBirthday,
                        'intro': context.read<HFGlobalState>().userIntro,
                        'available':
                            context.read<HFGlobalState>().userAvailable,
                        'education':
                            context.read<HFGlobalState>().userEducation,
                        'profileBackgroundImageUrl':
                            context.read<HFGlobalState>().userBackgroundImage,
                      });
                }
              }),
              const SizedBox(
                height: 80,
              ),
              HFButton(
                text: 'Log out',
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: HFColors().redColor(),
                textColor: HFColors().whiteColor(),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  context.read<HFGlobalState>().setUserName('');
                  context.read<HFGlobalState>().setUserFirstName('');
                  context.read<HFGlobalState>().setUserLastName('');
                  context.read<HFGlobalState>().setUserImage('');
                  context.read<HFGlobalState>().setUserBackgroundImage('');
                  context.read<HFGlobalState>().setUserIsAdmin(false);
                },
              ),
              const SizedBox(
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget SettingsListTile(context, icon, text, onTap) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: HFColors().secondaryLightColor(),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: HFColors().primaryColor(opacity: 1),
                  ),
                  child: Icon(
                    icon,
                    color: HFColors().whiteColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HFHeading(
                          text: text,
                          size: 4,
                          fontWeight: FontWeight.w400,
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: HFColors().primaryColor(),
                          size: 20,
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
