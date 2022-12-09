import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

@freezed
class EventExercise with _$EventExercise {
  const factory EventExercise({
    required bool v2,
    required String id,
    required String name,
    required String exerciseId,
    required dynamic amount,
    required String repetitions,
    required String series,
    required Map<String, dynamic> pauseTime,
    required List<Map<String, dynamic>> warmups,
    required String repetitionType,
    required List<String> types,
    required String note,
    required String video,
    required String videoThumbnail,
  }) = _EventExercise;

  factory EventExercise.fromJson(Map<String, Object?> json) =>
      _$EventExerciseFromJson(json);
}
