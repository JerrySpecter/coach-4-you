import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';

class SingleRequest extends StatelessWidget {
  const SingleRequest({
    Key? key,
    required this.name,
    required this.email,
    required this.content,
  }) : super(key: key);

  final String name;
  final String content;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: HFHeading(
          text: name,
          size: 6,
        ),
        actions: [
          IconButton(
              onPressed: () {
                HFFirebaseFunctions()
                    .getFirebaseAuthUser(context)
                    .collection('requests')
                    .doc(email)
                    .delete()
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'Request has been deleted!',
                      color: HFColors().primaryColor(opacity: 1)));

                  Navigator.pop(context);
                });
              },
              icon: const Icon(CupertinoIcons.trash))
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 20,
            ),
            const HFParagrpah(
              text: 'Email address:',
              size: 7,
            ),
            HFHeading(
              text: email,
              size: 6,
            ),
            const SizedBox(
              height: 20,
            ),
            const HFParagrpah(
              text: 'Message:',
              size: 7,
            ),
            const SizedBox(
              height: 10,
            ),
            HFParagrpah(
              text: content,
              size: 11,
              maxLines: 9999,
            ),
            const SizedBox(
              height: 40,
            ),
            HFButton(
              text: 'Accept request',
              padding: const EdgeInsets.all(16),
              onPressed: () {
                print('Accept request');
                FirebaseFirestore.instance
                    .collection('trainers')
                    .doc(context.read<HFGlobalState>().userId)
                    .collection('clients')
                    .doc()
                    .set({
                  'name': name,
                  'email': email,
                }).then((value) => {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(getSnackBar(
                            text: '$name has been added to clients!',
                            color: HFColors().primaryColor(opacity: 1),
                          ))

                          // TODO: go back
                          // TODO: remove request after accepting
                        });
              },
            )
          ],
        ),
      ),
    );
  }
}
