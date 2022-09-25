import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:uuid/uuid.dart';

class AddLocations extends StatelessWidget {
  const AddLocations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Add new location',
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
            children: const [
              SizedBox(
                height: 10,
              ),
              AddLocationsForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class AddLocationsForm extends StatefulWidget {
  const AddLocationsForm({Key? key}) : super(key: key);

  @override
  State<AddLocationsForm> createState() => _AddLocationsFormState();
}

class _AddLocationsFormState extends State<AddLocationsForm> {
  final _locationNameController = TextEditingController();
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
            hintText: 'Location name',
            controller: _locationNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter any name.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 40,
          ),
          HFButton(
            text: _isLoading ? 'Adding...' : 'Add location',
            padding: const EdgeInsets.all(16),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                var newId = Uuid().v4();

                FirebaseFirestore.instance
                    .collection('locations')
                    .doc(newId)
                    .set({
                  'name': _locationNameController.text,
                  'id': newId
                }).then((value) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    text: 'Location added',
                    color: HFColors().primaryColor(opacity: 1),
                  ));

                  setState(() {
                    _isLoading = false;
                  });
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
