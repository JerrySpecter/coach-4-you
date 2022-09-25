import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/firebase_functions.dart';
import '../../widgets/hf_input_field.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  RequestsPageState createState() => RequestsPageState();
}

class RequestsPageState extends State<RequestsPage> {
  final TextEditingController _searchFieldController = TextEditingController();
  String searchText = '';
  Stream stream = HFFirebaseFunctions()
      .getTrainersUser()
      .collection('requests')
      .orderBy("name", descending: false)
      .snapshots();

  @override
  void initState() {
    stream = HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection('requests')
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        title: const HFHeading(
          text: 'Requests',
          size: 6,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              HFInput(
                controller: _searchFieldController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    stream = HFFirebaseFunctions()
                        .getFirebaseAuthUser(context)
                        .collection('requests')
                        .where('name', isGreaterThanOrEqualTo: searchText)
                        .where('name', isLessThan: '${searchText}z')
                        .orderBy("name", descending: false)
                        .snapshots();
                  });
                },
                hintText: 'Search',
                keyboardType: TextInputType.text,
                verticalContentPadding: 12,
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: HFFirebaseFunctions()
                      .getFirebaseAuthUser(context)
                      .collection('requests')
                      .orderBy("name", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No requests.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'There are no requests.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 136,
                      child: ListView(children: [
                        ...data.docs.map((request) {
                          var dateCreated = request['dateCreated'] as Timestamp;

                          return HFListViewTile(
                            name: request['name'],
                            email: request['email'],
                            useImage: false,
                            showAvailable: false,
                            useSpacerBottom: true,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                singleRequestRoute,
                                arguments: {
                                  'name': request['name'],
                                  'email': request['email'],
                                  'content': request['content'],
                                  'dateCreated': DateFormat('EEE, d/M/y')
                                      .format(dateCreated.toDate()),
                                },
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HFParagrpah(
                                  text: DateFormat('EEE, d/M/y')
                                      .format(dateCreated.toDate()),
                                  size: 7,
                                  color: HFColors().whiteColor(),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                HFParagrpah(
                                  text: 'Message:',
                                  size: 7,
                                  color: HFColors().whiteColor(),
                                  fontWeight: FontWeight.w700,
                                ),
                                HFParagrpah(
                                  text: request['content'],
                                  size: 7,
                                  maxLines: 2,
                                  color: HFColors().whiteColor(),
                                ),
                              ],
                            ),
                          );
                        })
                      ]),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
