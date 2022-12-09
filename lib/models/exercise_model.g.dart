// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EventExercise _$$_EventExerciseFromJson(Map<String, dynamic> json) =>
    _$_EventExercise(
      v2: json['v2'] as bool,
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseId: json['exerciseId'] as String,
      amount: json['amount'],
      repetitions: json['repetitions'] as String,
      series: json['series'] as String,
      pauseTime: json['pauseTime'] as Map<String, dynamic>,
      warmups: (json['warmups'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      repetitionType: json['repetitionType'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      note: json['note'] as String,
      video: json['video'] as String,
      videoThumbnail: json['videoThumbnail'] as String,
    );

Map<String, dynamic> _$$_EventExerciseToJson(_$_EventExercise instance) =>
    <String, dynamic>{
      'v2': instance.v2,
      'id': instance.id,
      'name': instance.name,
      'exerciseId': instance.exerciseId,
      'amount': instance.amount,
      'repetitions': instance.repetitions,
      'series': instance.series,
      'pauseTime': instance.pauseTime,
      'warmups': instance.warmups,
      'repetitionType': instance.repetitionType,
      'types': instance.types,
      'note': instance.note,
      'video': instance.video,
      'videoThumbnail': instance.videoThumbnail,
    };
