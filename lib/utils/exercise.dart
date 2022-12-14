import 'dart:convert';
import 'package:uuid/uuid.dart';

class Exercise {
  final String title;
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final Map<String, dynamic> client;
  final String color;
  final List<dynamic> exercises;
  final String location;
  final String notes;
  final bool isDone;

  Exercise({
    required this.title,
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.client,
    required this.color,
    required this.exercises,
    required this.location,
    required this.notes,
    required this.isDone,
  });

  @override
  String toString() => jsonEncode(
        {
          "id": "$id",
          "title": "$title",
          "date": "$date",
          "startTime": "$startTime",
          "endTime": "$endTime",
          "client": "$client",
          "color": "$color",
          "exercises": "$exercises",
          "location": "$location",
          "notes": "$notes",
          "isDone": "$isDone",
        },
      );
}
