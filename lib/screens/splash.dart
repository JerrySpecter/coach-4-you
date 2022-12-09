import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/splash/hf_find_trainer_section.dart';
import 'package:health_factory/widgets/splash/hf_login_section.dart';
import 'package:health_factory/widgets/splash/hf_reset_password_section.dart';
import 'package:health_factory/widgets/splash/hf_splash_section.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _emailResetController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _authInstance = FirebaseAuth.instance;
  var animationDuration = 400;
  var smallAnimationDuration = 200;
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer(Duration(milliseconds: 2000), () {
      context.read<HFGlobalState>().setSplashScreenState(SplashScreens.splash);
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double contentHeight = MediaQuery.of(context).size.height;
    double imageSize = 250;

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      // height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          SizedBox(
            height: contentHeight,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  top: context.watch<HFGlobalState>().splashScreenState ==
                          SplashScreens.init
                      ? (contentHeight / 2) - (imageSize / 2) + 20
                      : context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.findTrainer
                          ? -10
                          : 100,
                  left: 0,
                  right: 0,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: animationDuration),
                  child: AnimatedScale(
                    scale: context.watch<HFGlobalState>().splashScreenState ==
                            SplashScreens.findTrainer
                        ? 0.4
                        : 1,
                    duration: Duration(milliseconds: smallAnimationDuration),
                    curve: Curves.easeInOut,
                    child: Image(
                      image: const AssetImage(
                          'assets/icon/transparentandroidlogo.png'),
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedPositioned(
            bottom: context.watch<HFGlobalState>().splashScreenState ==
                    SplashScreens.findTrainer
                ? -70
                : context.watch<HFGlobalState>().splashScreenState ==
                        SplashScreens.init
                    ? -(MediaQuery.of(context).size.height)
                    : -250 +
                        (MediaQuery.of(context).viewInsets.bottom >= 80
                            ? MediaQuery.of(context).viewInsets.bottom - 80
                            : 0),
            left: 0,
            right: 0,
            duration: Duration(milliseconds: animationDuration),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 120,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: HFColors().secondaryLightColor(),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      top: context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.findTrainer
                          ? 0
                          : 100,
                      left: 0,
                      right: 0,
                      duration: Duration(milliseconds: animationDuration),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        duration:
                            Duration(milliseconds: smallAnimationDuration),
                        curve: Curves.easeInOut,
                        opacity:
                            context.watch<HFGlobalState>().splashScreenState ==
                                    SplashScreens.findTrainer
                                ? 1
                                : 0,
                        child: IgnorePointer(
                            ignoring: context
                                    .watch<HFGlobalState>()
                                    .splashScreenState !=
                                SplashScreens.findTrainer,
                            child: const FindTrainerSection()),
                      ),
                    ),
                    AnimatedPositioned(
                      top: context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.splash
                          ? 0
                          : -100,
                      left: 0,
                      right: 0,
                      duration: Duration(milliseconds: animationDuration),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        duration:
                            Duration(milliseconds: smallAnimationDuration),
                        curve: Curves.easeInOut,
                        opacity:
                            context.watch<HFGlobalState>().splashScreenState ==
                                    SplashScreens.splash
                                ? 1
                                : 0,
                        child: IgnorePointer(
                            ignoring: context
                                    .watch<HFGlobalState>()
                                    .splashScreenState !=
                                SplashScreens.splash,
                            child: const SplashSection()),
                      ),
                    ),
                    AnimatedPositioned(
                      top: context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.login
                          ? 0
                          : context.watch<HFGlobalState>().splashScreenState ==
                                  SplashScreens.reset
                              ? -100
                              : 10,
                      left: 0,
                      right: 0,
                      duration: Duration(milliseconds: animationDuration),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        duration:
                            Duration(milliseconds: smallAnimationDuration),
                        curve: Curves.easeInOut,
                        opacity:
                            context.watch<HFGlobalState>().splashScreenState ==
                                    SplashScreens.login
                                ? 1
                                : 0,
                        child: IgnorePointer(
                          ignoring: context
                                  .watch<HFGlobalState>()
                                  .splashScreenState !=
                              SplashScreens.login,
                          child: LoginSection(
                            authInstance: _authInstance,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      top: context.watch<HFGlobalState>().splashScreenState ==
                              SplashScreens.reset
                          ? 0
                          : context.watch<HFGlobalState>().splashScreenState ==
                                  SplashScreens.login
                              ? 100
                              : 10,
                      left: 0,
                      right: 0,
                      duration: Duration(milliseconds: animationDuration),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        duration:
                            Duration(milliseconds: smallAnimationDuration),
                        curve: Curves.easeInOut,
                        opacity:
                            context.watch<HFGlobalState>().splashScreenState ==
                                    SplashScreens.reset
                                ? 1
                                : 0,
                        child: IgnorePointer(
                          ignoring: context
                                  .watch<HFGlobalState>()
                                  .splashScreenState !=
                              SplashScreens.reset,
                          child: ResetPasswordSection(
                            emailResetController: _emailResetController,
                            authInstance: _authInstance,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
