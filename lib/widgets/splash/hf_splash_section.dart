import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../constants/global_state.dart';
import '../hf_button.dart';
import '../hf_heading.dart';
import '../hf_paragraph.dart';

class SplashSection extends StatelessWidget {
  const SplashSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            height: 30,
          ),
          const HFHeading(
            text: 'Welcome!',
            size: 10,
          ),
          const SizedBox(
            height: 30,
          ),
          const HFParagrpah(
            text: 'Need a coach? You can find one here:',
            size: 9,
          ),
          const SizedBox(
            height: 10,
          ),
          HFButton(
            text: 'Find a coach',
            padding: const EdgeInsets.symmetric(vertical: 20),
            onPressed: () {
              context
                  .read<HFGlobalState>()
                  .setSplashScreenState(SplashScreens.findTrainer);
            },
          ),
          const SizedBox(
            height: 30,
          ),
          const HFParagrpah(
            text: 'Already have an account? Login here:',
            size: 9,
          ),
          const SizedBox(
            height: 10,
          ),
          HFButton(
            text: 'Login',
            padding: const EdgeInsets.symmetric(vertical: 20),
            onPressed: () {
              context
                  .read<HFGlobalState>()
                  .setSplashScreenState(SplashScreens.login);
            },
          ),
        ],
      ),
    );
  }
}
