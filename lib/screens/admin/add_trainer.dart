import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../constants/firebase_functions.dart';

class AddTrainers extends StatelessWidget {
  const AddTrainers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Add new trainer',
        ),
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 10,
              ),
              AddTrainersForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTrainersForm extends StatefulWidget {
  AddTrainersForm({Key? key}) : super(key: key);

  @override
  State<AddTrainersForm> createState() => _AddTrainersFormState();
}

class _AddTrainersFormState extends State<AddTrainersForm> {
  final _trainerFirstNameController = TextEditingController();
  final _trainerLastNameController = TextEditingController();
  final _trainerEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isTestAccount = false;
  bool _isExternal = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HFInput(
            hintText: 'Trainer first name',
            controller: _trainerFirstNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter trainers name.';
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          HFInput(
            hintText: 'Trainer last name',
            controller: _trainerLastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter trainers name.';
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          HFInput(
            hintText: 'Trainer email',
            textCapitalization: TextCapitalization.none,
            controller: _trainerEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter trainers email.';
              }

              if (!EmailValidator.validate(value)) {
                return 'Please enter valid email address.';
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          getToggleRow('Trainer is admin', _isAdmin, (value) {
            setState(() {
              _isAdmin = value;
            });
          }),
          SizedBox(
            height: 10,
          ),
          getToggleRow('Test account', _isTestAccount, (value) {
            setState(() {
              _isTestAccount = value;
            });
          }),
          SizedBox(
            height: 10,
          ),
          getToggleRow('External', _isExternal, (value) {
            setState(() {
              _isExternal = value;
            });
          }),
          SizedBox(
            height: 40,
          ),
          HFButton(
            text: _isLoading ? 'Adding...' : 'Add trainer',
            padding: EdgeInsets.all(16),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                http
                    .post(
                        Uri.parse(
                            'https://us-central1-health-factory-56e91.cloudfunctions.net/createUser'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8'
                        },
                        body: jsonEncode(<String, dynamic>{
                          'firstName': _trainerFirstNameController.text,
                          'lastName': _trainerLastNameController.text,
                          'email': _trainerEmailController.text,
                          'changed': '${DateTime.now()}',
                          'isAdmin': _isAdmin,
                          'isTestAccount': _isTestAccount,
                          'isExternal': _isExternal
                        }))
                    .then((value) {
                  var responseBody = jsonDecode(value.body);

                  switch (responseBody['code']) {
                    case 400:
                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: responseBody['errorMessage'],
                        color: HFColors().redColor(opacity: 1),
                      ));

                      setState(() {
                        _isLoading = false;
                      });
                      break;
                    default:
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: 'Trainer added',
                        color: HFColors().primaryColor(opacity: 1),
                      ));
                  }
                }).onError((error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'Error',
                    color: HFColors().redColor(opacity: 1),
                  ));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'Error',
                    color: HFColors().redColor(opacity: 1),
                  ));
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget getToggleRow(text, prop, onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: HFColors().secondaryLightColor(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: HFHeading(
                        text: text,
                        size: 4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      flex: 1,
                      child: CupertinoSwitch(
                        value: prop,
                        onChanged: onChanged,
                        thumbColor: HFColors().primaryColor(),
                        trackColor: HFColors().redColor(opacity: 0.4),
                        activeColor: HFColors().greenColor(opacity: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
