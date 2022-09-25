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

  @override
  Widget build(BuildContext context) {
    double contentHeight = MediaQuery.of(context).size.height - 420;
    double imageSize = 250;

    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height +
                MediaQuery.of(context).viewInsets.bottom,
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
                                SplashScreens.findTrainer
                            ? -10
                            : (contentHeight / 2) - (imageSize / 2) + 20,
                        left: 0,
                        right: 0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedScale(
                          scale: context
                                      .watch<HFGlobalState>()
                                      .splashScreenState ==
                                  SplashScreens.findTrainer
                              ? 0.4
                              : 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Image(
                            image: const AssetImage('assets/c4y-logo.png'),
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
                  top: context.watch<HFGlobalState>().splashScreenState ==
                          SplashScreens.findTrainer
                      ? 180
                      : contentHeight,
                  left: 0,
                  right: 0,
                  duration: const Duration(milliseconds: 200),
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
                            top: context
                                        .watch<HFGlobalState>()
                                        .splashScreenState ==
                                    SplashScreens.findTrainer
                                ? 0
                                : 100,
                            left: 0,
                            right: 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              opacity: context
                                          .watch<HFGlobalState>()
                                          .splashScreenState ==
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
                            top: context
                                        .watch<HFGlobalState>()
                                        .splashScreenState ==
                                    SplashScreens.splash
                                ? 0
                                : -100,
                            left: 0,
                            right: 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              opacity: context
                                          .watch<HFGlobalState>()
                                          .splashScreenState ==
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
                            top: context
                                        .watch<HFGlobalState>()
                                        .splashScreenState ==
                                    SplashScreens.login
                                ? 0
                                : context
                                            .watch<HFGlobalState>()
                                            .splashScreenState ==
                                        SplashScreens.reset
                                    ? -100
                                    : 10,
                            left: 0,
                            right: 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              opacity: context
                                          .watch<HFGlobalState>()
                                          .splashScreenState ==
                                      SplashScreens.login
                                  ? 1
                                  : 0,
                              child: IgnorePointer(
                                ignoring: context
                                        .watch<HFGlobalState>()
                                        .splashScreenState !=
                                    SplashScreens.login,
                                child: LoginSection(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  authInstance: _authInstance,
                                ),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            top: context
                                        .watch<HFGlobalState>()
                                        .splashScreenState ==
                                    SplashScreens.reset
                                ? 0
                                : context
                                            .watch<HFGlobalState>()
                                            .splashScreenState ==
                                        SplashScreens.login
                                    ? 100
                                    : 10,
                            left: 0,
                            right: 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              opacity: context
                                          .watch<HFGlobalState>()
                                          .splashScreenState ==
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
          ),
        ],
      ),
    );
  }
}
