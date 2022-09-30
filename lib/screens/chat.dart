import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/screens/chat_list.dart';
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
import '../widgets/hf_image.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageInputController = TextEditingController();
  String coachName = '';
  String coachImageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HFColors().secondaryColor(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 60),
              child: const HFHeading(
                text: 'Chat',
                size: 10,
              ),
            ),
            if (context.watch<HFGlobalState>().userAccessLevel ==
                accessLevels.client)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder(
                    stream: context.watch<HFGlobalState>().userTrainerId != ''
                        ? FirebaseFirestore.instance
                            .collection('trainers')
                            .doc(context.read<HFGlobalState>().userTrainerId)
                            .snapshots()
                        : Stream.empty(),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return HFParagrpah(
                          size: 8,
                          text: 'No messages',
                        );
                      }

                      var data = snapshot.data as DocumentSnapshot;

                      return StreamBuilder<Object>(
                          stream: FirebaseFirestore.instance
                              .collection('trainers')
                              .doc(context.read<HFGlobalState>().userTrainerId)
                              .collection('clients')
                              .doc(context.read<HFGlobalState>().userEmail)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.hasError) {
                              return HFParagrpah(
                                size: 8,
                                text: 'No messages',
                              );
                            }

                            var client = snapshot.data as DocumentSnapshot;

                            return HFClientChatTile(
                              name: data['name'],
                              text: client['messages']['lastMessageText'],
                              number: client['messages']
                                  ['numberOfUnseenClient'],
                              imageUrl: data['imageUrl'],
                              date: client['messages']['lastMessageDate'],
                              available: true,
                              imageSize: 52,
                              showAvailable: false,
                              useSpacerBottom: true,
                              headingMargin: 4,
                              onTap: () {
                                Navigator.pushNamed(context, chatScreen,
                                    arguments: {
                                      'name': data['name'],
                                      'id': data['id'],
                                      'imageUrl': data['imageUrl'],
                                      'email': data['email'],
                                    });
                              },
                              child: HFParagrpah(
                                text: client['messages']['lastMessageText'],
                                maxLines: 2,
                                size: 8,
                                color: HFColors().whiteColor(opacity: 0.7),
                              ),
                            );
                          });
                    })),
              ),
            if (context.watch<HFGlobalState>().userAccessLevel ==
                accessLevels.trainer)
              HFChatList()
          ],
        ),
      ),
    );
  }
}
