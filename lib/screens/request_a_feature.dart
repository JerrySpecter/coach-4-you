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

class RequestAFeature extends StatefulWidget {
  RequestAFeature({
    Key? key,
  }) : super(key: key);

  @override
  State<RequestAFeature> createState() => _RequestAFeatureState();
}

class _RequestAFeatureState extends State<RequestAFeature> {
  final TextEditingController requestFieldTextController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Request a new feature', []),
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
                controller: requestFieldTextController,
                keyboardType: TextInputType.multiline,
                labelText: 'Describe your feature',
                minLines: 6,
                maxLines: 10,
              ),
              const SizedBox(
                height: 40,
              ),
              HFButton(
                text: 'Request',
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: () async {
                  final deviceInfoPlugin = DeviceInfoPlugin();
                  final deviceInfo = await deviceInfoPlugin.deviceInfo;

                  FirebaseFirestore.instance
                      .collection('featureRequests')
                      .doc()
                      .set({
                    'name': context.read<HFGlobalState>().userName,
                    'email': context.read<HFGlobalState>().userEmail,
                    'request': requestFieldTextController.text,
                    'resolved': false,
                    'date': DateTime.now(),
                  }).then((value) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'Feature requested',
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
