import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/screens/root.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/global_state.dart';
import '../hf_button.dart';
import '../hf_heading.dart';
import '../hf_input_field.dart';
import '../hf_text_button.dart';
import 'dart:async';

class LoginSection extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FirebaseAuth authInstance;

  LoginSection({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.authInstance,
  }) : super(key: key);

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 30,
          ),
          const HFHeading(
            text: 'Login',
            size: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        'Use your credentials to login to your account. Or go back and ',
                    style: GoogleFonts.getFont(
                      'Manrope',
                      textStyle: TextStyle(
                          color: HFColors().whiteColor(), fontSize: 14),
                    )),
                TextSpan(
                  text: 'find a trainer.',
                  style: GoogleFonts.getFont(
                    'Manrope',
                    textStyle: TextStyle(
                      color: HFColors().primaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context
                          .read<HFGlobalState>()
                          .setSplashScreenState(SplashScreens.findTrainer);
                    },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          HFInput(
            controller: widget.emailController,
            textCapitalization: TextCapitalization.none,
            hintText: 'Email',
            showCursor: true,
            keyboardType: TextInputType.emailAddress,
          ),
          HFInput(
            controller: widget.passwordController,
            obscureText: true,
            showCursor: true,
            onTap: (() {
              context.read<HFGlobalState>().setInputFieldFocused(true);
            }),
            onEditingComplete: (() {
              context.read<HFGlobalState>().setInputFieldFocused(true);
            }),
            hintText: 'Password',
          ),
          const SizedBox(
            height: 10,
          ),
          HFButton(
            text: 'Login',
            padding: const EdgeInsets.symmetric(vertical: 20),
            onPressed: () async {
              try {
                await widget.authInstance
                    .signInWithEmailAndPassword(
                  email: widget.emailController.text == ''
                      ? 'biscan.karlo@gmail.com' //'biscan.karlof@gmail.com'
                      : widget.emailController.text,
                  password: widget.passwordController.text == ''
                      ? '12345678' //'3Vt#Npb&Jde68'
                      : widget.passwordController.text,
                )
                    .then((value) {
                  final idTokenResult =
                      value.user!.getIdTokenResult(true).then((result) {
                    var accessLevel = result.claims?['accessLevel'];
                    context
                        .read<HFGlobalState>()
                        .setUserAccessLevel(accessLevel);

                    if (context.read<HFGlobalState>().userAccessLevel ==
                        accessLevels.client) {
                      HFFirebaseFunctions()
                          .initClientData(value.user!.uid, context);
                    }

                    if (context.read<HFGlobalState>().userAccessLevel ==
                        accessLevels.trainer) {
                      HFFirebaseFunctions()
                          .initTrainerData(value.user!.uid, context);

                      // context
                      //     .read<HFGlobalState>()
                      //     .setRootScreenState(RootScreens.home);
                    }
                  });
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  getSnackBar(
                      text: e.toString(), color: HFColors().primaryColor()),
                );
              }
            },
          ),
          HFTextButton(
            text: 'Forgot password?',
            onPressed: () {
              context
                  .read<HFGlobalState>()
                  .setSplashScreenState(SplashScreens.reset);
            },
          )
        ],
      ),
    );
  }
}
