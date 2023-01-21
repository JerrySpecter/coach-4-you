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
  List<dynamic> allClients = [];

  getAllClients() async {
    var clients = await HFFirebaseFunctions()
        .getTrainersUser()
        .collection('clients')
        .orderBy("name", descending: false)
        .get();

    var tempClients = await HFFirebaseFunctions()
        .getTrainersUser()
        .collection('tempClients')
        .orderBy("name", descending: false)
        .get();

    setState(() {
      allClients = [...clients.docs, ...tempClients.docs];
    });
  }

  @override
  Widget build(BuildContext context) {
    getAllClients();

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
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: ListView(
                  children: [
                    if (allClients.isNotEmpty)
                      ...allClients.map((client) {
                        var isTemp = client['email'] == '';

                        return HFClientListViewTile(
                          name: client['name'],
                          email: client['email'],
                          imageUrl: client['imageUrl'],
                          available: isTemp ? true : client['accountReady'],
                          showAvailable: true,
                          useSpacerBottom: true,
                          onTap: () {
                            Navigator.pushNamed(context, clientProfileRoute,
                                arguments: {
                                  'name': client['name'],
                                  'email': isTemp ? '' : client['email'],
                                  'imageUrl': isTemp ? '' : client['imageUrl'],
                                  'id': isTemp ? client.id : client['id'],
                                  'weight': '',
                                  'height': '',
                                  'profileBackgroundImageUrl': '',
                                  'asTrainer': true
                                });
                          },
                          child: !isTemp
                              ? Column(
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
                                )
                              : SizedBox(
                                  height: 10,
                                ),
                        );
                      })
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: HFHeading(
                            text: 'No clients yet.',
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<QuerySnapshot> clients = HFFirebaseFunctions()
//     .getTrainersUser()
//     .collection('clients')
//     .orderBy("name", descending: false)
//     .get();

// Future<QuerySnapshot> tempClients = HFFirebaseFunctions()
//     .getTrainersUser()
//     .collection('tempClients')
//     .orderBy("name", descending: false)
//     .get();
