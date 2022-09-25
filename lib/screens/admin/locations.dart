import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_dialog.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';

class Locations extends StatelessWidget {
  const Locations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Locations',
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: HFColors().primaryColor(),
          borderRadius: BorderRadius.circular(24),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              adminLocationsAddRoute,
            );
          },
          icon: const Icon(CupertinoIcons.add),
        ),
      ),
      backgroundColor: HFColors().backgroundColor(),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 0.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('locations')
                      .orderBy("name", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No locations.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      return const Center(
                        child: HFParagrpah(
                          text: 'No locations.',
                          size: 10,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...data.docs.map(
                          (location) {
                            return HFListViewTile(
                              name: "${location['name']}",
                              id: location['id'],
                              useSpacerBottom: true,
                              showAvailable: false,
                              useImage: false,
                              icon: CupertinoIcons.trash,
                              onTap: () {
                                print(location['name']);

                                showAlertDialog(
                                  context,
                                  'Are you sure you want to delete location: ${location['name']}',
                                  () {
                                    FirebaseFirestore.instance
                                        .collection('locations')
                                        .doc(location['id'])
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  'Yes',
                                  () {
                                    Navigator.pop(context);
                                  },
                                  'No',
                                );
                              },
                            );
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
