import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_image.dart';

class SingleNews extends StatelessWidget {
  const SingleNews({
    Key? key,
    required this.title,
    required this.id,
    required this.date,
    required this.imageUrl,
    required this.content,
  }) : super(key: key);

  final String title;
  final String id;
  final String imageUrl;
  final String content;
  final String date;

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
          if (context.watch<HFGlobalState>().userAccessLevel ==
              accessLevels.trainer)
            IconButton(
                onPressed: () {
                  showAlertDialog(
                    context,
                    'Are you sure you want to delete $title',
                    () {
                      HFFirebaseFunctions()
                          .getFirebaseAuthUser(context)
                          .collection('news')
                          .doc('$id')
                          .delete()
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          getSnackBar(text: 'Deleted'),
                        );
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
                ))
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Padding(
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
                text: title,
                size: 8,
              ),
              const SizedBox(
                height: 10,
              ),
              HFParagrpah(
                text: DateFormat('dd.MM.yyyy.').format(DateTime.parse(date)),
                size: 7,
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 20,
              ),
              HFParagrpah(
                text: content,
                maxLines: 9999,
                size: 10,
                textAlign: TextAlign.left,
                lineHeight: 1.5,
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
