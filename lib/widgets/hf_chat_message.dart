import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import 'hf_dialog.dart';
import 'hf_paragraph.dart';

class HFChatMessage extends StatelessWidget {
  const HFChatMessage({
    Key? key,
    this.id = '',
    this.text = 'No text',
    this.date = 'no date',
    this.alignment = MainAxisAlignment.start,
    this.color = const Color.fromRGBO(17, 17, 17, 1),
  }) : super(key: key);

  final String id;
  final String text;
  final String date;
  final Color color;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (id == context.read<HFGlobalState>().userId) {
          showAlertDialog(
            context,
            'Are you sure you want to delete this message?',
            () {
              FirebaseFirestore.instance
                  .collection('clients')
                  .doc(context.read<HFGlobalState>().userId)
                  .collection('chat')
                  .doc(id)
                  .delete()
                  .then((value) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(getSnackBar(text: 'Message deleted'));
              });
            },
            'Yes',
            () {
              Navigator.pop(context);
            },
            'No',
          );
        }
      },
      child: Column(
        crossAxisAlignment: alignment == MainAxisAlignment.start
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          HFParagrpah(
            text: DateFormat('HH:mm').format(DateTime.parse(date)),
            size: 8,
            color: HFColors().whiteColor(),
          ),
          SizedBox(
            height: 5,
          ),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: alignment,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    minWidth: MediaQuery.of(context).size.width * 0.2),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: color),
                  child: HFParagrpah(
                    text: text,
                    size: 10,
                    maxLines: 99,
                    color: color.computeLuminance() >= 0.5
                        ? HFColors().secondaryColor()
                        : HFColors().whiteColor(),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
