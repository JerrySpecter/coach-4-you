import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';

import '../../constants/global_state.dart';
import '../hf_button.dart';
import '../hf_heading.dart';
import '../hf_input_field.dart';
import '../hf_paragraph.dart';
import '../hf_text_button.dart';

class ResetPasswordSection extends StatefulWidget {
  final TextEditingController emailResetController;
  final FirebaseAuth authInstance;

  const ResetPasswordSection({
    Key? key,
    required this.emailResetController,
    required this.authInstance,
  }) : super(key: key);

  @override
  State<ResetPasswordSection> createState() => _ResetPasswordSectionState();
}

class _ResetPasswordSectionState extends State<ResetPasswordSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 30,
            ),
            const HFHeading(
              text: 'Forgot Password?',
              size: 8,
            ),
            const SizedBox(
              height: 10,
            ),
            const HFParagrpah(
              text:
                  "Please enter the email addres associated with your account.",
              size: 8,
            ),
            const SizedBox(
              height: 10,
            ),
            HFInput(
              controller: widget.emailResetController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              showCursor: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter trainers email.';
                }

                if (!EmailValidator.validate(value)) {
                  return 'Please enter valid email address.';
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            HFButton(
              text: 'Send email',
              padding: const EdgeInsets.symmetric(vertical: 20),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());

                if (_formKey.currentState!.validate()) {
                  try {
                    FirebaseAuth.instance.sendPasswordResetEmail(
                      email: widget.emailResetController.text,
                    );

                    context
                        .read<HFGlobalState>()
                        .setSplashScreenState(SplashScreens.login);

                    widget.emailResetController.text = '';
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      getSnackBar(
                          text: e.toString(), color: HFColors().primaryColor()),
                    );
                  }
                }
              },
            ),
            HFTextButton(
              text: 'Back to login',
              onPressed: () {
                context
                    .read<HFGlobalState>()
                    .setSplashScreenState(SplashScreens.login);
              },
            )
          ],
        ),
      ),
    );
  }
}
