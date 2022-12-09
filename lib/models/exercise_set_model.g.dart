// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ExerciseSet _$$_ExerciseSetFromJson(Map<String, dynamic> json) =>
    _$_ExerciseSet(
      v2: json['v2'] as bool,
      author: json['author'] as String,
      description: json['description'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      repetitionType: json['repetitionType'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      warmups: (json['warmups'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      video: json['video'] as String,
      videoThumbnail: json['videoThumbnail'] as String,
    );

Map<String, dynamic> _$$_ExerciseSetToJson(_$_ExerciseSet instance) =>
    <String, dynamic>{
      'v2': instance.v2,
      'author': instance.author,
      'description': instance.description,
      'id': instance.id,
      'name': instance.name,
      'repetitionType': instance.repetitionType,
      'types': instance.types,
      'warmups': instance.warmups,
      'video': instance.video,
      'videoThumbnail': instance.videoThumbnail,
    };
