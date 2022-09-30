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
    this.dateCreated = '',
  }) : super(key: key);

  final String name;
  final String content;
  final String dateCreated;
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
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HFColors().primaryColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    CupertinoIcons.mail,
                    color: HFColors().secondaryColor(),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HFHeading(
                      text: 'Email:',
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    HFParagrpah(
                      size: 8,
                      text: email,
                      color: HFColors().whiteColor(opacity: 0.8),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HFColors().primaryColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    CupertinoIcons.calendar,
                    color: HFColors().secondaryColor(),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HFHeading(
                      text: 'Date created',
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    HFParagrpah(
                      size: 8,
                      text: dateCreated,
                      color: HFColors().whiteColor(opacity: 0.8),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const HFHeading(
              text: 'Message:',
              size: 6,
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
                FirebaseFirestore.instance
                    .collection('trainers')
                    .doc(context.read<HFGlobalState>().userId)
                    .collection('clients')
                    .doc(email)
                    .set({
                  'name': name,
                  'email': email,
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
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: '$name added to clients!',
                    color: HFColors().primaryColor(opacity: 1),
                  ));

                  HFFirebaseFunctions()
                      .getFirebaseAuthUser(context)
                      .collection('requests')
                      .doc(email)
                      .delete();

                  Navigator.pop(context);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
