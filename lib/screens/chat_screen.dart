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

import '../widgets/hf_chat_message.dart';
import '../widgets/hf_image.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String email;
  final String id;
  final String imageUrl;

  const ChatScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.id,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageInputController = TextEditingController();
  int messageNumber = 0;

  @override
  void initState() {
    if (context.read<HFGlobalState>().userAccessLevel == accessLevels.trainer) {
      resetMessagesNumberTrainer();
    }
    if (context.read<HFGlobalState>().userAccessLevel == accessLevels.client) {
      resetMessagesNumberClient();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HFColors().secondaryColor(),
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom <= 40 ? 108 : 68,
              left: 0,
              right: 0,
              top: 134,
              child: Container(
                color: HFColors().pinkColor(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 100, maxHeight: 536),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('trainers')
                        .doc(getTrainerId())
                        .collection('clients')
                        .doc(getClientId())
                        .collection('messages')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return Container(
                          color: HFColors().secondaryLightColor(),
                          child: Center(
                            child: HFParagrpah(
                              text: 'No messages',
                              size: 10,
                            ),
                          ),
                        );
                      }

                      var data = snapshot.data as QuerySnapshot;

                      if (context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.client) {
                        resetMessagesNumberClient();
                      }
                      if (context.read<HFGlobalState>().userAccessLevel ==
                          accessLevels.trainer) {
                        resetMessagesNumberTrainer();
                      }

                      if (data.docs.isEmpty) {
                        return Container(
                          color: HFColors().secondaryLightColor(),
                          child: Center(
                            child: HFParagrpah(
                              text: 'No messages',
                              size: 10,
                            ),
                          ),
                        );
                      }

                      return Container(
                        // MediaQuery.of(context).size.height
                        padding: EdgeInsets.symmetric(horizontal: 16),

                        color: HFColors().secondaryLightColor(),
                        child: ListView(
                          reverse: true,
                          children: [
                            ...data.docs.map(
                              (message) {
                                return HFChatMessage(
                                  id: message['senderId'],
                                  text: message['text'],
                                  date: message['date'],
                                  alignment:
                                      context.read<HFGlobalState>().userId ==
                                              message['senderId']
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  color: context.read<HFGlobalState>().userId ==
                                          message['senderId']
                                      ? HFColors().primaryColor()
                                      : HFColors().secondaryColor(),
                                );
                              },
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom <= 40 ? 40 : 0,
              left: 0,
              right: 0,
              child: Container(
                color: HFColors().secondaryColor(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: HFInput(
                        controller: messageInputController,
                        hintText: 'text',
                        verticalContentPadding: 0,
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: HFColors().primaryColor(),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          CupertinoIcons.arrow_up,
                          color: HFColors().secondaryColor(),
                          size: 20,
                        ),
                      ),
                      onTap: () {
                        if (messageInputController.text != '') {
                          var newId = Uuid().v4();
                          var date = "${DateTime.now()}";
                          var messageText = messageInputController.text;

                          messageInputController.text = '';

                          FirebaseFirestore.instance
                              .collection('trainers')
                              .doc(getTrainerId())
                              .collection('clients')
                              .doc(getClientId())
                              .collection('messages')
                              .doc(newId)
                              .set({
                            "id": newId,
                            "text": messageText,
                            "date": date,
                            "senderId": context.read<HFGlobalState>().userId,
                            "status": "unread",
                          }).then((value) {
                            FirebaseFirestore.instance
                                .collection('trainers')
                                .doc(getTrainerId())
                                .collection('clients')
                                .doc(getClientId())
                                .update({
                              'messages.lastMessageDate': date,
                              'messages.lastMessageText': messageText,
                              if (context
                                      .read<HFGlobalState>()
                                      .userAccessLevel ==
                                  accessLevels.client)
                                'messages.numberOfUnseenClient': 0,
                              if (context
                                      .read<HFGlobalState>()
                                      .userAccessLevel ==
                                  accessLevels.trainer)
                                'messages.numberOfUnseenTrainer': 0,
                            }).then((value) {
                              FirebaseFirestore.instance
                                  .collection('trainers')
                                  .doc(getTrainerId())
                                  .collection('clients')
                                  .doc(getClientId())
                                  .get()
                                  .then((value) {
                                var numberOfMessages = context
                                            .read<HFGlobalState>()
                                            .userAccessLevel ==
                                        accessLevels.client
                                    ? value['messages']['numberOfUnseenTrainer']
                                    : value['messages']['numberOfUnseenClient'];

                                FirebaseFirestore.instance
                                    .collection('trainers')
                                    .doc(getTrainerId())
                                    .collection('clients')
                                    .doc(getClientId())
                                    .update({
                                  if (context
                                          .read<HFGlobalState>()
                                          .userAccessLevel ==
                                      accessLevels.client)
                                    'messages.numberOfUnseenTrainer':
                                        numberOfMessages + 1,
                                  if (context
                                          .read<HFGlobalState>()
                                          .userAccessLevel ==
                                      accessLevels.trainer)
                                    'messages.numberOfUnseenClient':
                                        numberOfMessages + 1,
                                });
                              });
                            });
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Container(
                color: HFColors().secondaryColor(),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 16.0, bottom: 16, top: 10),
                  child: Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.chevron_back,
                          color: HFColors().primaryColor(),
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(72 / 6),
                          child: HFImage(imageUrl: widget.imageUrl),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HFParagrpah(
                              text: 'Sending to:',
                              size: 8,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            HFHeading(
                              text: widget.name,
                              size: 4,
                              color: HFColors().whiteColor(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  resetMessagesNumberTrainer() {
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(getTrainerId())
        .collection('clients')
        .doc(getClientId())
        .update({'messages.numberOfUnseenTrainer': 0});
  }

  resetMessagesNumberClient() {
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(getTrainerId())
        .collection('clients')
        .doc(getClientId())
        .update({'messages.numberOfUnseenClient': 0});
  }

  getTrainerId() {
    return context.read<HFGlobalState>().userAccessLevel == accessLevels.trainer
        ? context.read<HFGlobalState>().userId
        : widget.id;
  }

  getClientId() {
    return context.read<HFGlobalState>().userAccessLevel == accessLevels.client
        ? context.read<HFGlobalState>().userEmail
        : widget.email;
  }
}
