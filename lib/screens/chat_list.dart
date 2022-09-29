import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/utils/chat_message.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_input_field.dart';
import 'package:health_factory/widgets/hf_list_view_tile.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/routes.dart';
import '../widgets/hf_chat_message.dart';
import '../widgets/hf_client_chat_tile.dart';
import '../widgets/hf_client_list_view_tile.dart';
import '../widgets/hf_image.dart';

class HFChatList extends StatelessWidget {
  const HFChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16, top: 10),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: StreamBuilder(
          stream: context.watch<HFGlobalState>().userId != ''
              ? FirebaseFirestore.instance
                  .collection('trainers')
                  .doc(context.read<HFGlobalState>().userId)
                  .collection('clients')
                  .orderBy('name', descending: true)
                  .snapshots()
              : Stream.empty(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(
                child: HFParagrpah(
                  text: 'No clients',
                  size: 10,
                ),
              );
            }

            var data = snapshot.data as QuerySnapshot;

            if (data.docs.isEmpty) {
              return Center(
                child: HFParagrpah(
                  text: 'No clients',
                  size: 10,
                ),
              );
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height - 136,
              child: ListView(
                children: [
                  ...data.docs.map((client) {
                    if (!client['accountReady']) {
                      return SizedBox(
                        height: 0,
                      );
                    }
                    return HFClientChatTile(
                      name: client['name'],
                      text: client['messages']['lastMessageText'],
                      number: client['messages']['numberOfUnseen'],
                      imageUrl: client['imageUrl'],
                      available: client['accountReady'],
                      imageSize: 52,
                      showAvailable: false,
                      useSpacerBottom: true,
                      headingMargin: 4,
                      onTap: () {
                        Navigator.pushNamed(context, chatScreen, arguments: {
                          'name': client['name'],
                          'id': client['id'],
                          'imageUrl': client['imageUrl'],
                          'email': client['email'],
                          'asTrainer': true
                        });
                      },
                      child: HFParagrpah(
                        text: client['messages']['lastMessageText'],
                        maxLines: 2,
                        size: 8,
                        color: HFColors().whiteColor(opacity: 0.7),
                      ),
                    );
                  })
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
