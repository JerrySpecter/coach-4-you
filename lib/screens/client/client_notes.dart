import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import '../../../constants/colors.dart';
import 'package:intl/intl.dart';

import '../../widgets/hf_input_field.dart';

class ClientNotes extends StatefulWidget {
  const ClientNotes({
    Key? key,
    this.clientEmail = '',
    this.clientId = '',
  }) : super(key: key);

  final String clientEmail;
  final String clientId;

  @override
  State<ClientNotes> createState() => _ClientNotesState();
}

class _ClientNotesState extends State<ClientNotes> {
  final TextEditingController searchFieldController = TextEditingController();
  String searchNotesText = '';
  Stream notesStream = const Stream.empty();

  @override
  void initState() {
    super.initState();

    setState(() {
      notesStream = HFFirebaseFunctions()
          .getFirebaseAuthUser(context)
          .collection(COLLECTION_CLIENTS)
          .doc(widget.clientEmail)
          .collection(COLLECTION_NOTES)
          .orderBy('date', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: HFHeading(
          text: 'Notes:',
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: HFColors().primaryColor(),
        ),
        child: IconButton(
          icon: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.pushNamed(context, clientAddNotes, arguments: {
              'clientEmail': widget.clientEmail,
              'clientId': widget.clientId,
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: HFColors().primaryColor(opacity: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: HFInput(
                        controller: searchFieldController,
                        onChanged: (value) {
                          setState(() {
                            searchNotesText = value;
                            notesStream = getNotesStream(searchNotesText);
                          });
                        },
                        hintText: 'Search notes',
                        keyboardType: TextInputType.text,
                        verticalContentPadding: 12,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 220,
                        child: StreamBuilder(
                          stream: notesStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: HFParagrpah(
                                  text: 'No notes.',
                                  size: 10,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            var data = snapshot.data as QuerySnapshot;

                            if (data.docs.isEmpty) {
                              return const Center(
                                child: HFParagrpah(
                                  text: 'No notes.',
                                  size: 10,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return ListView(
                              shrinkWrap: true,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                ...data.docs.map(
                                  (note) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: HFListViewTile(
                                        showAvailable: false,
                                        useImage: false,
                                        name: note['name'],
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, clientNotesSingle,
                                              arguments: {
                                                'clientEmail':
                                                    widget.clientEmail,
                                                'clientId': widget.clientId,
                                                'noteId': note['id'],
                                                'name': note['name'],
                                                'description':
                                                    note['description'],
                                                'filepath': note['filepath'],
                                                'date': note['date'],
                                              });
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            HFParagrpah(
                                              size: 6,
                                              text: DateFormat('EEE, d/M/y')
                                                  .format(DateTime.parse(
                                                      note['date'])),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }

  getNotesStream(searchText) {
    return HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection(COLLECTION_CLIENTS)
        .doc(widget.clientEmail)
        .collection(COLLECTION_NOTES)
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThan: '${searchText}z')
        .orderBy("name", descending: false)
        .snapshots();
  }
}
