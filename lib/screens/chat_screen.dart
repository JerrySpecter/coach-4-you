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
    resetMessagesNumber();

    super.initState();
  }

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
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16, top: 10),
              child: Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            Container(
              color: HFColors().secondaryColor(),
              child: SizedBox(
                height: (MediaQuery.of(context).size.height - 272) -
                    (MediaQuery.of(context).viewInsets.bottom - 103),
                child: Stack(children: [
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom >= 171
                        ? 70
                        : 171,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height -
                        340 -
                        (MediaQuery.of(context).viewInsets.bottom > 103
                            ? MediaQuery.of(context).viewInsets.bottom - 103
                            : 0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('trainers')
                          .doc(context.read<HFGlobalState>().userId)
                          .collection('chat')
                          .doc(widget.id)
                          .collection('messages')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (!snapshot.hasData || snapshot.hasError) {
                          return Center(
                            child: HFParagrpah(
                              text: 'No messages',
                              size: 10,
                            ),
                          );
                        }

                        var data = snapshot.data as QuerySnapshot;

                        resetMessagesNumber();

                        if (data.docs.isEmpty) {
                          return Center(
                            child: HFParagrpah(
                              text: 'No messages',
                              size: 10,
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
                                    id: message['id'],
                                    text: message['text'],
                                    date: message['date'],
                                    alignment:
                                        context.read<HFGlobalState>().userId ==
                                                message['senderId']
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    color:
                                        context.read<HFGlobalState>().userId ==
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
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: HFColors().secondaryColor(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 10,
                            child: HFInput(
                              controller: messageInputController,
                              hintText: 'text',
                              verticalContentPadding: 0,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            child: Container(
                                child: Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              color: HFColors().primaryColor(),
                              size: 30,
                            )),
                            onTap: () {
                              if (messageInputController.text != '') {
                                var newId = Uuid().v4();
                                var date = "${DateTime.now()}";
                                var messageText = messageInputController.text;

                                messageInputController.text = '';

                                FirebaseFirestore.instance
                                    .collection('trainers')
                                    .doc(context.read<HFGlobalState>().userId)
                                    .collection('chat')
                                    .doc(widget.id)
                                    .collection('messages')
                                    .doc(newId)
                                    .set({
                                  "id": newId,
                                  "text": messageText,
                                  "date": date,
                                  "senderId":
                                      context.read<HFGlobalState>().userId,
                                  "status": "unread",
                                }).then((value) {
                                  FirebaseFirestore.instance
                                      .collection('trainers')
                                      .doc(context.read<HFGlobalState>().userId)
                                      .collection('clients')
                                      .doc(widget.email)
                                      .update({
                                    'messages.lastMessageDate': date,
                                    'messages.lastMessageText': messageText,
                                  });
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  resetMessagesNumber() {
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(context.read<HFGlobalState>().userId)
        .collection('clients')
        .doc(widget.email)
        .update({'messages.numberOfUnseen': 0});
  }
}
