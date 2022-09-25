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
    'id': data['id'],
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

DocumentReference<Map<String, dynamic>> getVideoById(id) {
  return FirebaseFirestore.instance.collection('videos').doc(id);
}

DocumentReference<Map<String, dynamic>> getExerciseTypeById(id) {
  return FirebaseFirestore.instance.collection('exerciseType').doc(id);
}
