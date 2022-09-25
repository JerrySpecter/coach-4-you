import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/screens/events/calendar.dart';
import 'package:health_factory/screens/home.dart';
import 'package:health_factory/screens/settings.dart';
import 'package:health_factory/screens/splash.dart';
import 'package:health_factory/screens/welcome.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/global_state.dart';
import '../utils/event.dart';
import 'chat.dart';

const double iconSize = 32;
const double barHeight = 60;

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  bool floatingButtonShowNews = false;
  bool floatingButtonShowEvent = false;
  bool floatingButtonShowExercise = false;

  hideFloatingButtonOptions() {
    setState(() {
      floatingButtonShowEvent = false;
      floatingButtonShowNews = false;
      floatingButtonShowExercise = false;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        print('user signed in');
        context.read<HFGlobalState>().setUserLoggedIn(true);

        user.getIdTokenResult(true).then((result) {
          var accessLevel = result.claims?['accessLevel'];

          context.read<HFGlobalState>().setUserAccessLevel(accessLevel);

          if (context.read<HFGlobalState>().userAccessLevel ==
              accessLevels.client) {
            HFFirebaseFunctions().initClientData(user.uid, context);
          }

          if (context.read<HFGlobalState>().userAccessLevel ==
              accessLevels.trainer) {
            HFFirebaseFunctions().initTrainerData(user.uid, context);
          }
        });
      } else {
        print('user not signed in');
        context.read<HFGlobalState>().setUserLoggedIn(false);
        context.read<HFGlobalState>().setRootScreenState(RootScreens.login);
        context
            .read<HFGlobalState>()
            .setSplashScreenState(SplashScreens.splash);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onHorizontalDragEnd: (details) {
        const sensitivity = 400;

        if (context.read<HFGlobalState>().rootScreenState ==
                RootScreens.login ||
            context.read<HFGlobalState>().rootScreenState ==
                RootScreens.welcome) {
          return;
        }

        if (details.primaryVelocity! < sensitivity) {
          print('swipe right');
          if (context.read<HFGlobalState>().rootScreenState !=
              RootScreens.settings) {
            switch (context.read<HFGlobalState>().rootScreenState) {
              case RootScreens.home:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.calendar);
                break;
              case RootScreens.calendar:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.chat);
                break;
              case RootScreens.chat:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.settings);
                break;
              default:
            }
          }
        }

        if (details.primaryVelocity! > -sensitivity) {
          print('swipe left');
          if (context.read<HFGlobalState>().rootScreenState !=
              RootScreens.home) {
            switch (context.read<HFGlobalState>().rootScreenState) {
              case RootScreens.settings:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.chat);
                break;
              case RootScreens.chat:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.calendar);
                break;
              case RootScreens.calendar:
                context
                    .read<HFGlobalState>()
                    .setRootScreenState(RootScreens.home);
                break;
              default:
            }
          }
        }
      },
      child: Container(
        color: HFColors().backgroundColor(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: HFColors().backgroundColor(),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Login screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  left: 0,
                  top: context.watch<HFGlobalState>().splashScreenState ==
                          SplashScreens.loggedIn
                      ? -20
                      : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.login
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.loggedIn,
                      child: const SplashScreen(),
                    ),
                  ),
                ),
                // Welcome screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  left: 0,
                  top: context.watch<HFGlobalState>().rootScreenState !=
                          RootScreens.welcome
                      ? -20
                      : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.welcome
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.welcome,
                      child: const WelcomePage(),
                    ),
                  ),
                ),
                // Home screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: 0,
                  left: context.watch<HFGlobalState>().rootScreenState !=
                          RootScreens.home
                      ? -20
                      : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.home
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.home,
                      child: const Home(),
                    ),
                  ),
                ),
                // Calendar screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: 0,
                  left: context.watch<HFGlobalState>().rootScreenState ==
                          RootScreens.home
                      ? 20
                      : context.watch<HFGlobalState>().rootScreenState ==
                              RootScreens.chat
                          ? -20
                          : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.calendar
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.calendar,
                      child: const CalendarPage(),
                    ),
                  ),
                ),
                // Chat screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: 0,
                  left: context.watch<HFGlobalState>().rootScreenState ==
                          RootScreens.calendar
                      ? 20
                      : context.watch<HFGlobalState>().rootScreenState ==
                              RootScreens.settings
                          ? -20
                          : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.chat
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.chat,
                      child: const Chat(),
                    ),
                  ),
                ),
                // Settings screen
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: 0,
                  left: context.watch<HFGlobalState>().rootScreenState !=
                          RootScreens.settings
                      ? 20
                      : 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: context.watch<HFGlobalState>().rootScreenState ==
                            RootScreens.settings
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring:
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.settings,
                      child: const SettingsPage(),
                    ),
                  ),
                ),
                // Floating event button
                AnimatedPositioned(
                  curve: floatingButtonShowEvent
                      ? Curves.easeOutBack
                      : Curves.easeInOut,
                  bottom: floatingButtonShowEvent ? 180 : 120,
                  right: floatingButtonShowEvent ? 20 : 30,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    curve: floatingButtonShowEvent
                        ? Curves.easeOutBack
                        : Curves.easeInOut,
                    opacity: floatingButtonShowEvent ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedScale(
                      curve: floatingButtonShowEvent
                          ? Curves.easeOutBack
                          : Curves.easeInOut,
                      scale: floatingButtonShowEvent ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !floatingButtonShowEvent,
                        child: HFButton(
                          useIcon: true,
                          icon: Icon(
                            CupertinoIcons.calendar_badge_plus,
                            size: 20,
                            color: HFColors().secondaryColor(),
                          ),
                          padding: const EdgeInsets.all(10),
                          text: 'Event',
                          onPressed: () {
                            print('Add Event');
                            hideFloatingButtonOptions();

                            Navigator.pushNamed(context, addEventRoute,
                                arguments: {
                                  'date': DateTime.parse(
                                      '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 00:00:00.000Z'),
                                });
                          },
                          backgroundColor: HFColors().primaryColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Floating news button
                AnimatedPositioned(
                  curve: floatingButtonShowNews
                      ? Curves.easeOutBack
                      : Curves.easeInOut,
                  bottom: floatingButtonShowNews ? 160 : 120,
                  right: floatingButtonShowNews ? 70 : 30,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    curve: floatingButtonShowNews
                        ? Curves.easeOutBack
                        : Curves.easeInOut,
                    opacity: floatingButtonShowNews ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedScale(
                      curve: floatingButtonShowNews
                          ? Curves.easeOutBack
                          : Curves.easeInOut,
                      scale: floatingButtonShowNews ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !floatingButtonShowNews,
                        child: HFButton(
                          useIcon: true,
                          icon: Icon(
                            CupertinoIcons.news_solid,
                            size: 20,
                            color: HFColors().secondaryColor(),
                          ),
                          padding: const EdgeInsets.all(10),
                          text: 'News',
                          onPressed: () {
                            print('Add News');
                            hideFloatingButtonOptions();
                            Navigator.pushNamed(context, addNewsRoute);
                          },
                          backgroundColor: HFColors().primaryColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Floating exercise button
                AnimatedPositioned(
                  curve: floatingButtonShowExercise
                      ? Curves.easeOutBack
                      : Curves.easeInOut,
                  bottom: floatingButtonShowExercise ? 110 : 120,
                  right: floatingButtonShowExercise ? 90 : 30,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    curve: floatingButtonShowExercise
                        ? Curves.easeOutBack
                        : Curves.easeInOut,
                    opacity: floatingButtonShowExercise ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedScale(
                      curve: floatingButtonShowExercise
                          ? Curves.easeOutBack
                          : Curves.easeInOut,
                      scale: floatingButtonShowExercise ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !floatingButtonShowExercise,
                        child: HFButton(
                          useIcon: true,
                          icon: SvgPicture.asset(
                            'assets/icon-gym.svg',
                            color: HFColors().secondaryColor(),
                            width: 20,
                          ),
                          padding: const EdgeInsets.all(10),
                          text: 'Exercise',
                          onPressed: () {
                            hideFloatingButtonOptions();
                            Navigator.pushNamed(context, addTrainingRoute);
                          },
                          backgroundColor: HFColors().primaryColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Main floating button
                if (context.watch<HFGlobalState>().userAccessLevel ==
                    accessLevels.trainer)
                  AnimatedPositioned(
                    curve: Curves.easeInOut,
                    bottom: 120,
                    right: context.watch<HFGlobalState>().rootScreenState !=
                                RootScreens.login &&
                            context.watch<HFGlobalState>().rootScreenState !=
                                RootScreens.welcome &&
                            context.watch<HFGlobalState>().rootScreenState !=
                                RootScreens.chat &&
                            context.watch<HFGlobalState>().rootScreenState !=
                                RootScreens.settings
                        ? 30
                        : -60,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedOpacity(
                      opacity: context.watch<HFGlobalState>().rootPageIndex ==
                                  0 ||
                              context.watch<HFGlobalState>().rootPageIndex == 1
                          ? 1
                          : 0,
                      duration: const Duration(milliseconds: 100),
                      child: FloatingActionButton(
                        heroTag: 'floating-button',
                        elevation: 10,
                        onPressed: () {
                          if (context.read<HFGlobalState>().rootScreenState ==
                              RootScreens.home) {
                            print('Add on home');
                            setState(() {
                              floatingButtonShowEvent =
                                  !floatingButtonShowEvent;
                            });

                            Timer(
                              const Duration(milliseconds: 50),
                              () => setState(() {
                                floatingButtonShowNews =
                                    !floatingButtonShowNews;
                              }),
                            );

                            Timer(
                              const Duration(milliseconds: 100),
                              () => setState(() {
                                floatingButtonShowExercise =
                                    !floatingButtonShowExercise;
                              }),
                            );
                          }

                          if (context.read<HFGlobalState>().rootScreenState ==
                              RootScreens.calendar) {
                            print('Add on calendar');
                            Navigator.pushNamed(
                              context,
                              addEventRoute,
                              arguments: {
                                'date': context
                                    .read<HFGlobalState>()
                                    .calendarSelectedDay,
                              },
                            );
                          }
                        },
                        backgroundColor: HFColors().primaryColor(),
                        mini: true,
                        child: Icon(
                          CupertinoIcons.add,
                          size: 20,
                          color: HFColors().secondaryColor(),
                        ),
                      ),
                    ),
                  ),
                // Floating menu
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.login &&
                          context.watch<HFGlobalState>().rootScreenState !=
                              RootScreens.welcome
                      ? 32
                      : -74,
                  left: 32,
                  right: 32,
                  child: Container(
                    height: barHeight,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topCenter,
                    padding:
                        const EdgeInsets.only(top: (barHeight - iconSize) / 2),
                    decoration: BoxDecoration(
                      color: HFColors().secondaryLightColor(),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        menuBarIcon(context, RootScreens.home, setState,
                            CupertinoIcons.home, hideFloatingButtonOptions),
                        menuBarIcon(context, RootScreens.calendar, setState,
                            CupertinoIcons.calendar, hideFloatingButtonOptions),
                        menuBarIcon(
                            context,
                            RootScreens.chat,
                            setState,
                            CupertinoIcons.chat_bubble_2,
                            hideFloatingButtonOptions),
                        menuBarIcon(context, RootScreens.settings, setState,
                            CupertinoIcons.settings, hideFloatingButtonOptions),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

fetchCalendarEvents(
    BuildContext context, DocumentSnapshot<Map<String, dynamic>> event) {
  Map<String, dynamic>? data = event.data();

  if (data == null ||
      context.read<HFGlobalState>().calendarLastUpdated == data['changed']) {
    return;
  }

  var newMap = <DateTime, List<Event>>{};

  context.read<HFGlobalState>().setCalendarLastUpdated(data['changed']);

  HFFirebaseFunctions()
      .getFirebaseAuthUser(context)
      .collection('days')
      .snapshots()
      .listen(
    (event) {
      event.docs.asMap().forEach((index, day) {
        HFFirebaseFunctions()
            .getFirebaseAuthUser(context)
            .collection('days')
            .doc(day.id)
            .collection('events')
            .orderBy('startTime')
            .get()
            .then(
          (value) {
            List<Event> events = [];

            value.docs.forEach((event) {
              var query = event;

              events.add(Event(
                title: query['title'],
                id: query['id'],
                startTime: query['startTime'],
                endTime: query['endTime'],
                client: query['client'],
                color: query['color'],
                exercises: query['exercises'],
                location: query['location'],
                notes: query['notes'],
                date: DateTime.parse(query['date']),
              ));
            });

            newMap[DateTime.parse(day.id)] = events;

            context.read<HFGlobalState>().setCalendarDays(newMap);
          },
        );
      });
    },
    onError: (error) => print("Listen failed: $error"),
  );
}

Widget menuBarIcon(
    BuildContext context, page, setState, icon, hideFloatingButtonOptions) {
  return Container(
    padding: const EdgeInsets.all(0),
    height: iconSize,
    width: iconSize,
    decoration: BoxDecoration(
      color: context.watch<HFGlobalState>().rootScreenState == page
          ? HFColors().primaryColor()
          : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    child: IconButton(
      enableFeedback: false,
      padding: const EdgeInsets.all(4),
      onPressed: () {
        setState(() {
          context.read<HFGlobalState>().setRootScreenState(page);
          hideFloatingButtonOptions();
        });
      },
      icon: Icon(
        icon,
        color: context.watch<HFGlobalState>().rootScreenState == page
            ? HFColors().secondaryColor()
            : HFColors().primaryColor(),
        size: 20,
      ),
    ),
  );
}
