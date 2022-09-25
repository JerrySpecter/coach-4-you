import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/screens/trainings/add_trainings.dart';
import 'package:health_factory/widgets/hf_dialog.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_training_list_view_tile.dart';

import '../../constants/colors.dart';
import '../../constants/firebase_functions.dart';
import '../../constants/routes.dart';

class SingleTraining extends StatefulWidget {
  const SingleTraining({
    Key? key,
    required this.name,
    required this.id,
    required this.note,
    required this.exercises,
  }) : super(key: key);

  final String name;
  final String id;
  final String note;
  final List<dynamic> exercises;

  @override
  State<SingleTraining> createState() => _SingleTrainingState();
}

class _SingleTrainingState extends State<SingleTraining> {
  String _nameState = '';
  String _noteState = '';
  List<dynamic> _exercisesState = [];

  @override
  void initState() {
    print('init state single training');
    _nameState = widget.name;
    _noteState = widget.note;
    _exercisesState = widget.exercises;

    super.initState();
  }

  @override
  void dispose() {
    print('dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              showAlertDialog(
                context,
                'Are you sure you want to delete video: $_nameState',
                () {
                  HFFirebaseFunctions()
                      .getFirebaseAuthUser(context)
                      .collection('trainings')
                      .doc(widget.id)
                      .delete()
                      .then((value) {
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                editTrainingRoute,
                arguments: {
                  'parentContext': context,
                  'id': widget.id,
                  'name': _nameState,
                  'note': _noteState,
                  'exercises': _exercisesState,
                  'isEdit': false,
                  'isDuplicate': true
                },
              );
            },
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                editTrainingRoute,
                arguments: {
                  'parentContext': context,
                  'id': widget.id,
                  'name': _nameState,
                  'note': _noteState,
                  'exercises': _exercisesState,
                  'isEdit': true,
                  'isDuplicate': false
                },
              );
            },
            icon: const Icon(CupertinoIcons.pen),
          )
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              HFHeading(
                text: _nameState,
                size: 7,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: HFColors().primaryColor(opacity: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._exercisesState.map((exercise) {
                      return HFTrainingListViewTile(
                        showDelete: false,
                        name: exercise['name'],
                        note: exercise['note'],
                        type: exercise['type'],
                        amount: double.parse(exercise['amount']),
                        repetitions: double.parse(exercise['repetitions']),
                        series: double.parse(exercise['series']),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const HFHeading(
                text: 'Note:',
                size: 6,
                lineHeight: 2,
              ),
              HFParagrpah(
                text: _noteState,
                size: 8,
                lineHeight: 1.4,
                maxLines: 999,
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateAndDisplayEditScreen(data) {
    final result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTraining(
          parentContext: context,
          id: data['id'],
          name: data['name'],
          note: data['note'],
          exercises: data['exercises'],
          isEdit: true,
        ),
      ),
    ).then((value) {
      // This block runs when you have returned back to the 1st Page from 2nd.
      if (!mounted) return;

      setState(() {
        if (value != null) {
          _nameState = value['name'];
          _noteState = value['note'];
          _exercisesState = value['exercises'];
        } else {
          _nameState = widget.name;
          _noteState = widget.note;
          _exercisesState = widget.exercises;
        }
      });
    });
  }
}
