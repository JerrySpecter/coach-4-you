import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:uuid/uuid.dart';

class ClientAddMeasurement extends StatelessWidget {
  ClientAddMeasurement(
      {Key? key, required this.hintText, required this.collection})
      : super(key: key);
  String hintText;
  String collection;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Add new measurement',
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
              ClientAddMeasurementForm(
                hintText: hintText,
                collection: collection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientAddMeasurementForm extends StatefulWidget {
  ClientAddMeasurementForm(
      {Key? key, required this.hintText, required this.collection})
      : super(key: key);

  String hintText;
  String collection;

  @override
  State<ClientAddMeasurementForm> createState() =>
      _ClientAddMeasurementFormState();
}

class _ClientAddMeasurementFormState extends State<ClientAddMeasurementForm> {
  final weightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HFInput(
            hintText: widget.hintText,
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter weight.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          HFButton(
            text: _isLoading ? 'Adding...' : 'Add',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                var newId = const Uuid().v4();

                var editedData = {
                  'value': weightController.text,
                  'date': '${DateTime.now()}',
                  'id': newId,
                };

                HFFirebaseFunctions()
                    .getFirebaseAuthUser(context)
                    .collection(widget.collection)
                    .doc(newId)
                    .set(editedData)
                    .then((value) {
                  Navigator.pop(context, editedData);

                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'Measurement added',
                    color: HFColors().primaryColor(opacity: 1),
                  ));

                  setState(() {
                    _isLoading = false;
                  });
                }).catchError((onError) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'There was an error',
                    color: HFColors().redColor(opacity: 1),
                  ));
                }).onError((error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'There was an error',
                    color: HFColors().redColor(opacity: 1),
                  ));
                });
              }
            },
          ),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
