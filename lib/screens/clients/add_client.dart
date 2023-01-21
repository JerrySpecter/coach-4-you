import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:uuid/uuid.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({
    Key? key,
  }) : super(key: key);

  @override
  AddClientScreenState createState() => AddClientScreenState();
}

class AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _startUpload = false;

  String eventName = '';
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: const HFHeading(
          text: 'Add client',
          size: 6,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HFInput(
                      controller: clientNameController,
                      hintText: 'Client name',
                      showCursor: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFInput(
                      controller: clientEmailController,
                      hintText: 'Client email',
                      showCursor: true,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        }

                        if (value.isNotEmpty) {
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter valid email address.';
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HFButton(
                      text: _startUpload ? 'Adding...' : 'Add client',
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var newId = const Uuid().v4();

                          if (clientEmailController.text == '') {
                            HFFirebaseFunctions()
                                .getFirebaseAuthUser(context)
                                .collection('tempClients')
                                .doc(newId)
                                .set({
                              'name': clientNameController.text,
                              'email': '',
                              'imageUrl': '',
                              'height': '',
                              'messages': {
                                'numberOfUnseenClient': 0,
                                'numberOfUnseenTrainer': 0,
                                'lastMessageDate': '',
                                'lastMessageText': '',
                              },
                              'accountReady': false,
                            }).then((value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(
                                text:
                                    '${clientNameController.text} added to clients!',
                                color: HFColors().primaryColor(opacity: 1),
                              ));

                              Navigator.pop(context);
                            });
                          } else {
                            HFFirebaseFunctions()
                                .getFirebaseAuthUser(context)
                                .collection('clients')
                                .doc(clientEmailController.text)
                                .set({
                              'name': clientNameController.text,
                              'email': clientEmailController.text,
                              'imageUrl': '',
                              'height': '',
                              'messages': {
                                'numberOfUnseenClient': 0,
                                'numberOfUnseenTrainer': 0,
                                'lastMessageDate': '',
                                'lastMessageText': '',
                              },
                              'accountReady': false,
                            }).then((value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(
                                text:
                                    '${clientNameController.text} added to clients!',
                                color: HFColors().primaryColor(opacity: 1),
                              ));

                              Navigator.pop(context);
                            });
                          }
                        }
                      },
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
