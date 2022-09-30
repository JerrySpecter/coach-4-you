import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/firebase_functions.dart';
import '../../widgets/hf_client_list_view_tile.dart';
import '../../widgets/hf_input_field.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  ClientsPageState createState() => ClientsPageState();
}

class ClientsPageState extends State<ClientsPage> {
  final TextEditingController _searchFieldController = TextEditingController();
  String searchText = '';
  Stream stream = HFFirebaseFunctions()
      .getTrainersUser()
      .collection('clients')
      .orderBy("name", descending: false)
      .snapshots();

  @override
  void initState() {
    stream = HFFirebaseFunctions()
        .getTrainersUser()
        .collection('clients')
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
          text: 'Clients',
          size: 6,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<Object>(
              stream: FirebaseFirestore.instance
                  .collection('trainers')
                  .doc(context.read<HFGlobalState>().userId)
                  .collection('requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, requestsRoute);
                    },
                    child: HFParagrpah(
                      text: 'Requests',
                      size: 10,
                      color: HFColors().primaryColor(),
                    ),
                  );
                }

                var data = snapshot.data as QuerySnapshot;

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, requestsRoute);
                  },
                  child: HFParagrpah(
                    size: 10,
                    color: HFColors().primaryColor(),
                    text: 'Requests (${data.docs.length})',
                  ),
                );
              },
            ),
          )
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: HFColors().primaryColor(),
          borderRadius: BorderRadius.circular(24),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, addClient);
          },
          icon: const Icon(CupertinoIcons.add),
        ),
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
                        .getTrainersUser()
                        .collection('clients')
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
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'No clients.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  var data = snapshot.data as QuerySnapshot;

                  if (data.docs.isEmpty) {
                    return const Center(
                      child: HFParagrpah(
                        text: 'There are no clients.',
                        size: 10,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 136,
                    child: ListView(
                      children: [
                        ...data.docs.map((client) {
                          return HFClientListViewTile(
                            name: client['name'],
                            email: client['email'],
                            imageUrl: client['imageUrl'],
                            available: client['accountReady'],
                            showAvailable: true,
                            useSpacerBottom: true,
                            onTap: () {
                              Navigator.pushNamed(context, clientProfileRoute,
                                  arguments: {
                                    'name': client['name'],
                                    'email': client['email'],
                                    'imageUrl': client['imageUrl'],
                                    'id': client['id'],
                                    'weight': '',
                                    'height': '',
                                    'profileBackgroundImageUrl': '',
                                    'asTrainer': true
                                  });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HFParagrpah(
                                  text: 'Email:',
                                  size: 7,
                                  color: HFColors().whiteColor(),
                                  fontWeight: FontWeight.w700,
                                ),
                                HFParagrpah(
                                  text: client['email'],
                                  size: 7,
                                  maxLines: 2,
                                  color: HFColors().whiteColor(),
                                ),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
