import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_appbar.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/firebase_functions.dart';
import '../widgets/hf_input_field.dart';

class ReportABug extends StatefulWidget {
  ReportABug({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportABug> createState() => _ReportABugState();
}

class _ReportABugState extends State<ReportABug> {
  final TextEditingController bugReportTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Report a problem', []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              HFInput(
                controller: bugReportTextController,
                keyboardType: TextInputType.multiline,
                labelText: 'Describe your problem',
                minLines: 6,
                maxLines: 10,
              ),
              const SizedBox(
                height: 40,
              ),
              HFButton(
                text: 'Report',
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: () async {
                  final deviceInfoPlugin = DeviceInfoPlugin();
                  final deviceInfo = await deviceInfoPlugin.deviceInfo;

                  FirebaseFirestore.instance
                      .collection('bugReports')
                      .doc()
                      .set({
                    'name': context.read<HFGlobalState>().userName,
                    'email': context.read<HFGlobalState>().userEmail,
                    'report': bugReportTextController.text,
                    'date': DateTime.now(),
                    'resolved': false,
                    'device': deviceInfo.toMap()
                  }).then((value) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'Bug reported',
                      color: HFColors().primaryColor(opacity: 1),
                    ));
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'There was an error',
                      color: HFColors().redColor(opacity: 1),
                    ));
                  });
                },
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
