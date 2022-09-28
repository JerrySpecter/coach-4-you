import 'dart:convert';

class ChatMessage {
  final String id;
  final String text;
  final String date;
  final String senderId;
  final messageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.date,
    required this.senderId,
    this.status = messageStatus.sent,
  });

  @override
  String toString() => jsonEncode(
        {
          "id": "$id",
          "text": "$text",
          "date": "$date",
          "senderId": "$senderId",
          "status": "$status",
        },
      );

  Map<String, dynamic> toJson() => ({
        "id": "$id",
        "text": "$text",
        "date": "$date",
        "senderId": "$senderId",
        "status": "$status",
      });
}

enum messageStatus { sending, sent, delivered }
