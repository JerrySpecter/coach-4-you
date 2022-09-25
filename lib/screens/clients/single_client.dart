import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_image.dart';

class SingleClient extends StatelessWidget {
  const SingleClient({
    Key? key,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
  }) : super(key: key);

  final String name;
  final String id;
  final String imageUrl;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: const HFHeading(
          text: '',
          size: 6,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showAlertDialog(
                context,
                'Are you sure you want to delete video: ${name}',
                () {
                  HFFirebaseFunctions()
                      .getFirebaseAuthUser(context)
                      .collection('clients')
                      .doc(email)
                      .delete()
                      .then((value) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(getSnackBar(text: 'Client deleted'));
                    Navigator.pop(context);
                  }).then((value) {
                    Navigator.pop(context);
                  });
                },
                'Yes',
                () {
                  Navigator.pop(context);
                },
                'No',
              );
            },
            icon: Icon(
              CupertinoIcons.trash,
              color: HFColors().redColor(),
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: HFImage(imageUrl: imageUrl),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            HFHeading(
              text: name,
              size: 8,
            ),
          ],
        ),
      ),
    );
  }
}
