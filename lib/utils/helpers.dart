import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:provider/provider.dart';

List<String> getCoaches(BuildContext context, isCoach) {
  var coaches = ['C4Y'];

  if (isCoach) {
    coaches.add(context.read<HFGlobalState>().userDisplayName);
  }
  return coaches;
}

Map<String, dynamic> trainerProfileData(data) {
  return {
    'name': data['name'],
    'email': data['email'],
    'imageUrl': data['imageUrl'],
    'profileBackgroundImageUrl': data['profileBackgroundImageUrl'],
    'id': data['id'].replaceAll(' ', ''),
    'intro': data['intro'],
    'available': data['available'],
    'education': data['education'],
    'locations': data['locations'],
    'birthday': data['birthday'],
    'loggedIn': false
  };
}

Map<String, dynamic> videoData(data) {
  return {
    'name': data['name'],
    'thumbnail': data['thumbnail'],
    'url': data['url'],
    'description': data['description'],
    'id': data['id'],
    'author': data['author'],
  };
}

Map<String, dynamic> trainingData(data) {
  return {
    'name': data['name'],
    'id': data['id'],
    'note': data['note'],
    'exercises': data['exercises'],
  };
}

Map<String, dynamic> exerciseData(data) {
  return {
    'id': data['id'],
    'name': data['name'],
    'description': data['description'],
    'author': data['author'],
    'video': data['video'],
    'videoThumbnail': data['videoThumbnail'],
    'types': data['types'],
    'repetitionType': data['repetitionType'],
  };
}

List<Map<String, dynamic>> getChartData() {
  return [
    {
      'date': '2022-09-21 00:00:00.000Z',
      'value': 80,
    },
    {
      'date': '2022-09-22 00:00:00.000Z',
      'value': 85,
    },
    {
      'date': '2022-09-23 00:00:00.000Z',
      'value': 78,
    },
    {
      'date': '2022-09-24 00:00:00.000Z',
      'value': 100,
    },
    {
      'date': '2022-09-25 00:00:00.000Z',
      'value': 90,
    },
    {
      'date': '2022-09-26 00:00:00.000Z',
      'value': 103,
    },
    {
      'date': '2022-09-27 00:00:00.000Z',
      'value': 85,
    },
    {
      'date': '2022-09-28 00:00:00.000Z',
      'value': 89,
    },
    {
      'date': '2022-09-29 00:00:00.000Z',
      'value': 78,
    },
    {
      'date': '2022-09-30 00:00:00.000Z',
      'value': 90,
    },
    {
      'date': '2022-09-25 00:00:00.000Z',
      'value': 90,
    },
    {
      'date': '2022-09-26 00:00:00.000Z',
      'value': 103,
    },
    {
      'date': '2022-09-27 00:00:00.000Z',
      'value': 85,
    },
    {
      'date': '2022-09-28 00:00:00.000Z',
      'value': 89,
    }
  ];
}

DocumentReference<Map<String, dynamic>> getVideoById(id) {
  return FirebaseFirestore.instance.collection('videos').doc(id);
}

DocumentReference<Map<String, dynamic>> getExerciseTypeById(id) {
  return FirebaseFirestore.instance.collection('exerciseType').doc(id);
}
